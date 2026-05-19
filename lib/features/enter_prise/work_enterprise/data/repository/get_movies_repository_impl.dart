import 'package:dartz/dartz.dart';
import '../../../../../../core/network/dio_service.dart';
import '../../../../../../core/app_config/app_urls.dart';
import '../../../../../../core/error/failure.dart';
import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/network/network_request.dart';
import '../models/response/movie_model.dart';
import 'get_movies_repository.dart';

class GetMoviesRepositoryImpl implements GetMoviesRepository {
  final DioService _dioService;

  GetMoviesRepositoryImpl(this._dioService);

  @override
  Future<Either<Failure, MoviesResponseModel>> getMovies({
    int? page,
    String? query,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (page != null) queryParams['page'] = page;
      if (query != null && query.isNotEmpty) queryParams['name'] = query;

      final response = await _dioService.callApi(
        NetworkRequest(
          AppUrls.getMovies,
          method: RequestMethod.get,
          queryParameters: queryParams,
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
