import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/features/shared/delete_account/presentation/cubit/delete_account_cubit.dart';
import 'package:aflam/features/shared/delete_account/presentation/cubit/delete_account_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../config/routes/routes.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DeleteAccountCubit>(),
      child: BlocListener<DeleteAccountCubit, DeleteAccountState>(
        listener: (context, state) {
          if (state is DeleteAccountLoading) {
            AppMessages.showLoading(context);
          } else if (state is DeleteAccountSuccess) {
            AppMessages.hideLoading(context);
            AppMessages.showSuccess(context, 'accountDeletedSuccessfully'.tr());
            // Navigate to login screen
            context.go(Routes.login);
          } else if (state is DeleteAccountError) {
            AppMessages.hideLoading(context);
            AppMessages.showError(context, state.message);
          }
        },
        child: Scaffold(
          appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
          body: SafeArea(
            child: Padding(
              padding: REdgeInsets.symmetric(horizontal: 16.w),
              child: ListView(
                children: [
                  20.height,
                  Center(
                    child: Text(
                      'deleteAccount'.tr(),
                      style: TextStyle(
                        color: AppColors.lightTText,
                        fontSize: 25.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  32.height,
                  Text(
                    'deleteAccountWarningTitle'.tr(),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18.sp, // +5
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  8.height,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DeleteBullet(text: 'deleteAccountWarningPoint1'.tr()),
                      4.height,
                      _DeleteBullet(text: 'deleteAccountWarningPoint2'.tr()),
                      4.height,
                      _DeleteBullet(text: 'deleteAccountWarningPoint3'.tr()),
                    ],
                  ),
                  150.height,
                  BlocBuilder<DeleteAccountCubit, DeleteAccountState>(
                    builder: (context, state) {
                      final isLoading = state is DeleteAccountLoading;
                      final cubit = context.read<DeleteAccountCubit>();
                      return CustomButton(
                        text: 'delete'.tr(),
                        isBackgroundGradient: true,
                        enabled: !isLoading,
                        onTap: () {
                          _showDeleteConfirmationDialog(context, cubit);
                        },
                      );
                    },
                  ),
                  20.height,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, DeleteAccountCubit cubit) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'confirmDelete'.tr(),
          style: TextStyle(fontSize: 20.sp), // +5
        ),
        content: Text(
          'deleteAccountConfirmationMessage'.tr(),
          style: TextStyle(fontSize: 16.sp), // +5
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(fontSize: 16.sp), // +5
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cubit.deleteAccount();
            },
            child: Text(
              'delete'.tr(),
              style: TextStyle(
                fontSize: 16.sp, // +5
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteBullet extends StatelessWidget {
  final String text;
  const _DeleteBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(
            fontSize: 18.sp, // +5
            color: AppColors.lightTText,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18.sp, // +5
              color: AppColors.lightTText,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

