import 'package:dartz/dartz.dart';
import 'package:aflam/core/app_config/app_urls.dart';
import 'package:aflam/core/error/failure.dart';
import 'package:aflam/core/error/exceptions.dart';
import 'package:aflam/core/network/dio_service.dart';
import 'package:aflam/core/network/network_request.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/category_model.dart';
import 'categories_repository.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final DioService _dioService;

  CategoriesRepositoryImpl(this._dioService);

  @override
  Future<Either<ServerFailure, CategoriesResponseModel>> getCategories() async {
    try {
      final response = await _dioService.callApi(
        NetworkRequest(
          AppUrls.getCategories,
          method: RequestMethod.get,
        ),
      );

      return Right(CategoriesResponseModel.fromJson(response));
    } on CustomException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
