import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/repository/repository.dart';
import '../models/video_token_response_model.dart';

abstract class VideoPlayerRepository extends Repository {
  Future<Either<CustomException, VideoTokenResponseModel>> getVideoToken({
    required String contentType,
    required int contentId,
    bool playTrailer = false,
  });
}
