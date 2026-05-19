import 'package:aflam/core/app_config/app_urls.dart';
import 'package:aflam/core/models/base_response_model.dart';
import 'package:aflam/core/network/network_request.dart';
import 'package:aflam/features/auth/enterprise/enterprise_auth_flow/data/models/response/enterprise_onboarding_data.dart';
import 'package:dartz/dartz.dart';

import '../../../../../../core/error/exceptions.dart';
import '../model/student_request_model.dart';
import 'student_repository.dart';

class StudentRepositoryImpl extends StudentRepository {
  @override
  Future<Either<CustomException, BaseResponseModel>> registerStudent({
    required StudentRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      BaseResponseModel response = await dioService.callApi(
        NetworkRequest(
          AppUrls.studentSignup,
          method: RequestMethod.post,
          isFormData: true,
          formDataBody: await model.toFormData(),
          requestWithOutToken: true,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );
      return response;
    });
    return result;
  }

  @override
  Future<Either<CustomException, BaseResponseModel>> completeStudentProfile({
    required StudentRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      BaseResponseModel response = await dioService.callApi(
        NetworkRequest(
          AppUrls.completeStudentProfile,
          method: RequestMethod.post,
          isFormData: true,
          formDataBody: await model.toCompleteProfileFormData(),
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );
      return response;
    });
    return result;
  }

  @override
  Future<Either<CustomException, Map<String, List<String>>>>
  getSpecifications() async {
    final result = await exceptionHandler(() async {
      final jsonResponse = await dioService.callApi(
        NetworkRequest(AppUrls.specifications, method: RequestMethod.get),
        mapper: (json) => json,
      );

      // Extract the map from the response
      Map<String, dynamic> data = jsonResponse;
      if (jsonResponse is Map<String, dynamic>) {
        if (jsonResponse.containsKey('data')) {
          data = jsonResponse['data'] as Map<String, dynamic>;
        } else if (jsonResponse.containsKey('response')) {
          data = jsonResponse['response'] as Map<String, dynamic>;
        }
      }

      final Map<String, List<String>> specifications = {};
      data.forEach((key, value) {
        if (value is List) {
          specifications[key] = value.map((e) => e.toString()).toList();
        }
      });

      return specifications;
    });
    return result;
  }

  @override
  Future<Either<CustomException, List<ContentCatalogItem>>>
  searchContentCatalog(String query, {String? type}) async {
    final result = await exceptionHandler(() async {
      final queryParams = <String, dynamic>{'q': query};
      if (type != null) queryParams['type'] = type;

      final jsonResponse = await dioService.callApi(
        NetworkRequest(
          AppUrls.contentCatalogSearch,
          method: RequestMethod.get,
          queryParameters: queryParams,
        ),
        mapper: (json) => json,
      );

      List<dynamic> dataList = [];
      if (jsonResponse is Map<String, dynamic>) {
        final data = jsonResponse['data'] ?? jsonResponse['response'] ?? [];
        if (data is List) {
          dataList = data;
        }
      } else if (jsonResponse is List) {
        dataList = jsonResponse;
      }

      return dataList
          .map((e) => ContentCatalogItem.fromJson(e as Map<String, dynamic>))
          .toList();
    });
    return result;
  }
}
