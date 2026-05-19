import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/repository/repository.dart';
import '../models/request/create_episode_request_model.dart';
import '../models/response/create_episode_response_model.dart';

abstract class CreateEpisodeRepository extends Repository {
  Future<Either<CustomException, CreateEpisodeResponseModel>> createEpisode({
    required CreateEpisodeRequestModel model,
  });
}
