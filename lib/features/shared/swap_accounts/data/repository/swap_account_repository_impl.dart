import 'package:aflam/core/app_config/app_urls.dart';
import 'package:aflam/core/models/base_response_model.dart';
import 'package:aflam/core/network/network_request.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/repository/repository.dart';
import 'swap_account_repository.dart';

class SwapAccountRepositoryImpl extends Repository implements SwapAccountRepository {
  @override
  Future<Either<CustomException, BaseResponseModel>> swapToEnterprise() async {
    final result = await exceptionHandler(
      () async {
        BaseResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.swapToEnterprise,
            method: RequestMethod.post,
            // No body needed for swap endpoint
          ),
          mapper: (json) => BaseResponseModel.fromJson(json),
        );
        return response;
      },
    );
    return result;
  }

  @override
  Future<Either<CustomException, BaseResponseModel>> swapToStudent() async {
    final result = await exceptionHandler(
      () async {
        BaseResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.swapToStudent,
            method: RequestMethod.post,
            // No body needed for swap endpoint
          ),
          mapper: (json) => BaseResponseModel.fromJson(json),
        );
        return response;
      },
    );
    return result;
  }

  @override
  Future<Either<CustomException, BaseResponseModel>> swapToViewer() async {
    final result = await exceptionHandler(
      () async {
        BaseResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.swapToViewer,
            method: RequestMethod.post,
            // No body needed for swap endpoint
          ),
          mapper: (json) => BaseResponseModel.fromJson(json),
        );
        return response;
      },
    );
    return result;
  }
}

