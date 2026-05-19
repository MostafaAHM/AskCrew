import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../model/banner_model.dart';

abstract class BannerRepository {
  Future<Either<Failure, BannersResponseModel>> getBanners();
}

