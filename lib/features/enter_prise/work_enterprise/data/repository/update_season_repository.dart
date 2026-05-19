
import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/repository/repository.dart';
import '../models/request/update_season_request_model.dart';
import '../models/response/create_season_response_model.dart';

abstract class UpdateSeasonRepository extends Repository {
  Future<Either<CustomException, CreateSeasonResponseModel>> updateSeason({
    required UpdateSeasonRequestModel model,
  });
}
