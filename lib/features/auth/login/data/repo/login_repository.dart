import 'package:dartz/dartz.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/repository/repository.dart';
import '../model/login_request_model.dart';
import '../model/google_login_request_model.dart';
import '../model/response/base_response_model.dart';

abstract class LoginRepository extends Repository {
  Future<Either<CustomException, LoginResponseModel>> login({
    required LoginRequestModel model,
  });

  Future<Either<CustomException, LoginResponseModel>> googleLoginViewer({
    required GoogleLoginRequestModel model,
  });

  // Future<Either<CustomException, LoginResponseModel>> loginWithGoogle();
  // Future<Either<CustomException, LoginResponseModel>> loginWithFacebook();
}
