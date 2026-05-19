import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../models/response/advertise_model.dart';

abstract class GetAdvertisesRepository {
  Future<Either<CustomException, List<AdvertiseModel>>> getAdvertises();
}
