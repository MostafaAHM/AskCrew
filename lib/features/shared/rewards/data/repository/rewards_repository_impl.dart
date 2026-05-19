import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:aflam/core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../models/reward_model.dart';
import 'rewards_repository.dart';

class RewardsRepositoryImpl extends RewardsRepository {
  @override
  Future<Either<CustomException, RewardsResponse>> getRewards({
    int page = 1,
    int pageSize = 10,
  }) async {
    return exceptionHandler(() async {
      final response = await dioService.callApi(
        NetworkRequest(
          AppUrls.rewardsEndpoint,
          method: RequestMethod.get,
          queryParameters: {'page': page, 'page_size': pageSize},
        ),
        mapper: (json) => RewardsResponse.fromJson(json),
      );
      return response;
    });
  }

  @override
  Future<Either<CustomException, void>> redeemReward(int rewardId) async {
    return exceptionHandler(() async {
      await dioService.callApi(
        NetworkRequest(
          AppUrls.redeemReward,
          method: RequestMethod.post,
          formDataBody: FormData.fromMap({'reward_id': rewardId}),
          isFormData: true,
        ),
      );
    });
  }
}
