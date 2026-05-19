import 'package:aflam/core/error/exceptions.dart';
import 'package:aflam/core/models/base_response_model.dart';
import 'package:aflam/features/enter_prise/community_enterprise/data/model/jops/request/create_job_request_model.dart';
import 'package:aflam/features/enter_prise/community_enterprise/data/model/jops/response/job_list_response_model.dart';
import 'package:aflam/features/enter_prise/community_enterprise/data/model/jops/response/job_application_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../../core/app_config/app_urls.dart';
import '../../../../../../core/network/network_request.dart';
import 'get_all_jops_repo.dart';

class GetAllJopsRepoImpl extends GetAllJopsRepo {
  @override
  Future<Either<CustomException, JobsResponseModel>> getAllJops({
    String? filter,
  }) async {
    final result = await exceptionHandler(() async {
      JobsResponseModel responseModel = await dioService.callApi(
        NetworkRequest(
          AppUrls.jobs,
          method: RequestMethod.get,
          requestWithOutToken: false,
          queryParameters: filter != null ? {'filter': filter} : null,
        ),
        mapper: (json) => JobsResponseModel.fromJson(json),
      );
      return responseModel;
    });
    return result;
  }

  @override
  Future<Either<CustomException, BaseResponseModel>> createJob({
    required CreateJobRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      BaseResponseModel responseModel = await dioService.callApi(
        NetworkRequest(
          AppUrls.createJob,
          method: RequestMethod.post,
          isFormData: true,
          formDataBody: await model.toFormData(),
          requestWithOutToken: false,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );

      return responseModel;
    });
    return result;
  }

  @override
  Future<Either<CustomException, BaseResponseModel>> deleteJob({
    required int jobId,
  }) async {
    final result = await exceptionHandler(() async {
      final raw = await dioService.callApi(
        NetworkRequest(
          AppUrls.deleteJobs(jobId),
          method: RequestMethod.delete,
          requestWithOutToken: false,
        ),
      );

      if (raw is Map<String, dynamic>) {
        return BaseResponseModel.fromJson(raw);
      }

      return BaseResponseModel(
        message: raw?.toString() ?? 'Deleted successfully',
        code: 204,
      );
    });
    return result;
  }

  @override
  Future<Either<CustomException, BaseResponseModel>> acceptJobApplication({
    required int applicationId,
  }) async {
    final result = await exceptionHandler(() async {
      final formData = FormData.fromMap({'status': 'accepted'});

      BaseResponseModel responseModel = await dioService.callApi(
        NetworkRequest(
          AppUrls.updateJobApplicationStatus(applicationId),
          method: RequestMethod.patch,
          isFormData: true,
          formDataBody: formData,
          requestWithOutToken: false,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );
      return responseModel;
    });
    return result;
  }

  @override
  Future<Either<CustomException, BaseResponseModel>> rejectJobApplication({
    required int applicationId,
  }) async {
    final result = await exceptionHandler(() async {
      final formData = FormData.fromMap({'status': 'rejected'});

      BaseResponseModel responseModel = await dioService.callApi(
        NetworkRequest(
          AppUrls.updateJobApplicationStatus(applicationId),
          method: RequestMethod.patch,
          isFormData: true,
          formDataBody: formData,
          requestWithOutToken: false,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );
      return responseModel;
    });
    return result;
  }

  @override
  Future<Either<CustomException, BaseResponseModel>> applyToJob({
    required int jobId,
  }) async {
    final result = await exceptionHandler(() async {
      final formData = FormData.fromMap({'job': jobId});

      BaseResponseModel responseModel = await dioService.callApi(
        NetworkRequest(
          AppUrls.applyToJob,
          method: RequestMethod.post,
          isFormData: true,
          formDataBody: formData,
          requestWithOutToken: false,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );
      return responseModel;
    });
    return result;
  }

  @override
  Future<Either<CustomException, JobApplicationsResponseModel>>
  getJobApplications({required int jobId}) async {
    final result = await exceptionHandler(() async {
      JobApplicationsResponseModel responseModel = await dioService.callApi(
        NetworkRequest(
          AppUrls.getJobApplications,
          method: RequestMethod.get,
          requestWithOutToken: false,
          queryParameters: {'job_id': jobId},
        ),
        mapper: (json) => JobApplicationsResponseModel.fromJson(json),
      );
      return responseModel;
    });
    return result;
  }

  @override
  Future<Either<CustomException, BaseResponseModel>> updateJob({
    required int jobId,
    required CreateJobRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      BaseResponseModel responseModel = await dioService.callApi(
        NetworkRequest(
          AppUrls.updateJob(jobId),
          method: RequestMethod.patch,
          isFormData: true,
          formDataBody: await model.toFormData(),
          requestWithOutToken: false,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );

      return responseModel;
    });
    return result;
  }

  @override
  Future<Either<CustomException, void>> rateUser({
    required int toUserId,
    required int rating,
  }) async {
    final result = await exceptionHandler(() async {
      final formData = FormData.fromMap({
        'to_user': toUserId,
        'rating': rating,
      });

      await dioService.callApi(
        NetworkRequest(
          AppUrls.rateUser,
          method: RequestMethod.post,
          formDataBody: formData,
          isFormData: true,
        ),
      );
    });
    return result;
  }
}
