import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/repository/repository.dart';
import '../model/activate_plan_request_model.dart';

abstract class ActivatePlanRepository extends Repository {
  Future<Either<CustomException, ActivatePlanResponseModel>> activatePlan(
    ActivatePlanRequestModel request,
  );
}
