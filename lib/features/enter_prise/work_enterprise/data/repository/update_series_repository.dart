
import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/repository/repository.dart';
import '../models/request/update_series_request_model.dart';
import '../models/response/create_series_response_model.dart';

abstract class UpdateSeriesRepository extends Repository {
  Future<Either<CustomException, CreateSeriesResponseModel>> updateSeries({
    required UpdateSeriesRequestModel model,
  });
}
