import 'package:dartz/dartz.dart';
import 'package:aflam/core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../models/reward_history_model.dart';
import 'reward_history_repository.dart';

class RewardHistoryRepositoryImpl extends RewardHistoryRepository {
  @override
  Future<Either<CustomException, RewardHistoryResponse>> getRewardHistory({
    int page = 1,
    int pageSize = 10,
  }) async {
    return exceptionHandler(() async {
      final response = await dioService.callApi(
        NetworkRequest(
          AppUrls.rewardCodesEndpoint,
          method: RequestMethod.get,
          queryParameters: {'page': page, 'page_size': pageSize},
        ),
        mapper: (json) => RewardHistoryResponse.fromJson(json),
      );
      return response;
    });
  }
}
