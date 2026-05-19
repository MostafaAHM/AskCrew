import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/model/get_plans_response_model.dart';
import '../../data/repo/plan_repository.dart';

part 'get_all_plan_state.dart';

class GetAllPlanCubit extends Cubit<GetAllPlanState> {
  final PlanRepository repository;
  GetAllPlanCubit(this.repository) : super(GetAllPlanInitial());

  Future<void> getAllPlans({String? planType}) async {
    emit(GetAllPlanLoading());

    final planResult = await repository.getSubscriptionPlans(
      planType: planType,
    );
    final discountResult = await repository.getPlanDiscounts();

    planResult.fold(
      (failure) {
        emit(
          GetAllPlanFailure(
            errorMessage: failure.message ,
          ),
        );
      },
      (plansResponse) {
        discountResult.fold(
          (failure) {
            emit(
              GetAllPlanFailure(
                errorMessage: failure.message ,
              ),
            );
          },
          (discounts) {
            emit(
              GetAllPlanSuccess(
                plansResponse: plansResponse,
                discounts: discounts,
              ),
            );
          },
        );
      },
    );
  }
}
