import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../core/models/base_response_model.dart';
import '../../../data/model/resend_sms_request_model.dart';
import '../../../data/model/send_otp_request_model.dart';
import '../../../data/repository/verify_otp_repository.dart';
import '../../verify_otp_screen.dart';

part 'verify_otp_state.dart';

class VerifyOtpCubit extends Cubit<VerifyOtpState> {
  VerifyOtpRepository repository;
  VerifyOtpType? otpType;

  VerifyOtpCubit(this.repository) : super(VerifyOtpInitial());

  void setOtpType(VerifyOtpType type) {
    otpType = type;
  }

  Future<void> verifyOTP(ResendSmsRequestModel options) async {
    emit(VerifyOtpLoading());

    final result = await repository.verifyOTP(options: options);
    result.fold(
      (failure) {
        emit(VerifyOtpError(failure.message));
      },
      (response) {
        if (otpType == VerifyOtpType.forgetPassword) {
          emit(ForgetPasswordVerifyOtpSuccess(response: response));
        } else {
          emit(RegisterVerifyOtpSuccess(response: response));
        }
      },
    );
  }

  Future<void> resendOTP(SendOtpRequestModel options) async {
    emit(VerifyOtpLoading());

    final result = await repository.resendOtp(options: options);
    result.fold(
      (failure) {
        emit(VerifyOtpError(failure.message));
      },
      (response) {
        emit(ResendSendVerifyOtpInitial());
      },
    );
  }

  Future<void> sendOtp(SendOtpRequestModel options) async {
    emit(VerifyOtpLoading());

    final result = await repository.sendOtp(options: options);
    result.fold(
      (failure) {
        emit(VerifyOtpError(failure.message));
      },
      (response) {
        emit(SendVerifyOtpInitial(response: response));
      },
    );
  }
}
