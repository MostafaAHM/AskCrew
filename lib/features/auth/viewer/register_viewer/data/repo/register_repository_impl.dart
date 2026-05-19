import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../../core/app_config/app_urls.dart';
import '../../../../../../core/app_config/prefs_keys.dart';
import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/helpers/secure_local_storage.dart';
import '../../../../../../core/models/base_response_model.dart';
import '../../../../../../core/network/network_request.dart';
import '../model/signup_request_model.dart';
import '../model/complete_viewer_profile_request_model.dart';
import '../model/google_signup_request_model.dart';
import '../../../../login/data/model/response/base_response_model.dart';
import 'register_repository.dart';

class RegisterRepositoryImpl extends RegisterRepository {
  @override
  Future<Either<CustomException, BaseResponseModel>> registerView({
    required SignupRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      BaseResponseModel response = await dioService.callApi(
        NetworkRequest(
          AppUrls.viewerSignup,
          method: RequestMethod.post,
          isFormData: false,
          body: model.toJson(),
          requestWithOutToken: true,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );
      log('Register View Response: $response');
      return response;
    });
    return result;
  }

  @override
  Future<Either<CustomException, BaseResponseModel>> completeViewerProfile({
    required CompleteViewerProfileRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      BaseResponseModel response = await dioService.callApi(
        NetworkRequest(
          AppUrls.completeViewerProfile,
          method: RequestMethod.post,
          isFormData: true,
          formDataBody: FormData.fromMap(model.toFormData()),
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );
      log('Complete Viewer Profile Response: $response');
      return response;
    });
    return result;
  }

  @override
  Future<Either<CustomException, LoginResponseModel>> googleSignupViewer({
    required GoogleSignupRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      // Log request details (safe - no token exposure)
      log(
        '📱 [GOOGLE SIGNUP] Calling: ${AppUrls.googleSignupViewer}\n'
        '   Phone: ${model.phone}\n'
        '   ID Token: ${model.idToken.isNotEmpty ? "Present" : "Missing"}',
        name: 'GoogleSignup',
      );

      // Call the Google signup endpoint with JSON
      final LoginResponseModel response = await dioService.callApi(
        NetworkRequest(
          AppUrls.googleSignupViewer,
          method: RequestMethod.post,
          isFormData: false,
          body: model.toJson(),
          requestWithOutToken: true,
        ),
        mapper: (json) => LoginResponseModel.fromJson(json: json),
      );

      log(
        '✅ [GOOGLE SIGNUP] Success - Status: ${response.code}',
        name: 'GoogleSignup',
      );

      // Save access token (same as normal login)
      await SecureLocalStorage.write(PrefsKeys.token, response.accessToken);

      // Save user data (same as normal login)
      await SecureLocalStorage.write(
        PrefsKeys.user,
        jsonEncode(response.user.toJson()),
      );

      // Note: We don't save password for Google sign-in
      // as it's not applicable

      return response;
    });
    return result;
  }
}
