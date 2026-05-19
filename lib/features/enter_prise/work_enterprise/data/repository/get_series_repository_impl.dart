import 'package:dartz/dartz.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_service.dart';
import '../../../../../core/network/network_request.dart';
import '../models/response/series_response_model.dart';
import 'get_series_repository.dart';

class GetSeriesRepositoryImpl implements GetSeriesRepository {
  final DioService _dioService;

  GetSeriesRepositoryImpl(this._dioService);

  @override
  Future<Either<CustomException, SeriesResponseModel>> getSeries() async {
    try {
      final response = await _dioService.callApi(
        NetworkRequest(
          AppUrls.getSeries,
          method: RequestMethod.get,
        ),
        mapper: (json) => SeriesResponseModel.fromJson(json),
      );
      return Right(response);
    } on CustomException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  @override
  Future<Either<CustomException, void>> deleteSeries(int id) async {
    try {
      await _dioService.callApi(
        NetworkRequest(
          AppUrls.deleteSeries(id),
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
  Future<Either<CustomException, SeriesModel>> updateSeries(int id, Map<String, dynamic> body) async {
    try {
      final response = await _dioService.callApi(
        NetworkRequest(
          AppUrls.updateSeries(id),
          method: RequestMethod.patch,
          body: body,
        ),
        mapper: (json) => SeriesModel.fromJson(json),
      );
      return Right(response);
    } on CustomException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}

