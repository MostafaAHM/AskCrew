import 'package:dartz/dartz.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/network/dio_service.dart';
import '../../../../../core/network/network_request.dart';
import '../model/banner_model.dart';
import 'banner_repository.dart';

class BannerRepositoryImpl implements BannerRepository {
  final DioService _dioService;

  BannerRepositoryImpl(this._dioService);

  @override
  Future<Either<Failure, BannersResponseModel>> getBanners() async {
    try {
      final response = await _dioService.callApi(
        NetworkRequest(
          AppUrls.getBanners,
          method: RequestMethod.get,
        ),
      );

      return Right(BannersResponseModel.fromJson(response));
    } on CustomException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

