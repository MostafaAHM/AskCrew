import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/validations/validators.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/core/widgets/fields/password_field.dart';
import 'package:aflam/features/shared/change_password/presentation/cubit/change_password_cubit.dart';
import 'package:aflam/features/shared/change_password/presentation/cubit/change_password_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/app_config/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword(BuildContext context) {
    final cubit = context.read<ChangePasswordCubit>();
    if (cubit.state is ChangePasswordLoading) return;

    if (!_formKey.currentState!.validate()) return;

    cubit.changePassword(
      oldPassword: _oldPasswordController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChangePasswordCubit>(),
      child: BlocListener<ChangePasswordCubit, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordLoading) {
            AppMessages.showLoading(context);
          } else if (state is ChangePasswordSuccess) {
            AppMessages.hideLoading(context);
            AppMessages.showSuccess(
              context,
              AppStrings.passwordChangedSuccessfully.tr(),
            );
            context.pop();
          } else if (state is ChangePasswordError) {
            AppMessages.hideLoading(context);
            AppMessages.showError(context, state.message);
          }
        },
        child: Scaffold(
          appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
          body: SafeArea(
            child: Padding(
              padding: REdgeInsets.symmetric(horizontal: 16.w),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    20.height,
                    Center(
                      child: Text(
                        AppStrings.changePassword.tr(),
                        style: TextStyle(
                          color: AppColors.lightTText,
                          fontSize: 25.sp, // +5
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    10.height,
                    Text(
                      AppStrings.changePasswordDescription.tr(),
                      style: TextStyle(
                        color: AppColors.lightTText,
                        fontSize: 19.sp, // +5
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    32.height,
                    PasswordField(
                      label: AppStrings.oldPassword.tr(),
                      hint: '********',
                      controller: _oldPasswordController,
                      validator: CustomValidators.validateEmpty,
                    ),
                    25.height,
                    PasswordField(
                      label: AppStrings.newPassword.tr(),
                      hint: '********',
                      controller: _newPasswordController,
                      validator: CustomValidators.validatePassword,
                    ),
                    25.height,
                    PasswordField(
                      label: AppStrings.confirmPassword.tr(),
                      hint: '********',
                      controller: _confirmPasswordController,
                      validator: (value) =>
                          CustomValidators.validateConfirmPassword(
                            _newPasswordController.text.trim(),
                            value,
                          ),
                    ),
                    200.height,
                    BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                      builder: (context, state) {
                        final isLoading = state is ChangePasswordLoading;
                        return CustomButton(
                          text: AppStrings.saveChanges.tr(),
                          isBackgroundGradient: true,
                          enabled: !isLoading,
                          onTap: () => _handleChangePassword(context),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
