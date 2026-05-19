part of 'payment_cubit.dart';

@immutable
sealed class PaymentState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentFailure extends PaymentState {
  final String message;
  PaymentFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Initialization
class PaymentInitializationSuccess extends PaymentState {
  final bool result;
  PaymentInitializationSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

// Payment
class PaymentTransactionSuccess extends PaymentState {
  final dynamic response;
  PaymentTransactionSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

// Save Status
class PaymentSaveStatusSuccess extends PaymentState {
  // final BaseResponseModel response;
  PaymentSaveStatusSuccess();

  @override
  List<Object?> get props => [];
}

// Subscription
class PaymentSubscriptionSuccess extends PaymentState {
  final SubscriptionResponseModel response;
  PaymentSubscriptionSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

// Content Payment
class PaymentContentSuccess extends PaymentState {
  final TapPaymentChargeResponse response;
  PaymentContentSuccess(this.response);

  @override
  List<Object?> get props => [response];
}