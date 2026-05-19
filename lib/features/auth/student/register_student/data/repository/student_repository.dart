import 'package:dartz/dartz.dart';

import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/models/base_response_model.dart';
import '../../../../../../core/repository/repository.dart';
import '../../../../enterprise/enterprise_auth_flow/data/models/response/enterprise_onboarding_data.dart';
import '../model/student_request_model.dart';

abstract class StudentRepository extends Repository {
  Future<Either<CustomException, BaseResponseModel>> registerStudent({
    required StudentRequestModel model,
  });

  Future<Either<CustomException, BaseResponseModel>> completeStudentProfile({
    required StudentRequestModel model,
  });

  Future<Either<CustomException, Map<String, List<String>>>>
  getSpecifications();

  Future<Either<CustomException, List<ContentCatalogItem>>>
  searchContentCatalog(String query, {String? type});
}
