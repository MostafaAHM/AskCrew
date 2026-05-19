
import 'package:dartz/dartz.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/repository/repository.dart';
import '../models/request/create_advertise_request_model.dart';
import '../models/response/create_advertise_response_model.dart';
import 'create_advertise_repository.dart';

class CreateAdvertiseRepositoryImpl extends Repository implements CreateAdvertiseRepository {
  @override
  Future<Either<CustomException, CreateAdvertiseResponseModel>> createAdvertise({
    required CreateAdvertiseRequestModel model,
  }) async {
    final result = await exceptionHandler(
      () async {
        final formData = await model.toFormData();
        
        final CreateAdvertiseResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.addAdvertise, // Make sure to add this endpoint to AppUrls
            method: RequestMethod.post,
            formDataBody: formData,
            isFormData: true,
          ),
          mapper: (json) => CreateAdvertiseResponseModel.fromJson(json),
        );

        return response;
      },
    );
    return result;
  }
}
