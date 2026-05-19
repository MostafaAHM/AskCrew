import '../../data/models/response/student_onboarding_data.dart';

abstract class StudentOnboardingState {}

class StudentOnboardingInitial extends StudentOnboardingState {}

class StudentOnboardingInProgress extends StudentOnboardingState {
  final int currentStep;
  final StudentOnboardingData data;

  StudentOnboardingInProgress({required this.currentStep, required this.data});
}

class StudentOnboardingLoading extends StudentOnboardingState {}

class StudentOnboardingSuccess extends StudentOnboardingState {
  final String message;
  final String? paymentUrl;

  StudentOnboardingSuccess(this.message, {this.paymentUrl});
}

class StudentOnboardingFailure extends StudentOnboardingState {
  final String message;

  StudentOnboardingFailure(this.message);
}
