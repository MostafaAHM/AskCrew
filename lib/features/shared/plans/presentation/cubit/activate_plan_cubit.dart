import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/activate_plan_request_model.dart';
import '../../data/repo/activate_plan_repository.dart';
import 'activate_plan_state.dart';

class ActivatePlanCubit extends Cubit<ActivatePlanState> {
  final ActivatePlanRepository repository;

  ActivatePlanCubit(this.repository) : super(ActivatePlanInitial());

  Future<void> activatePlan({
    required String planId,
    required int durationMonths,
  }) async {
    emit(ActivatePlanLoading());
    final result = await repository.activatePlan(
      ActivatePlanRequestModel(
        planId: planId,
        durationMonths: durationMonths,
      ),
    );

    result.fold(
      (error) => emit(ActivatePlanError(error.message)),
      (response) => emit(ActivatePlanSuccess(response)),
    );
  }
}
