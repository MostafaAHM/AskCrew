part of 'watermark_payment_cubit.dart';

@immutable
abstract class WatermarkPaymentState {}

class WatermarkPaymentInitial extends WatermarkPaymentState {}

class WatermarkPaymentLoading extends WatermarkPaymentState {}

class WatermarkPaymentChargeCreated extends WatermarkPaymentState {
  final String transactionUrl;
  WatermarkPaymentChargeCreated(this.transactionUrl);
}

class WatermarkPaymentVerifying extends WatermarkPaymentState {}

class WatermarkPaymentVerified extends WatermarkPaymentState {}

class WatermarkPaymentFailure extends WatermarkPaymentState {
  final String message;
  WatermarkPaymentFailure(this.message);
}
