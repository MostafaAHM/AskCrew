import 'package:dartz/dartz.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/repository/repository.dart';
import '../model/get_plans_response_model.dart';

abstract class PlanRepository extends Repository {
  Future<Either<CustomException, SubscriptionPlansResponse>>
  getSubscriptionPlans({String? planType});
  Future<Either<CustomException, PlanDiscountsModel>> getPlanDiscounts();
}
