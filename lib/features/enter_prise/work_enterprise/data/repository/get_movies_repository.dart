import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failure.dart';

import '../models/response/movie_model.dart';

abstract class GetMoviesRepository {
  Future<Either<Failure, MoviesResponseModel>> getMovies({
    int? page,
    String? query,
  });
}
