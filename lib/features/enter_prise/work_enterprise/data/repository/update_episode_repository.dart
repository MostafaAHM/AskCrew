
import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/repository/repository.dart';
import '../models/request/update_episode_request_model.dart';
import '../models/response/create_episode_response_model.dart';

abstract class UpdateEpisodeRepository extends Repository {
  Future<Either<CustomException, CreateEpisodeResponseModel>> updateEpisode({
    required UpdateEpisodeRequestModel model,
  });
}
