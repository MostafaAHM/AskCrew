import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/repository/repository.dart';
import 'change_password_repository.dart';

class ChangePasswordRepositoryImpl extends Repository implements ChangePasswordRepository {
  @override
  Future<Either<CustomException, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final result = await exceptionHandler(
      () async {
        final formData = FormData.fromMap({
          'old_password': oldPassword,
          'new_password': newPassword,
        });

        await dioService.callApi(
          NetworkRequest(
            AppUrls.changePassword,
            method: RequestMethod.post,
            formDataBody: formData,
            isFormData: true,
          ),
        );
      },
    );
    return result;
  }
}

