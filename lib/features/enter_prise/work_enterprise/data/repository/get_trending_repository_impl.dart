import 'package:dartz/dartz.dart';
import '../../../../../../core/network/dio_service.dart';
import '../../../../../../core/app_config/app_urls.dart';
import '../../../../../../core/error/failure.dart';
import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/network/network_request.dart';
import '../models/response/movie_model.dart';
import 'get_trending_repository.dart';

class GetTrendingRepositoryImpl implements GetTrendingRepository {
  final DioService _dioService;

  GetTrendingRepositoryImpl(this._dioService);

  @override
  Future<Either<Failure, MoviesResponseModel>> getTrending() async {
    try {
      final response = await _dioService.callApi(
        NetworkRequest(
          AppUrls.getTrending,
          method: RequestMethod.get,
        ),
      );

      return Right(MoviesResponseModel.fromJson(response));
    } on CustomException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

