part of 'verify_otp_cubit.dart';

sealed class VerifyOtpState extends Equatable {
  const VerifyOtpState();

  @override
  List<Object> get props => [];
}

final class VerifyOtpInitial extends VerifyOtpState {}

final class SendVerifyOtpInitial extends VerifyOtpState {
  final BaseResponseModel response;
  const SendVerifyOtpInitial({required this.response});
}

final class ResendSendVerifyOtpInitial extends VerifyOtpState {}

final class VerifyOtpLoading extends VerifyOtpState {}

final class ForgetPasswordVerifyOtpSuccess extends VerifyOtpState {
  final BaseResponseModel response;
  const ForgetPasswordVerifyOtpSuccess({required this.response});
}

final class RegisterVerifyOtpSuccess extends VerifyOtpState {
  final BaseResponseModel response;
  const RegisterVerifyOtpSuccess({required this.response});
}

final class VerifyOtpError extends VerifyOtpState {
  final String error;

  const VerifyOtpError(this.error);

  @override
  List<Object> get props => [error];
}
