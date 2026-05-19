import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/repository/repository.dart';
import '../models/reward_model.dart';

abstract class RewardsRepository extends Repository {
  Future<Either<CustomException, RewardsResponse>> getRewards({
    int page = 1,
    int pageSize = 10,
  });

  Future<Either<CustomException, void>> redeemReward(int rewardId);
}
