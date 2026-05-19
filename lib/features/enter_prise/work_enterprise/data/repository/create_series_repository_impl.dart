import 'package:dartz/dartz.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/repository/repository.dart';
import '../models/request/create_series_request_model.dart';
import '../models/response/create_series_response_model.dart';
import 'create_series_repository.dart';

class CreateSeriesRepositoryImpl extends Repository implements CreateSeriesRepository {
  @override
  Future<Either<CustomException, CreateSeriesResponseModel>> createSeries({
    required CreateSeriesRequestModel model,
  }) async {
    final result = await exceptionHandler(
      () async {
        final formData = await model.toFormData();
        
        final CreateSeriesResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.createSeries,
            method: RequestMethod.post,
            formDataBody: formData,
            isFormData: true,
          ),
          mapper: (json) => CreateSeriesResponseModel.fromJson(json),
        );

        return response;
      },
    );
    return result;
  }
}
