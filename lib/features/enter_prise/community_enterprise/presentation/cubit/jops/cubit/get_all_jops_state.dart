part of 'get_all_jops_cubit.dart';

sealed class GetAllJopsState extends Equatable {
  const GetAllJopsState();

  @override
  List<Object> get props => [];
}

final class GetAllJopsInitial extends GetAllJopsState {}

final class GetAllJopsLoading extends GetAllJopsState {}

final class GetAllJopsSuccess extends GetAllJopsState {
  final JobsResponseModel jobsResponseModel;

  const GetAllJopsSuccess(this.jobsResponseModel);

  @override
  List<Object> get props => [jobsResponseModel];
}

final class GetAllJopsFailure extends GetAllJopsState {
  final CustomException exception;

  const GetAllJopsFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

// Create Job States

final class CreateJobInitial extends GetAllJopsState {}

final class CreateJobLoading extends GetAllJopsState {}

final class CreateJobSuccess extends GetAllJopsState {
  final BaseResponseModel responseModel;

  const CreateJobSuccess(this.responseModel);

  @override
  List<Object> get props => [responseModel];
}

final class CreateJobFailure extends GetAllJopsState {
  final CustomException exception;

  const CreateJobFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

// Update Job States

final class UpdateJobInitial extends GetAllJopsState {}

final class UpdateJobLoading extends GetAllJopsState {}

final class UpdateJobSuccess extends GetAllJopsState {
  final BaseResponseModel responseModel;

  const UpdateJobSuccess(this.responseModel);

  @override
  List<Object> get props => [responseModel];
}

final class UpdateJobFailure extends GetAllJopsState {
  final CustomException exception;

  const UpdateJobFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

// Delete Job States

final class DeleteJobInitial extends GetAllJopsState {}

final class DeleteJobLoading extends GetAllJopsState {}

final class DeleteJobSuccess extends GetAllJopsState {
  final BaseResponseModel responseModel;

  const DeleteJobSuccess(this.responseModel);

  @override
  List<Object> get props => [responseModel];
}

final class DeleteJobFailure extends GetAllJopsState {
  final CustomException exception;

  const DeleteJobFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

// Accept Job Application States

final class AcceptJobApplicationInitial extends GetAllJopsState {}

final class AcceptJobApplicationLoading extends GetAllJopsState {}

final class AcceptJobApplicationSuccess extends GetAllJopsState {
  final BaseResponseModel responseModel;

  const AcceptJobApplicationSuccess(this.responseModel);

  @override
  List<Object> get props => [responseModel];
}

final class AcceptJobApplicationFailure extends GetAllJopsState {
  final CustomException exception;

  const AcceptJobApplicationFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

// Reject Job Application States

final class RejectJobApplicationInitial extends GetAllJopsState {}

final class RejectJobApplicationLoading extends GetAllJopsState {}

final class RejectJobApplicationSuccess extends GetAllJopsState {
  final BaseResponseModel responseModel;

  const RejectJobApplicationSuccess(this.responseModel);

  @override
  List<Object> get props => [responseModel];
}

final class RejectJobApplicationFailure extends GetAllJopsState {
  final CustomException exception;

  const RejectJobApplicationFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

// Apply to Job States

final class ApplyToJobInitial extends GetAllJopsState {}

final class ApplyToJobLoading extends GetAllJopsState {}

final class ApplyToJobSuccess extends GetAllJopsState {
  final BaseResponseModel responseModel;

  const ApplyToJobSuccess(this.responseModel);

  @override
  List<Object> get props => [responseModel];
}

final class ApplyToJobFailure extends GetAllJopsState {
  final CustomException exception;

  const ApplyToJobFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

// Get Job Applications States

final class GetJobApplicationsInitial extends GetAllJopsState {}

final class GetJobApplicationsLoading extends GetAllJopsState {}

final class GetJobApplicationsSuccess extends GetAllJopsState {
  final JobApplicationsResponseModel applicationsResponse;

  const GetJobApplicationsSuccess(this.applicationsResponse);

  @override
  List<Object> get props => [applicationsResponse];
}

final class GetJobApplicationsFailure extends GetAllJopsState {
  final CustomException exception;

  const GetJobApplicationsFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

// Rate User States

final class RateUserInitial extends GetAllJopsState {}

final class RateUserLoading extends GetAllJopsState {}

final class RateUserSuccess extends GetAllJopsState {
  final String message;

  const RateUserSuccess(this.message);

  @override
  List<Object> get props => [message];
}

final class RateUserFailure extends GetAllJopsState {
  final CustomException exception;

  const RateUserFailure(this.exception);

  @override
  List<Object> get props => [exception];
}
