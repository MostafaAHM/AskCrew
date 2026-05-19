import 'package:dartz/dartz.dart';

import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/helpers/secure_local_storage.dart';
import '../../../../../core/models/base_response_model.dart';
import '../../../../../core/network/network_request.dart';
import '../../../viewer/register_viewer/data/services/google_auth_service.dart';
import 'logout_repository.dart';

class LogoutRepositoryImpl extends LogoutRepository {
  final GoogleAuthService _googleAuthService;

  LogoutRepositoryImpl(this._googleAuthService);

  @override
  Future<Either<CustomException, BaseResponseModel>> logout() async {
    final result = await exceptionHandler(() async {
      BaseResponseModel response = await dioService.callApi(
        NetworkRequest(
          AppUrls.logout,
          method: RequestMethod.post,
          requestWithOutToken: false,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );

      await SecureLocalStorage.deleteAll();

      await dioService.clearCookies();

      await _googleAuthService.signOut();

      return response;
    });
    return result;
  }
}
