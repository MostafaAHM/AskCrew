import 'package:dartz/dartz.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/repository/repository.dart';
import '../models/response/advertise_model.dart';
import 'get_advertises_repository.dart';

class GetAdvertisesRepositoryImpl extends Repository implements GetAdvertisesRepository {

  @override
  Future<Either<CustomException, List<AdvertiseModel>>> getAdvertises() async {
    final result = await exceptionHandler(
      () async {
        final response = await dioService.callApi(
          NetworkRequest(
            AppUrls.getAdvertises,
            method: RequestMethod.get,
          ),
          mapper: (json) {
            final results = json['results'] as List;
            return results.map((e) => AdvertiseModel.fromJson(e)).toList();
          },
        );

        return response;
      },
    );
    return result;
  }
}
