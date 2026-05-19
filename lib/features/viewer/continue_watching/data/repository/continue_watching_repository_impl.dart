import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../../core/app_config/app_urls.dart';
import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/network/network_request.dart';

import '../models/continue_watching_item_model.dart';
import '../models/continue_watching_request_model.dart';
import '../repo/continue_watching_repository.dart';

class ContinueWatchingRepositoryImpl extends ContinueWatchingRepository {
  @override
  Future<Either<CustomException, List<ContinueWatchingItemModel>>>
  getContinueWatching() async {
    return exceptionHandler(() async {
      return await dioService.callApi<List<ContinueWatchingItemModel>>(
        NetworkRequest(AppUrls.getContinueWatching, method: RequestMethod.get),
        mapper: (dynamic json) {
          if (json is List) {
            return json
                .map(
                  (e) => ContinueWatchingItemModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList();
          }
          return [];
        },
      );
    });
  }

  @override
  Future<Either<CustomException, void>> updateContinueWatching({
    required UpdateContinueWatchingRequest request,
  }) async {
    return exceptionHandler(() async {
      await dioService.callApi(
        NetworkRequest(
          AppUrls.updateContinueWatching,
          method: RequestMethod.post,
          isFormData: true,
          formDataBody: FormData.fromMap(request.toFormData()),
        ),
      );
    });
  }
}
