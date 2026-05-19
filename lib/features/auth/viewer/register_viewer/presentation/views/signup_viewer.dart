import 'package:aflam/config/routes/routes.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/extensions.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/validations/validators.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/core/widgets/buttons/social_login_button.dart';
import 'package:aflam/core/widgets/checkbox/terms_checkbox.dart';
import 'package:aflam/core/widgets/fields/custom_text_field.dart';
import 'package:aflam/core/widgets/fields/password_field.dart';
import 'package:aflam/core/widgets/fields/phone_number_field.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:aflam/core/app_config/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../../core/di/service_locator.dart';
import '../../data/model/signup_request_model.dart';
import '../cubit/signup_cubit.dart';
import '../cubit/signup_state.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _acceptTerms = true;
  String? _phoneNumber;

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignup(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      AppMessages.showError(context, 'pleaseAcceptTerms'.tr());
      return;
    }

    final request = SignupRequestModel(
      fullname: _fullnameController.text.trim(),
      email: _emailController.text.trim(),
      mobilePhone: _phoneNumber ?? '',
      password: _passwordController.text,
    );

    context.read<SignupCubit>().signup(request);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SignupCubit>(),
      child: BlocListener<SignupCubit, SignupState>(
        listener: (context, state) {
          if (state is SignupLoading) {
            AppMessages.showLoading(context);
          } else if (state is SignupSuccess) {
            AppMessages.hideLoading(context);
            AppMessages.showSuccess(context, 'accountCreatedSuccessfully'.tr());
            if (state.isGoogleSignup) {
              context.go(Routes.viewerHome);
            } else {
              context.go(Routes.login);
            }
          } else if (state is SignupFailure) {
            AppMessages.hideLoading(context);
            AppMessages.showError(context, state.message);
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: AppColors.lightBGColor,
              appBar: CustomAppBar.backAppBar(
                showLogoInBackAppBar: true,
                onBackPressed: () {
                  context.go(Routes.moduleSelection);
                },
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          'createYourAccount'.tr(),
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.lightTText,
                          ),
                        ),
                        6.height,
                        Text(
                          'joinUsInJustAFewSteps'.tr(),
                          style: TextStyle(
                            fontSize: 17.sp,
                            color: AppColors.greyText,
                          ),
                        ),
                        20.height,
                        // Full Name Field
                        CustomTextField(
                          label: 'fullname'.tr(),
                          hint: 'enterYourFullName'.tr(),
                          controller: _fullnameController,
                          validator: CustomValidators.validateEmpty,
                        ),
                        12.height,
                        // Email Field
                        CustomTextField(
                          label: 'emailAddress'.tr(),
                          hint: 'enterYourEmailAddress'.tr(),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: CustomValidators.validateEmail,
                        ),
                        12.height,
                        // Phone Number Field
                        PhoneNumberField(
                          label: 'mobileNumber'.tr(),
                          hint: 'enterYourPhoneNumber'.tr(),
                          controller: _phoneController,
                          onChanged: (phone) {
                            if (phone.isNotEmpty) {
                              _phoneNumber = phone;
                            }
                          },
                          validator: (phone) {
                            if (phone == null) {
                              return 'phoneNumberIsRequired'.tr();
                            }
                            // Check if phone has a number property
                            try {
                              // PhoneNumber object has a number property
                              final phoneNumber = phone.number;
                              if (phoneNumber.isEmpty) {
                                return 'phoneNumberIsRequired'.tr();
                              }
                            } catch (e) {
                              return 'phoneNumberIsRequired'.tr();
                            }
                            return null;
                          },
                        ),
                        12.height,
                        // Password Field
                        PasswordField(
                          label: 'password'.tr(),
                          hint: 'interYourPassword'.tr(),
                          controller: _passwordController,
                          validator: CustomValidators.validatePassword,
                        ),
                        12.height,
                        // Terms Checkbox
                        TermsCheckbox(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value;
                            });
                          },
                          text: 'iAcceptThe'.tr(),
                          linkText: 'termsAndPrivacyPolicy'.tr(),
                          onLinkTap: () {},
                        ),
                        20.height,
                        // Divider with "or"
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppColors.borderColor,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                'or'.tr(),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: AppColors.greyText,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppColors.borderColor,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        18.height,
                        // Social Login Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialLoginButton(
                              type: SocialType.google,
                              onTap: () {
                                // Validate phone number before Google sign-in
                                if (_phoneNumber == null ||
                                    _phoneNumber!.isEmpty) {
                                  AppMessages.showError(
                                    context,
                                    'phoneNumberIsRequired'.tr(),
                                  );
                                  return;
                                }

                                // Trigger Google Sign-In with phone number
                                context.read<SignupCubit>().signupWithGoogle(
                                  phone: _phoneNumber!,
                                );
                              },
                            ),
                            // 16.width,
                            // SocialLoginButton(
                            //   type: SocialType.facebook,
                            //   onTap: () {
                            //     context
                            //         .read<SignupCubit>()
                            //         .signupWithFacebook();
                            //   },
                            // ),
                            // 16.width,
                            // SocialLoginButton(
                            //   type: SocialType.apple,
                            //   onTap: () {
                            //     context.read<SignupCubit>().signupWithApple();
                            //   },
                            // ),
                          ],
                        ),
                        12.height,
                        // Register Button
                        CustomButton.filled(
                          width: double.infinity,
                          height: 56.h,
                          text: 'register'.tr(),
                          isBackgroundGradient: true,
                          gradient: LinearGradient(
                            colors: const [
                              AppColors.secondaryColor,
                              AppColors.primaryColor,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          onTap: () => _handleSignup(context),
                        ),
                        16.height,
                        // Login Link
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: AppColors.greyText,
                              ),
                              children: [
                                TextSpan(text: 'alreadyRegistered'.tr()),
                                TextSpan(
                                  text: 'loginHere'.tr(),
                                  style: TextStyle(
                                    color: AppColors.secondaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      context.go(Routes.login);
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
