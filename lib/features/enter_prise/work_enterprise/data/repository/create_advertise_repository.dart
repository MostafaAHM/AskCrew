
import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../models/request/create_advertise_request_model.dart';
import '../models/response/create_advertise_response_model.dart';


abstract class CreateAdvertiseRepository {
  Future<Either<CustomException, CreateAdvertiseResponseModel>> createAdvertise({
    required CreateAdvertiseRequestModel model,
  });
}
