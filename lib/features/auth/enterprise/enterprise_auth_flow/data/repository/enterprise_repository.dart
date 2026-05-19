import 'package:dartz/dartz.dart';

import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/models/base_response_model.dart';
import '../../../../../../core/repository/repository.dart';
import '../models/request/enterprise_requst_model.dart';
import '../models/response/enterprise_onboarding_data.dart';

abstract class EnterpriseRepository extends Repository {
  Future<Either<CustomException, BaseResponseModel>> registerEnterprise({
    required EnterpriseRequestModel model,
  });

  Future<Either<CustomException, BaseResponseModel>> completeEnterpriseProfile({
    required EnterpriseRequestModel model,
  });

  Future<Either<CustomException, Map<String, List<String>>>>
  getSpecifications();

  Future<Either<CustomException, List<ContentCatalogItem>>>
  searchContentCatalog(String query, {String? type});

  Future<Either<CustomException, BaseResponseModel>> addUserRole({
    required int contentId,
    required String role,
  });

  Future<Either<CustomException, BaseResponseModel>> deleteUserRole({
    required int roleId,
  });
}
