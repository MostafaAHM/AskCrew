import 'package:aflam/config/routes/routes.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/core/widgets/fields/phone_number_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:aflam/core/app_config/app_colors.dart';
import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../../data/model/forget_password_request_model.dart';
import '../cubit/forget_password_cubit.dart';

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String? _phoneNumber;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<ForgetPasswordCubit>();
    if (cubit.state is ForgetPasswordLoading) return;

    final request = ForgetPasswordRequestModel(phone: _phoneNumber);

    cubit.sendForgetPasswordOtp(request);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ForgetPasswordCubit>(),
      child: BlocListener<ForgetPasswordCubit, ForgetPasswordState>(
        listener: (context, state) {
          if (state is ForgetPasswordLoading) {
            AppMessages.showLoading(context);
          } else if (state is ForgetPasswordSuccess) {
            AppMessages.hideLoading(context);
            AppMessages.showSuccess(
              context,
              AppStrings.otpSentSuccessfully.tr(),
            );
            final phone = _phoneNumber;
            context.go(
              '${Routes.verifyOtp}?type=forgetPassword${phone != null && phone.isNotEmpty ? '&phone=${Uri.encodeComponent(phone)}' : ''}',
            );
          } else if (state is ForgetPasswordFailure) {
            AppMessages.hideLoading(context);
            AppMessages.showError(context, state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.lightBGColor,
          // appBar: AppBar(
          //   backgroundColor: Colors.transparent,
          //   elevation: 0,

          // ),
          appBar: CustomAppBar.backAppBar(
            showLogoInBackAppBar: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.lightTText,
              ),
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
                child: BlocBuilder<ForgetPasswordCubit, ForgetPasswordState>(
                  builder: (context, state) {
                    final isLoading = state is ForgetPasswordLoading;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.forgetPassword.tr(),
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.lightTText,
                          ),
                        ),
                        8.height,
                        Text(
                          AppStrings.enterPhoneToResetPassword.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.greyText,
                          ),
                        ),
                        32.height,
                        PhoneNumberField(
                          label: AppStrings.mobileNumber.tr(),
                          hint: AppStrings.enterYourPhoneNumber.tr(),
                          controller: _phoneController,
                          onChanged: (phone) {
                            if (phone.isNotEmpty) {
                              _phoneNumber = phone;
                            }
                          },
                          validator: (phone) {
                            if (phone == null) {
                              return AppStrings.phoneNumberIsRequired.tr();
                            }
                            try {
                              final phoneNumber = phone.number;
                              if (phoneNumber.isEmpty) {
                                return AppStrings.phoneNumberIsRequired.tr();
                              }
                            } catch (e) {
                              return AppStrings.phoneNumberIsRequired.tr();
                            }
                            return null;
                          },
                        ),
                        32.height,
                        CustomButton.filled(
                          width: double.infinity,
                          height: 56.h,
                          text: AppStrings.sendOtp.tr(),
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
