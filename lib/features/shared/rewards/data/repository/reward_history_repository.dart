import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/repository/repository.dart';
import '../models/reward_history_model.dart';

abstract class RewardHistoryRepository extends Repository {
  Future<Either<CustomException, RewardHistoryResponse>> getRewardHistory({
    int page = 1,
    int pageSize = 10,
  });
}
