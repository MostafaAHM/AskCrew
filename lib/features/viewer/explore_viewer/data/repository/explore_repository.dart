import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_service.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../models/explore_response_model.dart';

abstract class ExploreRepository {
  Future<Either<CustomException, ExploreResponseModel>> getExploreContent();
}

class ExploreRepositoryImpl implements ExploreRepository {
  final DioService _dioService;

  ExploreRepositoryImpl(this._dioService);

  @override
  Future<Either<CustomException, ExploreResponseModel>> getExploreContent() async {
    try {
      final response = await _dioService.callApi(
        NetworkRequest(
          AppUrls.getExploreContent,
          method: RequestMethod.get,
        ),
      );

      // The response is a list directly, not wrapped in an object
      if (response is List) {
        return Right(ExploreResponseModel.fromJson(response));
      } else {
        return Left(CustomException('Invalid response format'));
      }
    } on CustomException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}

