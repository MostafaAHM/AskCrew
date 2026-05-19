import 'package:dartz/dartz.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/models/base_response_model.dart';
import '../../../../../core/repository/repository.dart';

abstract class LogoutRepository extends Repository {
  Future<Either<CustomException, BaseResponseModel>> logout();
}
