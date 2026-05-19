import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/repository/repository.dart';
import '../models/video_token_response_model.dart';

abstract class ContentVideoTokenRepository extends Repository {
  Future<Either<CustomException, VideoTokenResponseModel>>
  getContentVideoToken({required String contentType, required int contentId});
}
