import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/helpers/user_helper.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
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

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
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

    // Get password from secure storage
    final password = await SecureLocalStorage.read(PrefsKeys.password) ?? '';

    // Create basic data from current user
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

    // Navigate to onboarding based on user type
    switch (currentUser.type.toLowerCase()) {
      case 'enterprise':
        // Navigate to enterprise onboarding with swap flag (uses complete-enterprise-profile endpoint)
        context.go(
          '${Routes.enterpriseOnboarding}?swap=true',
          extra: basicData,
        );
        break;
      case 'student':
        // Navigate to student onboarding with swap flag (uses complete-student-profile endpoint)
        context.go(
          '${Routes.studentOnboarding}?swap=true',
          extra: studentBasicData,
        );
        break;
      case 'viewer':
        context.go(Routes.viewerHome);
        break;
      default:
        context.go(Routes.moduleSelection);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: Scaffold(
          appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pending_actions,
                    size: 100.sp,
                    color: AppColors.secondaryColor,
                  ),
                  32.height,
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
                  40.height,
                  BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      final isLoading = state is ProfileLoading;
                      return CustomButton(
                        text: 'checkStatus'.tr(),
                        isBackgroundGradient: true,
                        enabled: !isLoading,
                        onTap: isLoading ? null : () => _checkUserStatus(context),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
          );
        },
      ),
    );
  }
}

