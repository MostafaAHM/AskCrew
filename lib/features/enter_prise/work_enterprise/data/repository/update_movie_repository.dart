
import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../models/request/update_movie_request_model.dart';
import '../models/response/create_movie_response_model.dart';

abstract class UpdateMovieRepository {
  Future<Either<CustomException, CreateMovieResponseModel>> updateMovie({
    required UpdateMovieRequestModel model,
  });
}
