import 'package:dartz/dartz.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/repository/repository.dart';
import '../models/request/create_episode_request_model.dart';
import '../models/response/create_episode_response_model.dart';
import 'create_episode_repository.dart';

class CreateEpisodeRepositoryImpl extends Repository implements CreateEpisodeRepository {
  @override
  Future<Either<CustomException, CreateEpisodeResponseModel>> createEpisode({
    required CreateEpisodeRequestModel model,
  }) async {
    final result = await exceptionHandler(
      () async {
        final formData = await model.toFormData();
        
        final CreateEpisodeResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.createEpisode,
            method: RequestMethod.post,
            formDataBody: formData,
            isFormData: true,
          ),
          mapper: (json) => CreateEpisodeResponseModel.fromJson(json),
        );

        return response;
      },
    );
    return result;
  }
}
