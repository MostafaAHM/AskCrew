import 'package:dartz/dartz.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/app_config/prefs_keys.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/helpers/secure_local_storage.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/repository/repository.dart';
import 'delete_account_repository.dart';

class DeleteAccountRepositoryImpl extends Repository implements DeleteAccountRepository {
  @override
  Future<Either<CustomException, void>> deleteAccount() async {
    final result = await exceptionHandler(
      () async {
        await dioService.callApi(
          NetworkRequest(
            AppUrls.deleteAccount,
            method: RequestMethod.post,
          ),
        );

        // Clear local storage after successful deletion
        await SecureLocalStorage.delete(PrefsKeys.token);
        await SecureLocalStorage.delete(PrefsKeys.user);
        await SecureLocalStorage.delete(PrefsKeys.password);
        await SecureLocalStorage.delete(PrefsKeys.mailOrPhone);
        await dioService.clearCookies();
      },
    );
    return result;
  }
}

