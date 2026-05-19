import 'package:aflam/features/enter_prise/profile_enterprise/data/repository/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'rewards_state.dart';
import '../../data/models/reward_history_model.dart';
import '../../data/models/reward_model.dart';
import '../../data/repository/reward_history_repository.dart';
import '../../data/repository/rewards_repository.dart';

class RewardsCubit extends Cubit<RewardsState> {
  final RewardHistoryRepository _rewardHistoryRepository;
  final RewardsRepository _rewardsRepository;
  final ProfileRepository _profileRepository;

  int _currentActivityPage = 1;
  int _currentRewardsPage = 1;
  bool _isFetchingActivities = false;
  bool _isFetchingRewards = false;

  RewardsCubit(
    this._rewardHistoryRepository,
    this._rewardsRepository,
    this._profileRepository,
  ) : super(RewardsInitial());

  Future<void> loadRewardsData({bool silent = false}) async {
    if (_isFetchingActivities || _isFetchingRewards) return;
    _currentActivityPage = 1;
    _currentRewardsPage = 1;
    _isFetchingActivities = true;
    _isFetchingRewards = true;
    if (!silent) {
      emit(RewardsLoading());
    }

    try {
      // Fetch all data
      final historyResult = await _rewardHistoryRepository.getRewardHistory(
        page: _currentActivityPage,
      );
      final rewardsResult = await _rewardsRepository.getRewards(
        page: _currentRewardsPage,
      );
      final profileResult = await _profileRepository.getMyProfile();

      final List<RewardHistoryModel> activities = historyResult.fold(
        (failure) => [],
        (response) => response.results,
      );

      final hasReachedMaxActivities = historyResult.fold(
        (failure) => true,
        (response) => response.next == null,
      );

      final List<RewardModel> rewards = rewardsResult.fold(
        (failure) => [],
        (response) => response.results,
      );

      final hasReachedMaxRewards = rewardsResult.fold(
        (failure) => true,
        (response) => response.next == null,
      );

      final int totalPoints = profileResult.fold(
        (failure) => 0,
        (user) => user.points,
      );

      _isFetchingActivities = false;
      _isFetchingRewards = false;
      emit(
        RewardsLoaded(
          totalPoints: totalPoints,
          nextLevelPoints:
              (((totalPoints / 1000).floor() + 1) * 1000), // Simple mock logic
          activities: activities,
          rewards: rewards,
          hasReachedMax: hasReachedMaxActivities,
          hasReachedMaxRewards: hasReachedMaxRewards,
        ),
      );
    } catch (e) {
      _isFetchingActivities = false;
      _isFetchingRewards = false;
      emit(RewardsError(e.toString()));
    }
  }

  Future<void> loadMoreActivities() async {
    final currentState = state;
    if (currentState is! RewardsLoaded ||
        currentState.hasReachedMax ||
        _isFetchingActivities) {
      return;
    }

    _isFetchingActivities = true;
    _currentActivityPage++;

    try {
      final historyResult = await _rewardHistoryRepository.getRewardHistory(
        page: _currentActivityPage,
      );

      _isFetchingActivities = false;

      historyResult.fold(
        (failure) {
          // Keep existing state
        },
        (response) {
          emit(
            RewardsLoaded(
              totalPoints: currentState.totalPoints,
              nextLevelPoints: currentState.nextLevelPoints,
              activities: List.from(currentState.activities)
                ..addAll(response.results),
              rewards: currentState.rewards,
              hasReachedMax: response.next == null,
              hasReachedMaxRewards: currentState.hasReachedMaxRewards,
            ),
          );
        },
      );
    } catch (e) {
      _isFetchingActivities = false;
      // Keep existing state
    }
  }

  Future<void> loadMoreRewards() async {
    final currentState = state;
    if (currentState is! RewardsLoaded ||
        currentState.hasReachedMaxRewards ||
        _isFetchingRewards) {
      return;
    }

    _isFetchingRewards = true;
    _currentRewardsPage++;

    try {
      final rewardsResult = await _rewardsRepository.getRewards(
        page: _currentRewardsPage,
      );

      _isFetchingRewards = false;

      rewardsResult.fold(
        (failure) {
          // Keep existing state
        },
        (response) {
          emit(
            RewardsLoaded(
              totalPoints: currentState.totalPoints,
              nextLevelPoints: currentState.nextLevelPoints,
              activities: currentState.activities,
              rewards: List.from(currentState.rewards)
                ..addAll(response.results),
              hasReachedMax: currentState.hasReachedMax,
              hasReachedMaxRewards: response.next == null,
            ),
          );
        },
      );
    } catch (e) {
      _isFetchingRewards = false;
      // Keep existing state
    }
  }

  Future<void> redeemReward(int rewardId) async {
    final currentState = state;
    if (currentState is! RewardsLoaded) return;
    if (currentState.redeemingRewardId != null) return;

    emit(
      currentState.copyWith(
        redeemingRewardId: rewardId,
        redeemError: null,
        redeemSuccessMessage: null,
      ),
    );

    final result = await _rewardsRepository.redeemReward(rewardId);

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            redeemingRewardId: null,
            redeemError: failure.message,
          ),
        );
      },
      (success) {
        emit(
          currentState.copyWith(
            redeemingRewardId: null,
            redeemSuccessMessage: 'Reward redeemed successfully!',
          ),
        );
        loadRewardsData(silent: true);
      },
    );
  }
}
