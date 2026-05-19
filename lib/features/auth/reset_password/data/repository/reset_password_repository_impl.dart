import 'package:dartz/dartz.dart';

import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/models/base_response_model.dart';
import '../../../../../core/network/network_request.dart';
import '../model/reset_password_request_model.dart';
import 'reset_password_repository.dart';

class ResetPasswordRepositoryImpl extends ResetPasswordRepository {
  @override
  Future<Either<CustomException, BaseResponseModel>> resetPassword({
    required ResetPasswordRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      BaseResponseModel response = await dioService.callApi(
        NetworkRequest(
          AppUrls.resetPassword,
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
