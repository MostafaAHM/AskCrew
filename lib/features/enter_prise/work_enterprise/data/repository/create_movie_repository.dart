import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/repository/repository.dart';
import '../models/request/create_movie_request_model.dart';
import '../models/response/create_movie_response_model.dart';

abstract class CreateMovieRepository extends Repository{
  Future<Either<CustomException, CreateMovieResponseModel>> createMovie({
    required CreateMovieRequestModel model,
  });
}
