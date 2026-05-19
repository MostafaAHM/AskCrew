import 'package:dartz/dartz.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_service.dart';
import '../../../../../core/network/network_request.dart';
import '../models/response/episodes_response_model.dart';
import 'get_episodes_repository.dart';

class GetEpisodesRepositoryImpl implements GetEpisodesRepository {
  final DioService _dioService;

  GetEpisodesRepositoryImpl(this._dioService);

  @override
  Future<Either<CustomException, EpisodesResponseModel>> getEpisodes(int seasonId) async {
    try {
      final response = await _dioService.callApi(
        NetworkRequest(
          '${AppUrls.getEpisodes}?season=$seasonId',
          method: RequestMethod.get,
        ),
        mapper: (json) => EpisodesResponseModel.fromJson(json),
      );
      return Right(response);
    } on CustomException catch (e) {
      return Left(e);
    } catch (e) {
  return Left(CustomException(e.toString()));
    }
  }

  @override
  Future<Either<CustomException, void>> deleteEpisode(int id) async {
    try {
      await _dioService.callApi(
        NetworkRequest(
          AppUrls.deleteEpisode(id),
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
  Future<Either<CustomException, EpisodeModel>> updateEpisode(int id, Map<String, dynamic> body) async {
    try {
      final response = await _dioService.callApi(
        NetworkRequest(
          AppUrls.updateEpisode(id),
          method: RequestMethod.patch,
          body: body,
        ),
        mapper: (json) => EpisodeModel.fromJson(json),
      );
      return Right(response);
    } on CustomException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}
