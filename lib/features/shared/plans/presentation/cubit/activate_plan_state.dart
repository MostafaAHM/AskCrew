import '../../data/model/activate_plan_request_model.dart';

abstract class ActivatePlanState {}

class ActivatePlanInitial extends ActivatePlanState {}

class ActivatePlanLoading extends ActivatePlanState {}

class ActivatePlanSuccess extends ActivatePlanState {
  final ActivatePlanResponseModel response;
  ActivatePlanSuccess(this.response);
}

class ActivatePlanError extends ActivatePlanState {
  final String message;
  ActivatePlanError(this.message);
}
