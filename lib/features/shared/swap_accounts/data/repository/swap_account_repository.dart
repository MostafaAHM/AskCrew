import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/models/base_response_model.dart';

abstract class SwapAccountRepository {
  Future<Either<CustomException, BaseResponseModel>> swapToEnterprise();
  Future<Either<CustomException, BaseResponseModel>> swapToStudent();
  Future<Either<CustomException, BaseResponseModel>> swapToViewer();
}

