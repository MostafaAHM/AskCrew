import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/repository/repository.dart';
import '../models/request/create_series_request_model.dart';
import '../models/response/create_series_response_model.dart';

abstract class CreateSeriesRepository extends Repository {
  Future<Either<CustomException, CreateSeriesResponseModel>> createSeries({
    required CreateSeriesRequestModel model,
  });
}
