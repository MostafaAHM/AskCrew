import 'package:dartz/dartz.dart';

import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/models/base_response_model.dart';
import '../../../../../core/network/network_request.dart';
import '../model/forget_password_request_model.dart';
import 'forget_password_repository.dart';

class ForgetPasswordRepositoryImpl extends ForgetPasswordRepository {
  @override
  Future<Either<CustomException, BaseResponseModel>> sendForgetPasswordOtp({
    required ForgetPasswordRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      BaseResponseModel response = await dioService.callApi(
        NetworkRequest(
          AppUrls.resendSms, // Use resendSms to send OTP for forget password
          method: RequestMethod.post,
          body: model.toJson(),
          requestWithOutToken: true,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );

      return response;
    });
    return result;
  }
}
