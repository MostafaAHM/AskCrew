import 'package:dartz/dartz.dart';
import '../models/response/category_model.dart';
import '../../../../../../core/error/failure.dart';

abstract class CategoriesRepository {
  Future<Either<ServerFailure, CategoriesResponseModel>> getCategories();
}
