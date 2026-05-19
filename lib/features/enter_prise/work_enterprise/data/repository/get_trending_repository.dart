import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failure.dart';

import '../models/response/movie_model.dart';

abstract class GetTrendingRepository {
  Future<Either<Failure, MoviesResponseModel>> getTrending();
}

