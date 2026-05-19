import 'package:dartz/dartz.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/models/base_response_model.dart';
import '../../../../../core/repository/repository.dart';
import '../model/resend_sms_request_model.dart';
import '../model/send_otp_request_model.dart';

abstract class VerifyOtpRepository extends Repository {
  Future<Either<CustomException, BaseResponseModel>> verifyOTP({
    required ResendSmsRequestModel options,
  });

  Future<Either<CustomException, BaseResponseModel>> sendOtp({
    required SendOtpRequestModel options,
  });

  Future<Either<CustomException, BaseResponseModel>> resendOtp({
    required SendOtpRequestModel options,
  });
}
