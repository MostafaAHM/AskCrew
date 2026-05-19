import 'dart:async';
import 'package:aflam/core/app_config/app_strings.dart';

import 'package:aflam/config/routes/routes.dart';
import 'package:aflam/core/app_config/app_icons.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/extensions.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/app_config/app_colors.dart';
import '../../../../core/app_config/font_styles.dart';
import '../../../../core/widgets/otp/otp_field.dart';
import '../data/model/resend_sms_request_model.dart';
import '../data/model/send_otp_request_model.dart';
import 'cubit/validate_otp_code/verify_otp_cubit.dart';

enum VerifyOtpType { forgetPassword, register, accountVerification }

class VerifyOtpScreen extends StatefulWidget {
  final VerifyOtpType type;
  final String? phone;
  final String? email;

  const VerifyOtpScreen({
    super.key,
    this.type = VerifyOtpType.forgetPassword,
    this.phone,
    this.email,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  late final TextEditingController otpController;
  late final FocusNode otpFocusNode;
  String otp = '';
  Timer? _resendTimer;
  int _resendCountdown = 0; // Countdown in seconds (3 minutes = 180 seconds)

  @override
  void initState() {
    super.initState();
    otpController = TextEditingController();
    otpFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    otpController.dispose();
    otpFocusNode.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    if (_resendTimer != null && _resendTimer!.isActive) {
      return; // Timer already running
    }

    _resendTimer?.cancel();
    _resendCountdown = 180; // 3 minutes = 180 seconds

    // Immediately update UI to show the initial countdown
    if (mounted) {
      setState(() {});
    }

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_resendCountdown > 0) {
          setState(() {
            _resendCountdown--;
          });
        } else {
          timer.cancel();
          _resendTimer = null;
          setState(() {
            _resendCountdown = 0;
          });
        }
      } else {
        timer.cancel();
        _resendTimer = null;
      }
    });
  }

  String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getTitle() {
    switch (widget.type) {
      case VerifyOtpType.register:
        return AppStrings.checkYourPhone.tr();
      case VerifyOtpType.accountVerification:
        return AppStrings.verifyYourAccount.tr();
      case VerifyOtpType.forgetPassword:
        return AppStrings.checkYourPhone.tr();
    }
  }

  String _getSubtitle() {
    switch (widget.type) {
      case VerifyOtpType.register:
        return AppStrings.registerOtpSubtitle.tr();
      case VerifyOtpType.accountVerification:
        return AppStrings.accountVerificationOtpSubtitle.tr();
      case VerifyOtpType.forgetPassword:
        return AppStrings.forgetPasswordOtpSubtitle.tr();
    }
  }

  ResendSmsRequestModel _buildVerifyOtpOptions() {
    return ResendSmsRequestModel(sms: otp);
  }

  void _onVerifyPressed(BuildContext context) {
    if (otp.isEmpty || otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.authOtpEnterFullCode.tr())),
      );
      return;
    }

    final options = _buildVerifyOtpOptions();
    context.read<VerifyOtpCubit>().verifyOTP(options);
  }

  void _onResendPressed(BuildContext context) {
    final cubit = context.read<VerifyOtpCubit>();
    if (cubit.state is VerifyOtpLoading || _resendCountdown > 0) return;

    final request = SendOtpRequestModel(
      phone: widget.phone,
      email: widget.email,
    );

    cubit.resendOTP(request);
    // Timer will start when ResendSendVerifyOtpInitial state is received
  }

  // Removed automatic OTP sending - OTP should only be sent when user explicitly requests it
  // (either from signup screen or when pressing resend button)

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<VerifyOtpCubit>();
        cubit.setOtpType(widget.type);
        return cubit;
      },
      child: BlocConsumer<VerifyOtpCubit, VerifyOtpState>(
        listener: (context, state) {
          if (state is VerifyOtpError) {
            AppMessages.showError(context, state.error);
          }

          if (state is RegisterVerifyOtpSuccess) {
            AppMessages.showSuccess(
              context,
              AppStrings.otpVerifiedSuccessfully.tr(),
            );
            context.go(Routes.login);
          }

          if (state is ForgetPasswordVerifyOtpSuccess) {
            AppMessages.showSuccess(
              context,
              AppStrings.otpVerifiedSuccessfully.tr(),
            );
            // Navigate to reset password screen with the OTP code
            // Clean the OTP code: remove any non-digit characters and ensure it's exactly 6 digits
            final otpCode = otp.trim().replaceAll(RegExp(r'[^\d]'), '');
            if (otpCode.isNotEmpty && otpCode.length == 6) {
              context.go(
                '${Routes.resetPassword}?code=${Uri.encodeComponent(otpCode)}',
              );
            } else {
              AppMessages.showError(context, AppStrings.invalidOtpFormat.tr());
            }
          }

          if (state is ResendSendVerifyOtpInitial) {
            AppMessages.showSuccess(
              context,
              AppStrings.otpSentSuccessfully.tr(),
            );
            if (mounted) {
              _startResendTimer();
            }
          }

          if (state is SendVerifyOtpInitial) {
            // OTP sent - timer will start when user presses resend
          }
        },
        builder: (context, state) {
          // No automatic OTP sending - user must press resend button to send OTP
          // Timer will start only when user explicitly requests resend

          final isLoading = state is VerifyOtpLoading;

          return Scaffold(
            backgroundColor: const Color(0xFFFDFBF7),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    24.height,
                    Center(
                      child: Image.asset(
                        AppIcons.logoPNG,
                        width: 100.w,
                        height: 100.h,
                      ),
                    ),
                    32.height,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _getTitle(),
                        style: FontStyles.textStyle24.copyWith(
                          fontSize: 20.sp,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                    8.height,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _getSubtitle(),
                        style: FontStyles.textStyle14.copyWith(
                          color: AppColors.darkBGColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                    40.height,
                    Center(
                      child: CustomOTPField(
                        focusNode: otpFocusNode,
                        controller: otpController,
                        onCompleted: (value) {
                          otp = value ?? '';
                        },
                        onChanged: (value) {
                          otp = value ?? '';
                        },
                      ),
                    ),
                    40.height,
                    CustomButton(
                      text: AppStrings.verifyCode.tr(),
                      isBackgroundGradient: true,
                      onTap: isLoading ? null : () => _onVerifyPressed(context),
                    ),
                    12.height,
                    Center(
                      child: _resendCountdown > 0
                          ? RichText(
                              text: TextSpan(
                                style: FontStyles.textStyle12.copyWith(
                                  color: AppColors.darkBGColor,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        widget.type ==
                                            VerifyOtpType.forgetPassword
                                        ? "${AppStrings.haventGotEmailYet.tr()} "
                                        : "${AppStrings.haventGotCodeYet.tr()} ",
                                  ),
                                  TextSpan(
                                    text: AppStrings.resendIn.tr(
                                      namedArgs: {
                                        'time': _formatCountdown(
                                          _resendCountdown,
                                        ),
                                      },
                                    ),
                                    style: FontStyles.textStyle12.copyWith(
                                      color: AppColors.darkBGColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () => _onResendPressed(context),
                              child: RichText(
                                text: TextSpan(
                                  style: FontStyles.textStyle12.copyWith(
                                    color: AppColors.darkBGColor,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          widget.type ==
                                              VerifyOtpType.forgetPassword
                                          ? "${AppStrings.haventGotEmailYet.tr()} "
                                          : "${AppStrings.haventGotCodeYet.tr()} ",
                                    ),
                                    TextSpan(
                                      text:
                                          widget.type ==
                                              VerifyOtpType.forgetPassword
                                          ? AppStrings.resendEmail.tr()
                                          : AppStrings.resendCode.tr(),
                                      style: FontStyles.textStyle12.copyWith(
                                        color: AppColors.secondaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    16.height,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
