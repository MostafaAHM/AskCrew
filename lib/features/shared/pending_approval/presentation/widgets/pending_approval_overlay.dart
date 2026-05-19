import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/helpers/user_helper.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/data/repository/profile_repository.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/presentation/cubit/profile_cubit.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/presentation/cubit/profile_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../core/app_config/prefs_keys.dart';
import '../../../../../core/helpers/secure_local_storage.dart';
import '../../../../auth/enterprise/enterprise_auth_flow/data/models/request/enterprise_basic_data.dart';
import '../../../../auth/student/student_auth_flow/data/models/request/student_basic_data.dart';

class PendingApprovalOverlay extends StatefulWidget {
  final Widget child;

  const PendingApprovalOverlay({
    super.key,
    required this.child,
  });

  @override
  State<PendingApprovalOverlay> createState() => _PendingApprovalOverlayState();
}

class _PendingApprovalOverlayState extends State<PendingApprovalOverlay> {
  bool _hasCheckedInitialStatus = false;

  void _checkUserStatus(BuildContext context) {
    final currentUser = UserHelper.userNotifier.value;
    if (currentUser != null && mounted) {
      context.read<ProfileCubit>().getUserProfile(currentUser.id);
    }
  }

  Future<void> _navigateToOnboarding() async {
    final currentUser = UserHelper.userNotifier.value;
    if (currentUser == null) {
      context.go(Routes.moduleSelection);
      return;
    }

    // Get original user type to check if it was viewer
    final originalUserType = await SecureLocalStorage.read(PrefsKeys.originalUserType);
    final wasViewer = originalUserType?.toLowerCase() == 'viewer';
    
    // Get password from secure storage
    final password = await SecureLocalStorage.read(PrefsKeys.password) ?? '';

    // Get current user type after swap
    final currentUserType = currentUser.type.toLowerCase();

    // If original user was viewer, they must complete onboarding data
    // If original user was enterprise/student, they can navigate directly (no onboarding needed)
    if (wasViewer) {
      // Viewer must complete data for enterprise or student
      final basicData = EnterpriseBasicData(
        fullname: currentUser.fullname,
        email: currentUser.email,
        mobilePhone: currentUser.mobilePhone,
        password: password,
      );

      final studentBasicData = StudentBasicData(
        fullname: currentUser.fullname,
        email: currentUser.email,
        mobilePhone: currentUser.mobilePhone,
        password: password,
      );

      switch (currentUserType) {
        case 'enterprise':
          context.go(
            '${Routes.enterpriseOnboarding}?swap=true',
            extra: basicData,
          );
          break;
        case 'student':
          context.go(
            '${Routes.studentOnboarding}?swap=true',
            extra: studentBasicData,
          );
          break;
        case 'viewer':
          context.go(Routes.completeViewerProfile);
          break;
        default:
          context.go(Routes.moduleSelection);
          break;
      }
    } else {
      // Enterprise/Student swapping to each other - navigate directly to home
      // No onboarding needed as they already have complete profiles
      switch (currentUserType) {
        case 'enterprise':
          context.go(Routes.enterpriseHome);
          break;
        case 'student':
          context.go(Routes.studentHome);
          break;
        case 'viewer':
          context.go(Routes.viewerHome);
          break;
        default:
          context.go(Routes.moduleSelection);
          break;
      }
      
      // Clear original user type after successful navigation
      await SecureLocalStorage.delete(PrefsKeys.originalUserType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = UserHelper.userNotifier.value;
    
    // Only show overlay for enterprise and student
    if (currentUser == null) {
      return widget.child;
    }

    final userType = currentUser.type.toLowerCase();
    if (userType != 'enterprise' && userType != 'student') {
      return widget.child;
    }

    final isActive = currentUser.isActive;
    final isActivatedByAdmin = currentUser.profile?.isActivatedByAdmin;
    
    // Show overlay only if:
    // 1. User is not active, OR
    // 2. User has swapped (isActivatedByAdmin is explicitly false, meaning waiting for approval)
    // 
    // Don't show overlay if:
    // - isActivatedByAdmin is null (original enterprise/student user, no swap)
    // - isActivatedByAdmin is true (already approved)
    // - isActive is true and isActivatedByAdmin is null (original user, no approval needed)
    
    if (!isActive) {
      // User is not active, show overlay
    } else if (isActivatedByAdmin == false) {
      // User has swapped and is waiting for approval (isActivatedByAdmin explicitly false)
    } else {
      // User is active and either approved (true) or original user (null) - don't show overlay
      return widget.child;
    }

    // Show overlay with pending approval message
    return BlocProvider(
      create: (context) => ProfileCubit(getIt<ProfileRepository>()),
      child: Builder(
        builder: (blocContext) {
          // Check user status after BlocProvider is available (only once)
          if (!_hasCheckedInitialStatus) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _hasCheckedInitialStatus = true;
                });
                _checkUserStatus(blocContext);
              }
            });
          }

          return BlocListener<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileLoaded) {
                final user = state.user;
                UserHelper.setUser(user);
                
                // Check if user is now activated
                final isActive = user.isActive;
                final isActivatedByAdmin = user.profile?.isActivatedByAdmin ?? false;
                
                if (isActive && isActivatedByAdmin) {
                  // User is approved, navigate to onboarding to complete registration
                  AppMessages.showSuccess(context, 'accountApproved'.tr());
                  _navigateToOnboarding();
                }
              } else if (state is ProfileError) {
                AppMessages.showError(context, state.message);
              }
            },
            child: Stack(
              children: [
                // Original content (blurred/disabled)
                Opacity(
                  opacity: 0.5,
                  child: IgnorePointer(
                    child: widget.child,
                  ),
                ),
                // Overlay
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pending_actions,
                            size: 80.sp,
                            color: AppColors.secondaryColor,
                          ),
                          24.height,
                          Text(
                            'pendingApproval'.tr(),
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightTText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          16.height,
                          Text(
                            'pendingApprovalMessage'.tr(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          32.height,
                          BlocBuilder<ProfileCubit, ProfileState>(
                            builder: (context, state) {
                              final isLoading = state is ProfileLoading;
                              return CustomButton(
                                text: 'checkStatus'.tr(),
                                isBackgroundGradient: true,
                                enabled: !isLoading,
                                onTap: isLoading
                                    ? null
                                    : () => _checkUserStatus(context),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

