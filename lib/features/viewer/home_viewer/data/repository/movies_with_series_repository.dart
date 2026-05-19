import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/repository/repository.dart';
import '../model/movies_with_series_model.dart';

abstract class MoviesWithSeriesRepository extends Repository {
  Future<Either<CustomException, MoviesWithSeriesResponseModel>>
  getMoviesWithSeries({int? categoryId});

  Future<Either<CustomException, void>> rateContent({
    required String contentType,
    required String objectId,
    required int rating,
  });

  Future<Either<CustomException, MovieOrSeriesItem>> getContentDetails({
    required String contentType,
    required int id,
  });
}
