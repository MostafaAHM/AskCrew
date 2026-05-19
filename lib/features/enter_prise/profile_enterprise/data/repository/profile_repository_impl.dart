import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../core/app_config/prefs_keys.dart';
import '../../../../../core/helpers/secure_local_storage.dart';
import '../../../../../core/helpers/user_helper.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../auth/login/data/model/response/user_model.dart';
import '../../../../auth/login/data/model/response/profile_model.dart';
import '../../../../auth/login/data/model/response/paginated_profiles_response_model.dart';
import '../models/transaction_model.dart';
import '../models/user_stats_model.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl extends ProfileRepository {
  @override
  Future<Either<CustomException, UserModel>> getUserProfile({
    required int userId,
  }) async {
    final result = await exceptionHandler(() async {
      final response = await dioService.callApi(
        NetworkRequest(
          AppUrls.getUserProfile(userId),
          method: RequestMethod.get,
        ),
        mapper: (json) {
          if (json is Map<String, dynamic>) {
            return UserModel.fromJson(json);
          } else if (json is Map) {
            return UserModel.fromJson(Map<String, dynamic>.from(json));
          } else {
            throw Exception('Invalid response format');
          }
        },
      );

      return response;
    });

    return result;
  }

  @override
  Future<Either<CustomException, UserModel>> getMyProfile() async {
    final result = await exceptionHandler(() async {
      final response = await dioService.callApi(
        NetworkRequest(AppUrls.getMyProfile, method: RequestMethod.get),
        mapper: (json) {
          if (json is Map<String, dynamic>) {
            return UserModel.fromJson(json);
          } else if (json is Map) {
            return UserModel.fromJson(Map<String, dynamic>.from(json));
          } else {
            throw Exception('Invalid response format');
          }
        },
      );

      return response;
    });

    return result;
  }

  @override
  Future<Either<CustomException, PaginatedProfilesResponseModel>>
  getAllProfiles({
    int? page,
    int? pageSize,
    String? type,
    String? name,
    String? email,
    String? phone,
    String? fullname,
    bool? isActive,
    bool? isVerified,
    String? studentSpecification,
    String? enterpriseSpecification,
  }) async {
    final result = await exceptionHandler(() async {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (pageSize != null) queryParams['page_size'] = pageSize;
      if (type != null) queryParams['type'] = type;
      if (name != null && name.isNotEmpty) queryParams['name'] = name;
      if (email != null && email.isNotEmpty) queryParams['email'] = email;
      if (phone != null && phone.isNotEmpty) queryParams['phone'] = phone;
      if (fullname != null && fullname.isNotEmpty) {
        queryParams['fullname'] = fullname;
      }
      if (isActive != null) queryParams['is_active'] = isActive;
      if (isVerified != null) queryParams['is_verified'] = isVerified;
      if (studentSpecification != null && studentSpecification.isNotEmpty) {
        queryParams['student_specification'] = studentSpecification;
      }
      if (enterpriseSpecification != null &&
          enterpriseSpecification.isNotEmpty) {
        queryParams['enterprise_specification'] = enterpriseSpecification;
      }

      final response = await dioService.callApi(
        NetworkRequest(
          AppUrls.getAllProfiles,
          method: RequestMethod.get,
          queryParameters: queryParams.isNotEmpty ? queryParams : null,
        ),
        mapper: (json) {
          if (json is Map<String, dynamic>) {
            return PaginatedProfilesResponseModel.fromJson(json);
          } else if (json is Map) {
            return PaginatedProfilesResponseModel.fromJson(
              Map<String, dynamic>.from(json),
            );
          } else {
            throw Exception('Invalid response format');
          }
        },
      );

      return response;
    });

    return result;
  }

  @override
  Future<Either<CustomException, TransactionsResponse>> getMyPayments({
    int? page,
    int? pageSize,
  }) async {
    final result = await exceptionHandler(() async {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (pageSize != null) queryParams['page_size'] = pageSize;

      final response = await dioService.callApi(
        NetworkRequest(
          AppUrls.getMyPayments,
          method: RequestMethod.get,
          queryParameters: queryParams.isNotEmpty ? queryParams : null,
        ),
        mapper: (json) {
          if (json is Map<String, dynamic>) {
            return TransactionsResponse.fromJson(json);
          } else if (json is Map) {
            return TransactionsResponse.fromJson(
              Map<String, dynamic>.from(json),
            );
          } else {
            throw Exception('Invalid response format');
          }
        },
      );

      return response;
    });

    return result;
  }

  @override
  Future<Either<CustomException, UserStatsModel>> getMyStats() async {
    final result = await exceptionHandler(() async {
      final response = await dioService.callApi(
        NetworkRequest(
          AppUrls.getMyStats, // Make sure AppUrls is updated
          method: RequestMethod.get,
        ),
        mapper: (json) {
          if (json is Map<String, dynamic>) {
            return UserStatsModel.fromJson(json);
          } else if (json is Map) {
            return UserStatsModel.fromJson(Map<String, dynamic>.from(json));
          } else {
            throw Exception('Invalid response format');
          }
        },
      );

      return response;
    });

    return result;
  }

  @override
  Future<Either<CustomException, UserModel>> updateProfile({
    required String fullname,
    File? profilePhoto,
    String? personalInfo,
    required bool isAvailable,
  }) async {
    final result = await exceptionHandler(() async {
      final Map<String, dynamic> data = {
        'fullname': fullname,
        'is_available': isAvailable.toString(),
      };

      if (personalInfo != null) {
        data['personal_info'] = personalInfo;
      }

      if (profilePhoto != null) {
        data['profile_photo'] = await MultipartFile.fromFile(
          profilePhoto.path,
          filename: profilePhoto.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(data);

      final response = await dioService.callApi(
        NetworkRequest(
          AppUrls.updateProfile,
          method: RequestMethod.patch,
          isFormData: true,
          formDataBody: formData,
        ),
        mapper: (json) {
          if (json['user'] != null) {
            return UserModel.fromJson(json['user']);
          }
          return UserModel.fromJson(json);
        },
      );

      UserModel updatedUser = response;
      final currentUser = UserHelper.userNotifier.value;

      if (currentUser != null) {
        ProfileModel? mergedProfile = updatedUser.profile;

        if (mergedProfile == null) {
          mergedProfile = currentUser.profile;
        } else if (currentUser.profile != null) {
          final oldProfile = currentUser.profile!;
          mergedProfile = mergedProfile.copyWith(
            favoriteCategories:
                (mergedProfile.favoriteCategories.isEmpty &&
                    oldProfile.favoriteCategories.isNotEmpty)
                ? oldProfile.favoriteCategories
                : mergedProfile.favoriteCategories,
            images:
                (mergedProfile.images == null || mergedProfile.images!.isEmpty)
                ? oldProfile.images
                : mergedProfile.images,
            videos:
                (mergedProfile.videos == null || mergedProfile.videos!.isEmpty)
                ? oldProfile.videos
                : mergedProfile.videos,
            views: mergedProfile.views ?? oldProfile.views,
          );
        }

        updatedUser = updatedUser.copyWith(
          profile: mergedProfile,
          ratingMean: (updatedUser.ratingMean == null)
              ? currentUser.ratingMean
              : updatedUser.ratingMean,
          wallet: (updatedUser.wallet == '0.00' && currentUser.wallet != '0.00')
              ? currentUser.wallet
              : updatedUser.wallet,
          points: (updatedUser.points == 0 && currentUser.points != 0)
              ? currentUser.points
              : updatedUser.points,
        );
      }

      await SecureLocalStorage.write(
        PrefsKeys.user,
        jsonEncode(updatedUser.toJson()),
      );

      UserHelper.setUser(updatedUser);

      return updatedUser;
    });

    return result;
  }
}
