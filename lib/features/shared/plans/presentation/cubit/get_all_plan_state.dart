part of 'get_all_plan_cubit.dart';

sealed class GetAllPlanState extends Equatable {
  const GetAllPlanState();

  @override
  List<Object> get props => [];
}

final class GetAllPlanInitial extends GetAllPlanState {}

final class GetAllPlanLoading extends GetAllPlanState {}

final class GetAllPlanSuccess extends GetAllPlanState {
  final SubscriptionPlansResponse plansResponse;
  final PlanDiscountsModel discounts;

  const GetAllPlanSuccess({
    required this.plansResponse,
    required this.discounts,
  });

  @override
  List<Object> get props => [plansResponse, discounts];
}

final class GetAllPlanFailure extends GetAllPlanState {
  final String errorMessage;

  const GetAllPlanFailure({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
