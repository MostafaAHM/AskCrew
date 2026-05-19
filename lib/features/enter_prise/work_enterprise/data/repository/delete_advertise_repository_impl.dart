import 'package:dartz/dartz.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/repository/repository.dart';
import 'delete_advertise_repository.dart';

class DeleteAdvertiseRepositoryImpl extends Repository implements DeleteAdvertiseRepository {
  @override
  Future<Either<CustomException, void>> deleteAdvertise({required int advertiseId}) async {
    final result = await exceptionHandler(
      () async {
        await dioService.callApi(
          NetworkRequest(
            AppUrls.deleteAdvertise(advertiseId),
            method: RequestMethod.delete,
          ),
          mapper: (json) => null,
        );
      },
    );
    return result;
  }
}
