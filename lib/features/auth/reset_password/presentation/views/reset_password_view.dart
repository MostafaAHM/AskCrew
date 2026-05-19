import 'package:aflam/config/routes/routes.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/validations/validators.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/core/widgets/fields/custom_text_field.dart';
import 'package:aflam/core/widgets/fields/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:aflam/core/app_config/app_colors.dart';
import '../../data/model/reset_password_request_model.dart';
import '../cubit/reset_password_cubit.dart';

class ResetPasswordView extends StatefulWidget {
  final String? code;

  const ResetPasswordView({super.key, this.code});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.code != null && widget.code!.isNotEmpty) {
      // Clean the code: remove any spaces, dashes, and ensure it's only digits
      // The router already decodes URL parameters, so we don't need to decode again
      final cleanCode = widget.code!.trim().replaceAll(RegExp(r'[^\d]'), '');
      if (cleanCode.length == 6) {
        _codeController.text = cleanCode;
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<ResetPasswordCubit>();
    if (cubit.state is ResetPasswordLoading) return;

    // Clean the code: ensure it's exactly 6 digits, remove any non-digit characters
    final cleanCode = _codeController.text.trim().replaceAll(
      RegExp(r'[^\d]'),
      '',
    );

    if (cleanCode.isEmpty || cleanCode.length != 6) {
      AppMessages.showError(context, AppStrings.otpCodeMustBe6Digits.tr());
      return;
    }

    final request = ResetPasswordRequestModel(
      code: cleanCode,
      newPassword: _newPasswordController.text.trim(),
    );

    cubit.resetPassword(request);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ResetPasswordCubit>(),
      child: BlocListener<ResetPasswordCubit, ResetPasswordState>(
        listener: (context, state) {
          if (state is ResetPasswordLoading) {
            AppMessages.showLoading(context);
          } else if (state is ResetPasswordSuccess) {
            AppMessages.hideLoading(context);
            AppMessages.showSuccess(
              context,
              AppStrings.passwordResetSuccessfully.tr(),
            );
            context.go(Routes.login);
          } else if (state is ResetPasswordFailure) {
            AppMessages.hideLoading(context);
            AppMessages.showError(context, state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.lightBGColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.lightTText),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(Routes.login);
                }
              },
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Form(
                key: _formKey,
                child: BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
                  builder: (context, state) {
                    final isLoading = state is ResetPasswordLoading;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.resetPassword.tr(),
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.lightTText,
                          ),
                        ),
                        8.height,
                        Text(
                          AppStrings.enterCodeAndNewPassword.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.greyText,
                          ),
                        ),
                        32.height,
                        CustomTextField(
                          label: AppStrings.otpCode.tr(),
                          hint: AppStrings.enterOtpCode.tr(),
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.otpCodeIsRequired.tr();
                            }
                            // Remove any non-digit characters for validation
                            final cleanValue = value.replaceAll(
                              RegExp(r'[^\d]'),
                              '',
                            );
                            if (cleanValue.length != 6) {
                              return AppStrings.otpCodeMustBe6Digits.tr();
                            }
                            // Update the controller with cleaned value if it was different
                            if (cleanValue != value) {
                              _codeController.value = TextEditingValue(
                                text: cleanValue,
                                selection: TextSelection.collapsed(
                                  offset: cleanValue.length,
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                        20.height,
                        PasswordField(
                          label: AppStrings.newPassword.tr(),
                          hint: AppStrings.enterNewPassword.tr(),
                          controller: _newPasswordController,
                          validator: CustomValidators.validatePassword,
                        ),
                        20.height,
                        PasswordField(
                          label: AppStrings.confirmPassword.tr(),
                          hint: AppStrings.confirmNewPassword.tr(),
                          controller: _confirmPasswordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.confirmPasswordIsRequired.tr();
                            }
                            if (value != _newPasswordController.text) {
                              return AppStrings.passwordsDoNotMatch.tr();
                            }
                            return null;
                          },
                        ),
                        32.height,
                        CustomButton.filled(
                          width: double.infinity,
                          height: 56.h,
                          text: AppStrings.resetPassword.tr(),
                          isBackgroundGradient: true,
                          gradient: LinearGradient(
                            colors: const [
                              AppColors.secondaryColor,
                              AppColors.primaryColor,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          onTap: isLoading
                              ? null
                              : () => _handleSubmit(context),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
