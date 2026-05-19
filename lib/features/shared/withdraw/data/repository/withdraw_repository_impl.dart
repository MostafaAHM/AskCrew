import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/repository/repository.dart';
import '../model/collect_request_model.dart';
import 'withdraw_repository.dart';

class WithdrawRepositoryImpl extends Repository implements WithdrawRepository {
  @override
  Future<Either<CustomException, CollectRequestModel>> createCollectRequest({
    required int amount,
    required String source,
  }) async {
    return exceptionHandler(() async {
      final formData = FormData.fromMap({
        'amount': amount,
        'source': source,
      });

      final response = await dioService.callApi(
        NetworkRequest(
          AppUrls.collectRequests,
          method: RequestMethod.post,
          isFormData: true,
          formDataBody: formData,
        ),
        mapper: (json) {
          final map = json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
          return CollectRequestModel.fromJson(map);
        },
      );
      return response;
    });
  }

  @override
  Future<Either<CustomException, CollectRequestsResponse>> getCollectRequests() async {
    return exceptionHandler(() async {
      final response = await dioService.callApi(
        NetworkRequest(AppUrls.collectRequests, method: RequestMethod.get),
        mapper: (json) {
          final map = json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
          return CollectRequestsResponse.fromJson(map);
        },
      );
      return response;
    });
  }
}
