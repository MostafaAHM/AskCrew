import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../model/activate_plan_request_model.dart';
import 'activate_plan_repository.dart';

class ActivatePlanRepositoryImpl extends ActivatePlanRepository {
  @override
  Future<Either<CustomException, ActivatePlanResponseModel>> activatePlan(
    ActivatePlanRequestModel request,
  ) async {
    final result = await exceptionHandler(() async {
      final formData = FormData.fromMap(request.toJson());
      
      ActivatePlanResponseModel responseModel = await dioService.callApi(
        NetworkRequest(
          AppUrls.activatePlan,
          method: RequestMethod.post,
          formDataBody: formData,
          isFormData: true,
          requestWithOutToken: false,
        ),
        mapper: (json) => ActivatePlanResponseModel.fromJson(json),
      );

      return responseModel;
    });
    return result;
  }
}
