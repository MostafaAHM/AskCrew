import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/withdraw_repository.dart';
import 'withdraw_state.dart';

class WithdrawCubit extends Cubit<WithdrawState> {
  final WithdrawRepository _repository;

  WithdrawCubit(this._repository) : super(WithdrawInitial());

  Future<void> submitWithdraw({
    required int amount,
    required String source,
  }) async {
    emit(WithdrawLoading());
    final result = await _repository.createCollectRequest(
      amount: amount,
      source: source,
    );
    result.fold(
      (error) => emit(WithdrawError(error.message)),
      (request) => emit(WithdrawSuccess(request)),
    );
  }

  Future<void> loadHistory() async {
    emit(WithdrawHistoryLoading());
    final result = await _repository.getCollectRequests();
    result.fold(
      (error) => emit(WithdrawHistoryError(error.message)),
      (response) => emit(WithdrawHistoryLoaded(response.results)),
    );
  }
}
