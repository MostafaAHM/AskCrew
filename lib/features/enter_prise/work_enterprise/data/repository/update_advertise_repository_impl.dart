
import 'package:dartz/dartz.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/repository/repository.dart';
import '../models/request/update_advertise_request_model.dart';
import '../models/response/create_advertise_response_model.dart';
import 'update_advertise_repository.dart';

class UpdateAdvertiseRepositoryImpl extends Repository implements UpdateAdvertiseRepository {
  @override
  Future<Either<CustomException, CreateAdvertiseResponseModel>> updateAdvertise({
    required UpdateAdvertiseRequestModel model,
  }) async {
    final result = await exceptionHandler(
      () async {
        final formData = await model.toFormData();
        
        final CreateAdvertiseResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.updateAdvertise(model.advertiseId), // Needs to be added to AppUrls
            method: RequestMethod.patch,
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
