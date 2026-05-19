import 'package:dartz/dartz.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/models/base_response_model.dart';
import '../../../../../core/repository/repository.dart';
import '../model/forget_password_request_model.dart';

abstract class ForgetPasswordRepository extends Repository {
  Future<Either<CustomException, BaseResponseModel>> sendForgetPasswordOtp({
    required ForgetPasswordRequestModel model,
  });
}
