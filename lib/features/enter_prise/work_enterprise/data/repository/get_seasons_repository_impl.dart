import 'package:dartz/dartz.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_service.dart';
import '../../../../../core/network/network_request.dart';
import '../models/response/seasons_response_model.dart';
import 'get_seasons_repository.dart';

class GetSeasonsRepositoryImpl implements GetSeasonsRepository {
  final DioService _dioService;

  GetSeasonsRepositoryImpl(this._dioService);

  @override
  Future<Either<CustomException, SeasonsResponseModel>> getSeasons(int seriesId) async {
    try {
      final response = await _dioService.callApi(
        NetworkRequest(
          '${AppUrls.getSeasons}?series=$seriesId',
          method: RequestMethod.get,
        ),
        mapper: (json) => SeasonsResponseModel.fromJson(json),
      );
      return Right(response);
    } on CustomException catch (e) {
      return Left(e);
    } catch (e) {
  return Left(CustomException(e.toString()));
    }
  }

  @override
  Future<Either<CustomException, void>> deleteSeason(int id) async {
    try {
      await _dioService.callApi(
        NetworkRequest(
          AppUrls.deleteSeason(id),
          method: RequestMethod.delete,
        ),
      );
      return const Right(null);
    } on CustomException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  @override
  Future<Either<CustomException, SeasonModel>> updateSeason(int id, Map<String, dynamic> body) async {
    try {
      final response = await _dioService.callApi(
        NetworkRequest(
          AppUrls.updateSeason(id),
          method: RequestMethod.patch,
          body: body,
        ),
        mapper: (json) => SeasonModel.fromJson(json),
      );
      return Right(response);
    } on CustomException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}
