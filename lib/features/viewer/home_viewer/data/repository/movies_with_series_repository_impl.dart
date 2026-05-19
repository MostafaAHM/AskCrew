import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/repository/repository.dart';
import '../model/movies_with_series_model.dart';
import 'movies_with_series_repository.dart';

class MoviesWithSeriesRepositoryImpl extends Repository
    implements MoviesWithSeriesRepository {
  @override
  Future<Either<CustomException, MoviesWithSeriesResponseModel>>
  getMoviesWithSeries({int? categoryId}) async {
    return await exceptionHandler(() async {
      // Build query parameters for category filtering
      // We keep sending parameter in case backend supports it
      final Map<String, dynamic>? queryParams;
      if (categoryId != null) {
        queryParams = {'category_id': categoryId};
      } else {
        queryParams = null;
      }

      final response = await dioService.callApi(
        NetworkRequest(
          AppUrls.getMoviesWithSeries,
          method: RequestMethod.get,
          requestWithOutToken: false,
          queryParameters: queryParams,
        ),
        mapper: (json) {
          if (json is Map<String, dynamic>) {
            return MoviesWithSeriesResponseModel.fromJson(json);
          } else if (json is List) {
            // If API returns a list directly, wrap it in the response model
            return MoviesWithSeriesResponseModel(
              count: json.length,
              next: null,
              previous: null,
              results: json
                  .map(
                    (e) =>
                        MovieOrSeriesItem.fromJson(e as Map<String, dynamic>),
                  )
                  .toList(),
            );
          } else if (json is String) {
            throw CustomException(
              'Invalid response format: expected JSON, got String',
            );
          } else {
            throw CustomException(
              'Invalid response format: ${json.runtimeType}',
            );
          }
        },
      );

      // Manual client-side filtering as fallback
      // This ensures filtering works even if API ignores the parameter
      if (categoryId != null) {
        final filteredResults = response.results.where((item) {
          final itemCategoryId = item.categoryId ?? item.category?.id;
          return itemCategoryId == categoryId;
        }).toList();

        return MoviesWithSeriesResponseModel(
          count: filteredResults.length,
          next: response.next,
          previous: response.previous,
          results: filteredResults,
        );
      }

      return response;
    });
  }

  @override
  Future<Either<CustomException, void>> rateContent({
    required String contentType,
    required String objectId,
    required int rating,
  }) async {
    return await exceptionHandler(() async {
      await dioService.callApi(
        NetworkRequest(
          AppUrls.rateContent,
          method: RequestMethod.post,
          isFormData: true,
          formDataBody: FormData.fromMap({
            'content_type': contentType,
            'object_id': objectId,
            'rating': rating,
          }),
        ),
      );
    });
  }

  @override
  Future<Either<CustomException, MovieOrSeriesItem>> getContentDetails({
    required String contentType,
    required int id,
  }) async {
    return await exceptionHandler(() async {
      String endpoint = '';
      if (contentType == 'series') {
        endpoint = '${AppUrls.baseApi}/v1/content/series/$id/';
      } else if (contentType == 'movie') {
        endpoint = '${AppUrls.baseApi}/v1/content/movies/$id/';
      } else if (contentType == 'advertise') {
        endpoint = '${AppUrls.baseApi}/v1/content/advertise/$id/';
      } else if (contentType == 'season') {
        endpoint = '${AppUrls.baseApi}/v1/content/seasons/$id/';
      } else if (contentType == 'episode') {
        endpoint = '${AppUrls.baseApi}/v1/content/episodes/$id/';
      } else {
        endpoint = '${AppUrls.baseApi}/v1/content/$contentType/$id/';
      }

      final response = await dioService.callApi(
        NetworkRequest(endpoint, method: RequestMethod.get),
        mapper: (json) {
          return MovieOrSeriesItem.fromJson(json as Map<String, dynamic>);
        },
      );

      return response;
    });
  }
}
