import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/repository/repository.dart';
import '../../../../auth/login/data/model/response/user_model.dart';
import '../../../../auth/login/data/model/response/paginated_profiles_response_model.dart';
import '../models/transaction_model.dart';
import '../models/user_stats_model.dart';

abstract class ProfileRepository extends Repository {
  Future<Either<CustomException, UserModel>> getUserProfile({
    required int userId,
  });

  Future<Either<CustomException, UserModel>> getMyProfile();

  Future<Either<CustomException, PaginatedProfilesResponseModel>>
  getAllProfiles({
    int? page,
    int? pageSize,
    String? type, // Filter by user type: 'enterprise', 'student', 'viewer'
    String? name,
    String? email,
    String? phone,
    String? fullname,
    bool? isActive,
    bool? isVerified,
    String? studentSpecification,
    String? enterpriseSpecification,
  });

  Future<Either<CustomException, TransactionsResponse>> getMyPayments({
    int? page,
    int? pageSize,
  });

  Future<Either<CustomException, UserStatsModel>> getMyStats();

  Future<Either<CustomException, UserModel>> updateProfile({
    required String fullname,
    File? profilePhoto,
    String? personalInfo,
    required bool isAvailable,
  });
}
