
import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../models/request/update_advertise_request_model.dart';
import '../models/response/create_advertise_response_model.dart';


abstract class UpdateAdvertiseRepository {
  Future<Either<CustomException, CreateAdvertiseResponseModel>> updateAdvertise({
    required UpdateAdvertiseRequestModel model,
  });
}
