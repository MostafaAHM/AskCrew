import 'package:dartz/dartz.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/repository/repository.dart';
import '../models/category_model.dart';

abstract class CategoriesRepository extends Repository {
  Future<Either<CustomException, List<CategoryModel>>> getCategories();
}
