import '../../data/models/response/enterprise_onboarding_data.dart';

abstract class EnterpriseOnboardingState {}

class EnterpriseOnboardingInitial extends EnterpriseOnboardingState {}

class EnterpriseOnboardingInProgress extends EnterpriseOnboardingState {
  final int currentStep;
  final EnterpriseOnboardingData data;

  EnterpriseOnboardingInProgress({
    required this.currentStep,
    required this.data,
  });
}

class EnterpriseOnboardingLoading extends EnterpriseOnboardingState {}

class EnterpriseOnboardingSuccess extends EnterpriseOnboardingState {
  final String message;
  final String? paymentUrl;

  EnterpriseOnboardingSuccess(this.message, {this.paymentUrl});
}

class EnterpriseOnboardingFailure extends EnterpriseOnboardingState {
  final String message;

  EnterpriseOnboardingFailure(this.message);
}
