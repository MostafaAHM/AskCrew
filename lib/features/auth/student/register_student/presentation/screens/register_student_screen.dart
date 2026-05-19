import 'package:aflam/config/routes/routes.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/extensions.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/validations/validators.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/core/widgets/checkbox/terms_checkbox.dart';
import 'package:aflam/core/widgets/fields/custom_text_field.dart';
import 'package:aflam/core/widgets/fields/password_field.dart';
import 'package:aflam/core/widgets/fields/phone_number_field.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:aflam/core/app_config/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../../core/app_config/app_strings.dart';
import '../../../../../../core/app_config/font_styles.dart';
import '../../../student_auth_flow/data/models/request/student_basic_data.dart';
import '../../../student_auth_flow/presentation/widgets/custom_stepper_indicator.dart';

class RegisterStudentScreen extends StatefulWidget {
  const RegisterStudentScreen({super.key});

  @override
  State<RegisterStudentScreen> createState() => _RegisterStudentScreenState();
}

class _RegisterStudentScreenState extends State<RegisterStudentScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBGColor,
      appBar: CustomAppBar.backAppBar(
        showLogoInBackAppBar: true,
        onBackPressed: () {
          context.go(Routes.moduleSelection);
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: CustomStepperIndicator(totalSteps: 5, currentStep: 0),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
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
                          try {
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
                        onLinkTap: () {
                          // TODO: Navigate to terms and privacy policy
                        },
                      ),
                      20.height,
                      // Register Button
                      CustomButton.filled(
                        width: double.infinity,
                        height: 56.h,
                        text: 'register'.tr(),
                        isBackgroundGradient: true,
                        gradient: const LinearGradient(
                          colors: [
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
                            style: FontStyles.textStyle14.copyWith(
                              color: AppColors.greyText,
                            ),
                            children: [
                              TextSpan(text: AppStrings.alreadyRegistered.tr()),
                              TextSpan(
                                text: AppStrings.loginHere.tr(),
                                style: FontStyles.textStyle14.copyWith(
                                  color: AppColors.secondaryColor,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
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
          ],
        ),
      ),
    );
  }

  void _handleSignup(BuildContext context) {
    if (!_acceptTerms) {
      AppMessages.showError(context, 'youMustAcceptTermsFirst'.tr());
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final basicData = StudentBasicData(
      fullname: _fullnameController.text.trim(),
      email: _emailController.text.trim(),
      mobilePhone: _phoneNumber ?? _phoneController.text.trim(),
      password: _passwordController.text,
    );

    context.go(Routes.studentOnboarding, extra: basicData);
  }
}
