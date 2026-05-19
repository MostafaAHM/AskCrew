import '../../data/model/collect_request_model.dart';

abstract class WithdrawState {}

class WithdrawInitial extends WithdrawState {}

class WithdrawLoading extends WithdrawState {}

class WithdrawSuccess extends WithdrawState {
  final CollectRequestModel request;
  WithdrawSuccess(this.request);
}

class WithdrawError extends WithdrawState {
  final String message;
  WithdrawError(this.message);
}

// ─── History states ──────────────────────────────────────────────────────────
class WithdrawHistoryLoading extends WithdrawState {}

class WithdrawHistoryLoaded extends WithdrawState {
  final List<CollectRequestModel> requests;
  WithdrawHistoryLoaded(this.requests);
}

class WithdrawHistoryError extends WithdrawState {
  final String message;
  WithdrawHistoryError(this.message);
}
