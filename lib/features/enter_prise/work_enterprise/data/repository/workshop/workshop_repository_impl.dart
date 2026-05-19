import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../../core/app_config/app_urls.dart';
import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/network/network_request.dart';
import '../../../../../../core/repository/repository.dart';
import '../../models/request/create_workshop_request_model.dart';
import '../../models/response/workshop_list_response_model.dart';
import '../../models/response/workshop_registration_model.dart';
import '../../models/response/workshop_response_model.dart';
import 'workshop_repository.dart';

class WorkshopRepositoryImpl extends Repository implements WorkshopRepository {
  @override
  Future<Either<CustomException, WorkshopListResponseModel>> getWorkshops({
    int? page,
    int? pageSize,
  }) async {
    final result = await exceptionHandler(
      () async {
        final queryParams = <String, dynamic>{};
        if (page != null) queryParams['page'] = page;
        if (pageSize != null) queryParams['page_size'] = pageSize;

        final WorkshopListResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.getWorkshops,
            method: RequestMethod.get,
            queryParameters: queryParams.isNotEmpty ? queryParams : null,
          ),
          mapper: (json) => WorkshopListResponseModel.fromJson(json),
        );

        return response;
      },
    );
    return result;
  }

  @override
  Future<Either<CustomException, WorkshopListResponseModel>> getMyWorkshops({
    int? page,
    int? pageSize,
  }) async {
    final result = await exceptionHandler(
      () async {
        final queryParams = <String, dynamic>{};
        if (page != null) queryParams['page'] = page;
        if (pageSize != null) queryParams['page_size'] = pageSize;

        final WorkshopListResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.getMyWorkshops,
            method: RequestMethod.get,
            queryParameters: queryParams.isNotEmpty ? queryParams : null,
          ),
          mapper: (json) => WorkshopListResponseModel.fromJson(json),
        );

        return response;
      },
    );
    return result;
  }

  @override
  Future<Either<CustomException, WorkshopResponseModel>> getWorkshopById({
    required int id,
  }) async {
    final result = await exceptionHandler(
      () async {
        final WorkshopResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.getWorkshopById(id),
            method: RequestMethod.get,
          ),
          mapper: (json) => WorkshopResponseModel.fromJson(json),
        );

        return response;
      },
    );
    return result;
  }

  @override
  Future<Either<CustomException, WorkshopResponseModel>> createWorkshop({
    required CreateWorkshopRequestModel model,
  }) async {
    final result = await exceptionHandler(
      () async {
        final formData = await model.toFormData();
        
        final WorkshopResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.createWorkshop,
            method: RequestMethod.post,
            formDataBody: formData,
            isFormData: true,
          ),
          mapper: (json) => WorkshopResponseModel.fromJson(json),
        );

        return response;
      },
    );
    return result;
  }

  @override
  Future<Either<CustomException, WorkshopResponseModel>> updateWorkshop({
    required int id,
    required CreateWorkshopRequestModel model,
  }) async {
    final result = await exceptionHandler(
      () async {
        final formData = await model.toFormData();
        
        final WorkshopResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.updateWorkshop(id),
            method: RequestMethod.patch,
            formDataBody: formData,
            isFormData: true,
          ),
          mapper: (json) => WorkshopResponseModel.fromJson(json),
        );

        return response;
      },
    );
    return result;
  }

  @override
  Future<Either<CustomException, void>> deleteWorkshop({
    required int id,
  }) async {
    final result = await exceptionHandler(
      () async {
        await dioService.callApi(
          NetworkRequest(
            AppUrls.deleteWorkshop(id),
            method: RequestMethod.delete,
          ),
          mapper: (json) => null,
        );

        return;
      },
    );
    return result;
  }

  @override
  Future<Either<CustomException, WorkshopResponseModel>> applyToWorkshop({
    required int workshopId,
  }) async {
    final result = await exceptionHandler(
      () async {
        final WorkshopResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.applyToWorkshop,
            method: RequestMethod.post,
            body: {'workshop': workshopId},
          ),
          mapper: (json) => WorkshopResponseModel.fromJson(json),
        );

        return response;
      },
    );
    return result;
  }

  @override
  Future<Either<CustomException, WorkshopResponseModel>> approveWorkshopRegistration({
    required int registrationId,
  }) async {
    final result = await exceptionHandler(
      () async {
        final WorkshopResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.approveWorkshopRegistration(registrationId),
            method: RequestMethod.post,
          ),
          mapper: (json) => WorkshopResponseModel.fromJson(json),
        );

        return response;
      },
    );
    return result;
  }

  @override
  Future<Either<CustomException, WorkshopResponseModel>> rejectWorkshopRegistration({
    required int registrationId,
  }) async {
    final result = await exceptionHandler(
      () async {
        final WorkshopResponseModel response = await dioService.callApi(
          NetworkRequest(
            AppUrls.rejectWorkshopRegistration(registrationId),
            method: RequestMethod.post,
          ),
          mapper: (json) => WorkshopResponseModel.fromJson(json),
        );

        return response;
      },
    );
    return result;
  }

  @override
  Future<Either<CustomException, List<WorkshopRegistrationModel>>> getWorkshopRegistrations({
    required int workshopId,
  }) async {
    final result = await exceptionHandler(
      () async {
        final dynamic response = await dioService.callApi(
          NetworkRequest(
            AppUrls.getWorkshopRegistrations(workshopId),
            method: RequestMethod.get,
          ),
          mapper: (json) => json,
        );

        List<dynamic> results = [];
        
        // Handle paginated response (Map with 'results' key)
        if (response is Map<String, dynamic>) {
          results = response['results'] as List<dynamic>? ?? [];
        } 
        // Handle direct list response
        else if (response is List<dynamic>) {
          results = response;
        }

        final registrations = results
            .map((e) => WorkshopRegistrationModel.fromJson(e as Map<String, dynamic>))
            .toList();

        return registrations;
      },
    );
    return result;
  }

  @override
  Future<Either<CustomException, void>> rateUser({
    required int toUserId,
    required int rating,
  }) async {
    final result = await exceptionHandler(
      () async {
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
      },
    );
    return result;
  }
}

