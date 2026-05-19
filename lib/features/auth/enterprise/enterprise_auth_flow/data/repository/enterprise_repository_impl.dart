import 'package:aflam/core/app_config/app_urls.dart';
import 'package:aflam/core/models/base_response_model.dart';
import 'package:aflam/core/network/network_request.dart';
import 'package:aflam/features/auth/enterprise/enterprise_auth_flow/data/models/request/enterprise_requst_model.dart';
import 'package:aflam/features/auth/enterprise/enterprise_auth_flow/data/models/response/enterprise_onboarding_data.dart';
import 'package:dartz/dartz.dart';

import '../../../../../../core/error/exceptions.dart';
import 'enterprise_repository.dart';

class EnterpriseRepositoryImpl extends EnterpriseRepository {
  @override
  Future<Either<CustomException, BaseResponseModel>> registerEnterprise({
    required EnterpriseRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      final jsonResponse = await dioService.callApi(
        NetworkRequest(
          AppUrls.enterpriseSignup,
          method: RequestMethod.post,
          isFormData: true,
          formDataBody: await model.toFormData(),
          requestWithOutToken: true,
        ),
        mapper: (json) => json,
      );
      BaseResponseModel response = BaseResponseModel.fromJson(jsonResponse);
      return response;
    });
    return result;
  }

  @override
  Future<Either<CustomException, BaseResponseModel>> completeEnterpriseProfile({
    required EnterpriseRequestModel model,
  }) async {
    final result = await exceptionHandler(() async {
      BaseResponseModel response = await dioService.callApi(
        NetworkRequest(
          AppUrls.completeEnterpriseProfile,
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

  @override
  Future<Either<CustomException, BaseResponseModel>> addUserRole({
    required int contentId,
    required String role,
  }) async {
    final result = await exceptionHandler(() async {
      final jsonResponse = await dioService.callApi(
        NetworkRequest(
          AppUrls.addUserRole,
          method: RequestMethod.post,
          body: {'content_id': contentId, 'role': role},
        ),
        mapper: (json) => json,
      );
      BaseResponseModel response = BaseResponseModel.fromJson(jsonResponse);
      return response;
    });
    return result;
  }

  @override
  Future<Either<CustomException, BaseResponseModel>> deleteUserRole({
    required int roleId,
  }) async {
    final result = await exceptionHandler(() async {
      final url = AppUrls.deleteUserRole(roleId);
      print('📡 Calling DELETE API: $url');

      final jsonResponse = await dioService.callApi(
        NetworkRequest(url, method: RequestMethod.delete),
        mapper: (json) => json,
      );
      BaseResponseModel response = BaseResponseModel.fromJson(jsonResponse);
      return response;
    });
    return result;
  }
}
