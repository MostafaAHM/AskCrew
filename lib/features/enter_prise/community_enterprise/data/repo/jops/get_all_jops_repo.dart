import 'package:aflam/core/models/base_response_model.dart';
import 'package:dartz/dartz.dart';

import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/repository/repository.dart';
import '../../model/jops/request/create_job_request_model.dart';
import '../../model/jops/response/job_application_model.dart';
import '../../model/jops/response/job_list_response_model.dart';

abstract class GetAllJopsRepo extends Repository {
  Future<Either<CustomException, JobsResponseModel>> getAllJops({
    String? filter,
  });
  Future<Either<CustomException, BaseResponseModel>> deleteJob({
    required int jobId,
  });
  Future<Either<CustomException, BaseResponseModel>> createJob({
    required CreateJobRequestModel model,
  });
  Future<Either<CustomException, BaseResponseModel>> updateJob({
    required int jobId,
    required CreateJobRequestModel model,
  });
  Future<Either<CustomException, BaseResponseModel>> acceptJobApplication({
    required int applicationId,
  });
  Future<Either<CustomException, BaseResponseModel>> rejectJobApplication({
    required int applicationId,
  });
  Future<Either<CustomException, BaseResponseModel>> applyToJob({
    required int jobId,
  });
  Future<Either<CustomException, JobApplicationsResponseModel>>
  getJobApplications({required int jobId});
  Future<Either<CustomException, void>> rateUser({
    required int toUserId,
    required int rating,
  });
}
