import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../models/response/episodes_response_model.dart';

abstract class GetEpisodesRepository {
  Future<Either<CustomException, EpisodesResponseModel>> getEpisodes(int seasonId);
  Future<Either<CustomException, void>> deleteEpisode(int id);
  Future<Either<CustomException, EpisodeModel>> updateEpisode(int id, Map<String, dynamic> body);
}
