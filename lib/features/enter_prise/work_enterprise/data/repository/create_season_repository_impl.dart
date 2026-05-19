import 'package:dartz/dartz.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/repository/repository.dart';
import '../models/request/create_season_request_model.dart';
import '../models/response/create_season_response_model.dart';
import 'create_season_repository.dart';

class CreateSeasonRepositoryImpl extends Repository implements CreateSeasonRepository {
  @override
  Future<Either<CustomException, CreateSeasonResponseModel>> createSeason({
    required CreateSeasonRequestModel model,
  }) async {
    final result = await exceptionHandler(
      () async {
        final formData = await model.toFormData();
        
        final CreateSeasonResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.createSeason,
            method: RequestMethod.post,
            formDataBody: formData,
            isFormData: true,
          ),
          mapper: (json) => CreateSeasonResponseModel.fromJson(json),
        );

        return response;
      },
    );
    return result;
  }
}
