import 'package:dartz/dartz.dart';

import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/models/base_response_model.dart';
import '../../../../../core/network/network_request.dart';
import '../model/resend_sms_request_model.dart';
import '../model/send_otp_request_model.dart';
import 'verify_otp_repository.dart';

class VerifyOtpRepositoryImpl extends VerifyOtpRepository {
  @override
  Future<Either<CustomException, BaseResponseModel>> verifyOTP({
    required ResendSmsRequestModel options,
  }) async {
    final result = await exceptionHandler(() async {
      BaseResponseModel responseModel = await dioService.callApi(
        NetworkRequest(
          AppUrls.activate,
          method: RequestMethod.post,
          body: options.toJson(),
          requestWithOutToken: true,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );

      return responseModel;
    });
    return result;
  }

  @override
  Future<Either<CustomException, BaseResponseModel>> resendOtp({
    required SendOtpRequestModel options,
  }) async {
    final result = await exceptionHandler(() async {
      BaseResponseModel responseModel = await dioService.callApi(
        NetworkRequest(
          AppUrls.resendSms,
          method: RequestMethod.post,
          body: options.toJson(),
          requestWithOutToken: true,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );

      return responseModel;
    });
    return result;
  }

  @override
  Future<Either<CustomException, BaseResponseModel>> sendOtp({
    required SendOtpRequestModel options,
  }) async {
    final result = await exceptionHandler(() async {
      BaseResponseModel responseModel = await dioService.callApi(
        NetworkRequest(
          AppUrls.resendSms,
          method: RequestMethod.post,
          body: options.toJson(),
          requestWithOutToken: true,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );

      return responseModel;
    });
    return result;
  }
}
