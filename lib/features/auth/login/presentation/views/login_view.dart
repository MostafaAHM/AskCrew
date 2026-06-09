import 'package:aflam/config/routes/routes.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/validations/validators.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/core/widgets/buttons/social_login_button.dart';

import 'package:aflam/core/widgets/fields/custom_text_field.dart';
import 'package:aflam/core/widgets/fields/password_field.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aflam/core/app_config/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:aflam/core/helpers/user_helper.dart';

import '../../data/model/login_request_model.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import 'package:aflam/features/shared/notifications/presentation/cubit/notifications_cubit.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  String? _category;

  @override
  void initState() {
    super.initState();
    // Get category from query parameters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = GoRouterState.of(context);
      setState(() {
        _category = state.uri.queryParameters['category'];
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) {
    final cubit = context.read<LoginCubit>();
    if (cubit.state is LoginLoading) return;

    if (!_formKey.currentState!.validate()) return;

    final request = LoginRequestModel(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    cubit.login(request);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginCubit>(),
      child: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginLoading) {
            AppMessages.showLoading(context);
          } else if (state is LoginSuccess) {
            AppMessages.hideLoading(context);
            AppMessages.showSuccess(
              context,
              AppStrings.loggedInSuccessfully.tr(),
            );

            UserHelper.setUser(state.response.user);
            getIt<NotificationsCubit>().init();

            final user = state.response.user;
            final userType = user.type;

            if (userType == 'viewer') {
              context.go(Routes.viewerHome);
            } else if (userType == 'enterprise') {
              context.go(Routes.enterpriseHome);
            } else if (userType == 'student') {
              context.go(Routes.studentHome);
            } else {
              context.go(Routes.viewerHome);
            }
          } else if (state is LoginFailure) {
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
                    child: BlocBuilder<LoginCubit, LoginState>(
                      builder: (context, state) {
                        final isLoading = state is LoginLoading;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.loginTitle.tr(),
                              style: TextStyle(
                                fontSize: 30.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.lightTText,
                              ),
                            ),
                            6.height,
                            Text(
                              AppStrings.loginSubtitle.tr(),
                              style: TextStyle(
                                fontSize: 17.sp,
                                color: AppColors.greyText,
                              ),
                            ),
                            16.height,
                            CustomTextField(
                              label: AppStrings.email.tr(),
                              hint: AppStrings.enterYourEmail.tr(),
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: CustomValidators.validateEmail,
                            ),
                            12.height,
                            PasswordField(
                              label: AppStrings.password.tr(),
                              hint: AppStrings.interYourPassword.tr(),
                              controller: _passwordController,
                              validator: CustomValidators.validatePassword,
                            ),
                            10.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // ==== Remember me (custom checkbox + text) ====
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      _rememberMe = !_rememberMe;
                                    });
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 18.w,
                                        height: 18.w,
                                        decoration: BoxDecoration(
                                          color: _rememberMe
                                              ? AppColors.secondaryColor
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            3.r,
                                          ),
                                          border: Border.all(
                                            color: AppColors.secondaryColor,
                                            width: 1.6,
                                          ),
                                        ),
                                        child: _rememberMe
                                            ? Icon(
                                                Icons.check,
                                                size: 14.sp,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),

                                      8.width,

                                      Text(
                                        AppStrings.rememberMe.tr(),
                                        style: TextStyle(
                                          fontSize: 17.sp,
                                          color: AppColors.lightMainText
                                              .withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () =>
                                      context.go(Routes.forgetPassword),
                                  child: Text(
                                    AppStrings.forgetPassword.tr(),
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      color: AppColors.lightMainText
                                          .withOpacity(0.9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            30.height,
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                  ),
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
                            // Google Login Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SocialLoginButton(
                                  type: SocialType.google,
                                  onTap: isLoading
                                      ? () {}
                                      : () {
                                          context
                                              .read<LoginCubit>()
                                              .loginWithGoogle();
                                        },
                                ),
                              ],
                            ),
                            18.height,
                            CustomButton.filled(
                              width: double.infinity,
                              height: 56.h,
                              text: AppStrings.login.tr(),
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
                                  : () => _handleLogin(context),
                            ),
                            16.height,
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: AppColors.greyText,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: AppStrings.dontHaveAnAccount.tr(),
                                    ),
                                    TextSpan(
                                      text: AppStrings.signup.tr(),
                                      style: TextStyle(
                                        color: AppColors.secondaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          if (_category == 'enterprise') {
                                            context.go(
                                              Routes.registerEnterprise,
                                            );
                                          } else if (_category == 'student') {
                                            context.go(Routes.registerStudent);
                                          } else {
                                            context.go(Routes.signup);
                                          }
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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
