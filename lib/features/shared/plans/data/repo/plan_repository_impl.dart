import 'package:dartz/dartz.dart';

import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';

import '../model/get_plans_response_model.dart';
import 'plan_repository.dart';

class PlanRepositoryImpl extends PlanRepository {
  @override
  Future<Either<CustomException, SubscriptionPlansResponse>>
  getSubscriptionPlans({String? planType}) async {
    final result = await exceptionHandler(() async {
      SubscriptionPlansResponse responseModel = await dioService.callApi(
        NetworkRequest(
          AppUrls.plans,
          method: RequestMethod.get,
          queryParameters: planType != null ? {'plan_type': planType} : null,
          requestWithOutToken: false,
        ),
        mapper: (json) => SubscriptionPlansResponse.fromJson(json),
      );

      return responseModel;
    });
    return result;
  }

  @override
  Future<Either<CustomException, PlanDiscountsModel>> getPlanDiscounts() async {
    final result = await exceptionHandler(() async {
      PlanDiscountsModel responseModel = await dioService.callApi(
        NetworkRequest(
          AppUrls.planDiscounts,
          method: RequestMethod.get,
          requestWithOutToken: false,
        ),
        mapper: (json) => PlanDiscountsModel.fromJson(json),
      );

      return responseModel;
    });
    return result;
  }
}
