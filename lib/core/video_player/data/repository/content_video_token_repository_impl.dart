import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/app_config/app_urls.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/errors_exceptions_handler.dart';
import '../../../../core/repository/repository.dart';
import '../models/video_token_response_model.dart';
import 'content_video_token_repository.dart';

class ContentVideoTokenRepositoryImpl extends Repository
    implements ContentVideoTokenRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppUrls.baseApi,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.json,
    ),
  );

  @override
  Future<Either<CustomException, VideoTokenResponseModel>>
  getContentVideoToken({
    required String contentType,
    required int contentId,
  }) async {
    return await exceptionHandler(() async {
      try {
        final response = await _dio.get(
          AppUrls.getContentVideoToken(contentType, contentId),
        );
        final json = response.data;

        if (json is Map<String, dynamic>) {
          return VideoTokenResponseModel.fromJson(json);
        } else if (json is String) {
          throw CustomException(
            'Invalid response format: expected JSON, got String',
          );
        } else {
          throw CustomException('Invalid response format: ${json.runtimeType}');
        }
      } on DioException catch (e) {
        ErrorsExceptionsHandler.handleError(e);
        throw CustomException('Unknown error occurred');
      }
    });
  }
}
