import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/app_config/app_urls.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/errors_exceptions_handler.dart';
import '../../../../core/repository/repository.dart';
import '../../../../core/network/network_request.dart';
import '../models/video_token_response_model.dart';
import 'video_player_repository.dart';

class VideoPlayerRepositoryImpl extends Repository
    implements VideoPlayerRepository {

  @override
  Future<Either<CustomException, VideoTokenResponseModel>> getVideoToken({
    required String contentType,
    required int contentId,
    bool playTrailer = false,
  }) async {
    return await exceptionHandler(() async {
      try {
        // Determine which URL to use based on playTrailer
        String url;
        if (playTrailer) {
          url = AppUrls.getTrailerToken(contentType, contentId);
        } else {
          url = AppUrls.getContentVideoToken(contentType, contentId);
        }

        return await dioService.callApi(
          NetworkRequest(
            url,
            method: RequestMethod.get,
            requestWithOutToken: false,
          ),
          mapper: (json) {
            return VideoTokenResponseModel.fromJson(json as Map<String, dynamic>);
          },
        );
      } on DioException catch (e) {
        throw ErrorsExceptionsHandler.handleError(e);
      }
    });
  }
}
