import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../../core/error/exceptions.dart';
import '../../../../../../../core/models/base_response_model.dart';
import '../../../../data/model/jops/request/create_job_request_model.dart';
import '../../../../data/model/jops/response/job_application_model.dart';
import '../../../../data/model/jops/response/job_list_response_model.dart';
import '../../../../data/repo/jops/get_all_jops_repo.dart';

part 'get_all_jops_state.dart';

class GetAllJopsCubit extends Cubit<GetAllJopsState> {
  final GetAllJopsRepo repo;

  GetAllJopsCubit(this.repo) : super(GetAllJopsInitial());

  // Helper emit that avoids "Cannot emit after close" exceptions
  void safeEmit(GetAllJopsState state) {
    if (!isClosed) emit(state);
  }

  Future<void> getAllJops({String? filter}) async {
    safeEmit(GetAllJopsLoading());

    final result = await repo.getAllJops(filter: filter);

    if (isClosed) return;

    result.fold(
      (exception) => safeEmit(GetAllJopsFailure(exception)),
      (jobsResponseModel) => safeEmit(GetAllJopsSuccess(jobsResponseModel)),
    );
  }

  Future<void> createJob({required CreateJobRequestModel model}) async {
    safeEmit(CreateJobLoading());

    final result = await repo.createJob(model: model);

    if (isClosed) return;

    result.fold(
      (exception) => safeEmit(CreateJobFailure(exception)),
      (responseModel) => safeEmit(CreateJobSuccess(responseModel)),
    );
  }

  Future<void> updateJob({
    required int jobId,
    required CreateJobRequestModel model,
  }) async {
    safeEmit(UpdateJobLoading());

    final result = await repo.updateJob(jobId: jobId, model: model);

    if (isClosed) return;

    result.fold(
      (exception) => safeEmit(UpdateJobFailure(exception)),
      (responseModel) => safeEmit(UpdateJobSuccess(responseModel)),
    );
  }

  Future<void> deleteJob({required int jobId}) async {
    safeEmit(DeleteJobLoading());

    final result = await repo.deleteJob(jobId: jobId);

    if (isClosed) return;

    result.fold(
      (exception) => safeEmit(DeleteJobFailure(exception)),
      (responseModel) => safeEmit(DeleteJobSuccess(responseModel)),
    );
  }

  Future<void> acceptJobApplication({required int applicationId}) async {
    safeEmit(AcceptJobApplicationLoading());

    final result = await repo.acceptJobApplication(
      applicationId: applicationId,
    );

    if (isClosed) return;

    result.fold(
      (exception) => safeEmit(AcceptJobApplicationFailure(exception)),
      (responseModel) => safeEmit(AcceptJobApplicationSuccess(responseModel)),
    );
  }

  Future<void> rejectJobApplication({required int applicationId}) async {
    safeEmit(RejectJobApplicationLoading());

    final result = await repo.rejectJobApplication(
      applicationId: applicationId,
    );

    if (isClosed) return;

    result.fold(
      (exception) => safeEmit(RejectJobApplicationFailure(exception)),
      (responseModel) => safeEmit(RejectJobApplicationSuccess(responseModel)),
    );
  }

  Future<void> applyToJob({required int jobId}) async {
    safeEmit(ApplyToJobLoading());

    final result = await repo.applyToJob(jobId: jobId);

    if (isClosed) return;

    result.fold(
      (exception) => safeEmit(ApplyToJobFailure(exception)),
      (responseModel) => safeEmit(ApplyToJobSuccess(responseModel)),
    );
  }

  Future<void> getJobApplications({required int jobId}) async {
    safeEmit(GetJobApplicationsLoading());

    final result = await repo.getJobApplications(jobId: jobId);

    if (isClosed) return;

    result.fold(
      (exception) => safeEmit(GetJobApplicationsFailure(exception)),
      (applicationsResponse) =>
          safeEmit(GetJobApplicationsSuccess(applicationsResponse)),
    );
  }

  Future<void> rateUser({required int toUserId, required int rating}) async {
    final result = await repo.rateUser(toUserId: toUserId, rating: rating);

    if (isClosed) return;

    result.fold(
      (exception) => safeEmit(RateUserFailure(exception)),
      (_) => safeEmit(RateUserSuccess('Rating submitted successfully!')),
    );
  }
}
