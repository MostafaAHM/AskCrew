import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/app_config/prefs_keys.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/helpers/secure_local_storage.dart';
import '../../../../../core/network/network_request.dart';
import '../model/login_request_model.dart';
import '../model/google_login_request_model.dart';
import '../model/response/base_response_model.dart';
import 'login_repository.dart';

class LoginRepositoryImpl extends LoginRepository {
  @override
  Future<Either<CustomException, LoginResponseModel>> login({
    required LoginRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      final LoginResponseModel user = await dioService.callApi(
        NetworkRequest(
          AppUrls.login,
          method: RequestMethod.post,
          body: model.toJson(),
          requestWithOutToken: true,
        ),
        mapper: (json) => LoginResponseModel.fromJson(json: json),
      );

      await SecureLocalStorage.write(PrefsKeys.token, user.accessToken);

      await SecureLocalStorage.write(PrefsKeys.password, model.password);

      await SecureLocalStorage.write(PrefsKeys.mailOrPhone, model.email);

      await SecureLocalStorage.write(
        PrefsKeys.user,
        jsonEncode(user.user.toJson()),
      );

      return user;
    });

    return result;
  }

  @override
  Future<Either<CustomException, LoginResponseModel>> googleLoginViewer({
    required GoogleLoginRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      final LoginResponseModel response = await dioService.callApi(
        NetworkRequest(
          AppUrls.googleLoginViewer,
          method: RequestMethod.post,
          isFormData: false,
          body: model.toJson(),
          requestWithOutToken: true,
        ),
        mapper: (json) => LoginResponseModel.fromJson(json: json),
      );

      await SecureLocalStorage.write(PrefsKeys.token, response.accessToken);

      await SecureLocalStorage.write(
        PrefsKeys.user,
        jsonEncode(response.user.toJson()),
      );

      return response;
    });
    return result;
  }
}
