import 'package:equatable/equatable.dart';
import '../../data/models/reward_history_model.dart';
import '../../data/models/reward_model.dart';

abstract class RewardsState extends Equatable {
  const RewardsState();

  @override
  List<Object?> get props => [];
}

class RewardsInitial extends RewardsState {}

class RewardsLoading extends RewardsState {}

class RewardsLoaded extends RewardsState {
  final int totalPoints;
  final int nextLevelPoints;
  final List<RewardHistoryModel> activities;
  final List<RewardModel> rewards;
  final bool hasReachedMax; // For activities pagination
  final bool hasReachedMaxRewards; // For rewards pagination

  const RewardsLoaded({
    required this.totalPoints,
    required this.nextLevelPoints,
    required this.activities,
    required this.rewards,
    this.hasReachedMax = false,
    this.hasReachedMaxRewards = false,
    this.redeemingRewardId,
    this.redeemSuccessMessage,
    this.redeemError,
  });

  final int? redeemingRewardId;
  final String? redeemSuccessMessage;
  final String? redeemError;

  RewardsLoaded copyWith({
    int? totalPoints,
    int? nextLevelPoints,
    List<RewardHistoryModel>? activities,
    List<RewardModel>? rewards,
    bool? hasReachedMax,
    bool? hasReachedMaxRewards,
    int? redeemingRewardId,
    String? redeemSuccessMessage,
    String? redeemError,
  }) {
    return RewardsLoaded(
      totalPoints: totalPoints ?? this.totalPoints,
      nextLevelPoints: nextLevelPoints ?? this.nextLevelPoints,
      activities: activities ?? this.activities,
      rewards: rewards ?? this.rewards,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      hasReachedMaxRewards: hasReachedMaxRewards ?? this.hasReachedMaxRewards,
      redeemingRewardId: redeemingRewardId ?? this.redeemingRewardId,
      redeemSuccessMessage: redeemSuccessMessage ?? this.redeemSuccessMessage,
      redeemError: redeemError ?? this.redeemError,
    );
  }

  @override
  List<Object?> get props => [
    totalPoints,
    nextLevelPoints,
    activities,
    rewards,
    hasReachedMax,
    hasReachedMaxRewards,
    redeemingRewardId,
    redeemSuccessMessage,
    redeemError,
  ];
}

class RewardsError extends RewardsState {
  final String message;

  const RewardsError(this.message);

  @override
  List<Object?> get props => [message];
}
