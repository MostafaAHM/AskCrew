import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';

abstract class DeleteMovieRepository {
  Future<Either<CustomException, String>> deleteMovie(int id);
}
