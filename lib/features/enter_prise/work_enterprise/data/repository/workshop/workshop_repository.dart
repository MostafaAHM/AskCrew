import 'package:dartz/dartz.dart';
import '../../../../../../core/error/exceptions.dart';
import '../../models/request/create_workshop_request_model.dart';
import '../../models/response/workshop_list_response_model.dart';
import '../../models/response/workshop_registration_model.dart';
import '../../models/response/workshop_response_model.dart';

abstract class WorkshopRepository {
  Future<Either<CustomException, WorkshopListResponseModel>> getWorkshops({
    int? page,
    int? pageSize,
  });

  Future<Either<CustomException, WorkshopListResponseModel>> getMyWorkshops({
    int? page,
    int? pageSize,
  });

  Future<Either<CustomException, WorkshopResponseModel>> getWorkshopById({
    required int id,
  });

  Future<Either<CustomException, WorkshopResponseModel>> createWorkshop({
    required CreateWorkshopRequestModel model,
  });

  Future<Either<CustomException, WorkshopResponseModel>> updateWorkshop({
    required int id,
    required CreateWorkshopRequestModel model,
  });

  Future<Either<CustomException, void>> deleteWorkshop({
    required int id,
  });

  Future<Either<CustomException, WorkshopResponseModel>> applyToWorkshop({
    required int workshopId,
  });

  Future<Either<CustomException, WorkshopResponseModel>> approveWorkshopRegistration({
    required int registrationId,
  });

  Future<Either<CustomException, WorkshopResponseModel>> rejectWorkshopRegistration({
    required int registrationId,
  });

  Future<Either<CustomException, List<WorkshopRegistrationModel>>> getWorkshopRegistrations({
    required int workshopId,
  });

  Future<Either<CustomException, void>> rateUser({
    required int toUserId,
    required int rating,
  });
}

