import 'package:dartz/dartz.dart';

import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/models/base_response_model.dart';
import '../../../../../../core/repository/repository.dart';
import '../model/signup_request_model.dart';
import '../model/complete_viewer_profile_request_model.dart';
import '../model/google_signup_request_model.dart';
import '../../../../login/data/model/response/base_response_model.dart';

abstract class RegisterRepository extends Repository {
  Future<Either<CustomException, BaseResponseModel>> registerView({
    required SignupRequestModel model,
  });

  Future<Either<CustomException, BaseResponseModel>> completeViewerProfile({
    required CompleteViewerProfileRequestModel model,
  });
  Future<Either<CustomException, LoginResponseModel>> googleSignupViewer({
    required GoogleSignupRequestModel model,
  });
}
