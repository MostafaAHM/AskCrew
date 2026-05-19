import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/repository/repository.dart';
import '../model/favorite_item_model.dart';
import 'favorites_repository.dart';

class FavoritesRepositoryImpl extends Repository
    implements FavoritesRepository {
  @override
  Future<Either<CustomException, FavoritesResponseModel>> getFavorites() async {
    return await exceptionHandler(() async {
      final response = await dioService.callApi(
        NetworkRequest(AppUrls.getFavorites, method: RequestMethod.get),
        mapper: (json) =>
            FavoritesResponseModel.fromJson(json as Map<String, dynamic>),
      );
      return response;
    });
  }

  @override
  Future<Either<CustomException, void>> addFavorite({
    required String contentType,
    required int objectId,
  }) async {
    return await exceptionHandler(() async {
      final formData = FormData.fromMap({
        'content_type': contentType,
        'object_id': objectId,
      });

      await dioService.callApi(
        NetworkRequest(
          AppUrls.addFavorite,
          method: RequestMethod.post,
          formDataBody: formData,
          isFormData: true,
        ),
      );
    });
  }

  @override
  Future<Either<CustomException, void>> removeFavorite({
    required String contentType,
    required int objectId,
  }) async {
    return await exceptionHandler(() async {
      // Body for DELETE as form-data
      final formData = FormData.fromMap({
        'content_type': contentType,
        'object_id': objectId,
      });

      await dioService.callApi(
        NetworkRequest(
          AppUrls.removeFavorite,
          method: RequestMethod.delete,
          formDataBody: formData,
          isFormData: true,
        ),
      );
    });
  }
}
