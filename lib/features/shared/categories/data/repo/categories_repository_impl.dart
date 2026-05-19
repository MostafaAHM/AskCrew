import 'package:dartz/dartz.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../models/category_model.dart';
import 'categories_repository.dart';

class CategoriesRepositoryImpl extends CategoriesRepository {
  @override
  Future<Either<CustomException, List<CategoryModel>>> getCategories() async {
    return await exceptionHandler(
      () async {
        final response = await dioService.callApi(
          NetworkRequest(
            '/v1/auth/categories',
            method: RequestMethod.get,
          ),
          mapper: (json) {
            final categories = json['categories'] as List;
            return categories.map((e) => CategoryModel.fromJson(e)).toList();
          },
        );
        return response;
      },
    );
  }
}
