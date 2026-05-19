part of 'swap_account_cubit.dart';

abstract class SwapAccountState extends Equatable {
  const SwapAccountState();

  @override
  List<Object?> get props => [];
}

class SwapAccountInitial extends SwapAccountState {}

class SwapAccountLoading extends SwapAccountState {}

class SwapAccountSuccess extends SwapAccountState {
  final BaseResponseModel response;

  const SwapAccountSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class SwapAccountError extends SwapAccountState {
  final String message;
  final int? code;

  const SwapAccountError(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}
