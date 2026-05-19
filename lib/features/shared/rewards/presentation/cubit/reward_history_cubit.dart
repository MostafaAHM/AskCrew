import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/reward_history_model.dart';
import '../../data/repository/reward_history_repository.dart';

abstract class RewardHistoryState {}

class RewardHistoryInitial extends RewardHistoryState {}

class RewardHistoryLoading extends RewardHistoryState {}

class RewardHistoryLoaded extends RewardHistoryState {
  final List<RewardHistoryModel> history;
  final bool hasReachedMax;

  RewardHistoryLoaded({required this.history, this.hasReachedMax = false});
}

class RewardHistoryError extends RewardHistoryState {
  final String message;
  RewardHistoryError(this.message);
}

class RewardHistoryCubit extends Cubit<RewardHistoryState> {
  final RewardHistoryRepository _repository;
  int _currentPage = 1;
  bool _isFetching = false;

  RewardHistoryCubit(this._repository) : super(RewardHistoryInitial());

  Future<void> getHistory() async {
    if (_isFetching) return;
    _currentPage = 1;
    _isFetching = true;
    emit(RewardHistoryLoading());
    final result = await _repository.getRewardHistory(page: _currentPage);
    _isFetching = false;
    result.fold((failure) => emit(RewardHistoryError(failure.message)), (
      response,
    ) {
      final hasReachedMax = response.next == null;
      emit(
        RewardHistoryLoaded(
          history: response.results,
          hasReachedMax: hasReachedMax,
        ),
      );
    });
  }

  Future<void> loadMoreHistory() async {
    final currentState = state;
    if (currentState is! RewardHistoryLoaded ||
        currentState.hasReachedMax ||
        _isFetching) {
      return;
    }

    _isFetching = true;
    _currentPage++;
    final result = await _repository.getRewardHistory(page: _currentPage);
    _isFetching = false;

    result.fold(
      (failure) {
        // We don't want to emit error state if pagination fails, maybe just keep existing data
        // or emit a specific pagination error if needed. For now just stop fetching.
      },
      (response) {
        final hasReachedMax = response.next == null;
        emit(
          RewardHistoryLoaded(
            history: List.from(currentState.history)..addAll(response.results),
            hasReachedMax: hasReachedMax,
          ),
        );
      },
    );
  }
}
