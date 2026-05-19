import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../models/response/series_response_model.dart';

abstract class GetSeriesRepository {
  Future<Either<CustomException, SeriesResponseModel>> getSeries();
  Future<Either<CustomException, void>> deleteSeries(int id);
  Future<Either<CustomException, SeriesModel>> updateSeries(int id, Map<String, dynamic> body);
}
