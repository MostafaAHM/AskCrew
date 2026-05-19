import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/helpers/user_helper.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/features/shared/swap_accounts/presentation/cubit/swap_account_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'dart:convert';

import '../../../../../config/routes/routes.dart';
import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/prefs_keys.dart';
import '../../../../../core/helpers/secure_local_storage.dart';
import '../../../../../features/auth/login/data/model/response/user_model.dart';

class SwapAccountsScreen extends StatefulWidget {
  const SwapAccountsScreen({super.key});

  @override
  State<SwapAccountsScreen> createState() => _SwapAccountsScreenState();
}

class _SwapAccountsScreenState extends State<SwapAccountsScreen> {
  String? _selectedAccountType;
  String?
  _targetAccountType; // Store target account type for after swap success

  @override
  Widget build(BuildContext context) {
    final currentUser = UserHelper.userNotifier.value;
    final currentUserType = currentUser?.type.toLowerCase() ?? '';

    // Filter out current user type
    final availableAccountTypes = [
      AccountType(
        type: 'enterprise',
        title: 'enterprise'.tr(),
        description: 'enterprise_desc'.tr(),
      ),
      AccountType(
        type: 'student',
        title: 'student'.tr(),
        description: 'student_desc'.tr(),
      ),
      AccountType(
        type: 'viewer',
        title: 'viewer'.tr(),
        description: 'viewer_desc'.tr(),
      ),
    ].where((account) => account.type != currentUserType).toList();

    return BlocProvider(
      create: (context) => getIt<SwapAccountCubit>(),
      child: BlocListener<SwapAccountCubit, SwapAccountState>(
        listener: (context, state) {
          if (state is SwapAccountLoading) {
            AppMessages.showLoading(context);
          } else if (state is SwapAccountSuccess) {
            AppMessages.hideLoading(context);
            AppMessages.showSuccess(
              context,
              state.response.message ?? 'accountSwappedSuccessfully'.tr(),
            );
            // Update user type in UserHelper after successful swap
            _updateUserTypeAndNavigate(context);
          } else if (state is SwapAccountError) {
            AppMessages.hideLoading(context);

            // Check if error is related to incomplete profile
            final lowerMsg = state.message.toLowerCase();
            // Only redirect if message explicitly asks to complete profile/data
            final isProfileIncomplete =
                (lowerMsg.contains('complete') &&
                    (lowerMsg.contains('profile') ||
                        lowerMsg.contains('data') ||
                        lowerMsg.contains('account'))) ||
                (lowerMsg.contains('missing') &&
                    (lowerMsg.contains('fields') ||
                        lowerMsg.contains('data'))) ||
                lowerMsg.contains('اكمل بيانات') ||
                lowerMsg.contains('استكمال العضوية') ||
                lowerMsg.contains('البيانات ناقصة');

            if (isProfileIncomplete) {
              final targetType = _targetAccountType ?? _selectedAccountType;
              if (targetType != null) {
                if (targetType == 'enterprise') {
                  context.pushNamed(
                    Routes.enterpriseOnboarding,
                    queryParameters: {'swap': 'true'},
                  );
                  return;
                } else if (targetType == 'student') {
                  context.pushNamed(
                    Routes.studentOnboarding,
                    queryParameters: {'swap': 'true'},
                  );
                  return;
                }
              }
            }

            AppMessages.showError(context, state.message);
          }
        },
        child: Scaffold(
          appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
          body: SafeArea(
            child: Padding(
              padding: REdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        20.height,
                        Center(
                          child: Text(
                            'swapAccounts'.tr(),
                            style: TextStyle(
                              color: AppColors.lightTText,
                              fontSize: 25.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        32.height,
                        ...availableAccountTypes.map((accountType) {
                          final isSelected =
                              _selectedAccountType == accountType.type;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: _AccountCard(
                              accountType: accountType,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  _selectedAccountType = accountType.type;
                                });
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  if (_selectedAccountType != null) ...[
                    20.height,
                    BlocBuilder<SwapAccountCubit, SwapAccountState>(
                      builder: (context, state) {
                        final isLoading = state is SwapAccountLoading;
                        return CustomButton(
                          text: 'confirm'.tr(),
                          isBackgroundGradient: true,
                          enabled: !isLoading,
                          onTap: () => _handleAccountSwitch(
                            context,
                            _selectedAccountType!,
                          ),
                        );
                      },
                    ),
                    20.height,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAccountSwitch(
    BuildContext context,
    String accountType,
  ) async {
    final currentUser = UserHelper.userNotifier.value;
    final currentUserType = currentUser?.type.toLowerCase() ?? '';

    // Save target account type for after swap success
    setState(() {
      _targetAccountType = accountType;
    });

    // Save original user type before swap (only if not already saved)
    final savedOriginalType = await SecureLocalStorage.read(
      PrefsKeys.originalUserType,
    );
    if (savedOriginalType == null && currentUserType.isNotEmpty) {
      await SecureLocalStorage.write(
        PrefsKeys.originalUserType,
        currentUserType,
      );
    }

    final cubit = context.read<SwapAccountCubit>();

    // Call swap endpoint first
    switch (accountType) {
      case 'enterprise':
        cubit.swapToEnterprise();
        break;
      case 'student':
        cubit.swapToStudent();
        break;
      case 'viewer':
        cubit.swapToViewer();
        break;
    }
  }

  Future<void> _updateUserTypeAndNavigate(BuildContext context) async {
    if (_targetAccountType == null) {
      context.go(Routes.moduleSelection);
      return;
    }

    // Update user type in UserHelper after successful swap
    final currentUser = UserHelper.userNotifier.value;
    if (currentUser != null) {
      // Create new UserModel with updated type
      final updatedUser = UserModel(
        id: currentUser.id,
        email: currentUser.email,
        fullname: currentUser.fullname,
        mobilePhone: currentUser.mobilePhone,
        wallet: currentUser.wallet,
        points: currentUser.points,
        profilePhoto: currentUser.profilePhoto,
        personalInfo: currentUser.personalInfo,
        isVerified: currentUser.isVerified,
        waterMark: currentUser.waterMark,
        isActive: currentUser.isActive,
        type: _targetAccountType!,
        typeInt: currentUser
            .typeInt, // Keep same typeInt or update based on new type
        dateJoined: currentUser.dateJoined,
        profile: currentUser.profile,
        ratingCount: currentUser.ratingCount,
        ratingMean: currentUser.ratingMean,
      );
      UserHelper.setUser(updatedUser);

      // Update user in secure storage
      final userJson = updatedUser.toJson();
      await SecureLocalStorage.write(PrefsKeys.user, jsonEncode(userJson));
    }

    // Navigate to the new account type home
    switch (_targetAccountType!.toLowerCase()) {
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
  }
}

class AccountType {
  final String type;
  final String title;
  final String description;

  AccountType({
    required this.type,
    required this.title,
    required this.description,
  });
}

class _AccountCard extends StatelessWidget {
  final AccountType accountType;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountCard({
    required this.accountType,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Colors based on selection state
    final backgroundColor = isSelected
        ? const Color(0xFF50177A) // Selected card color
        : const Color(0x0A50177A); // Unselected card color (4% opacity)

    final borderColor = isSelected
        ? const Color(0xFFA785FF) // Border color when selected
        : Colors.transparent;

    // Text color: #DFDFDF with 92% opacity (EB in hex = 235/255 ≈ 92%)
    final textColor = isSelected
        ? const Color(0xEBDFDFDF) // Text color (92% opacity) when selected
        : AppColors.lightTText; // Default text color when not selected

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              accountType.title,
              style: TextStyle(
                color: textColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            8.height,
            Text(
              accountType.description,
              style: TextStyle(
                color: textColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
