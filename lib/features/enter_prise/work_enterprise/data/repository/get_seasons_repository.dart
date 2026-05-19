import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../models/response/seasons_response_model.dart';

abstract class GetSeasonsRepository {
  Future<Either<CustomException, SeasonsResponseModel>> getSeasons(int seriesId);
  Future<Either<CustomException, void>> deleteSeason(int id);
  Future<Either<CustomException, SeasonModel>> updateSeason(int id, Map<String, dynamic> body);
}
