
import 'package:dartz/dartz.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/repository/repository.dart';
import '../models/request/update_season_request_model.dart';
import '../models/response/create_season_response_model.dart';
import 'update_season_repository.dart';

class UpdateSeasonRepositoryImpl extends Repository implements UpdateSeasonRepository {
  @override
  Future<Either<CustomException, CreateSeasonResponseModel>> updateSeason({
    required UpdateSeasonRequestModel model,
  }) async {
    final result = await exceptionHandler(
      () async {
        final formData = await model.toFormData();
        
        final CreateSeasonResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.updateSeason(model.seasonId),
            method: RequestMethod.patch,
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
