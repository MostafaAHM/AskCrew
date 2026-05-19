import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../../core/app_config/app_urls.dart';
import '../../../../../../core/app_config/prefs_keys.dart';
import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/helpers/secure_local_storage.dart';
import '../../../../../../core/helpers/user_helper.dart';
import '../../../../../../core/network/network_request.dart';
import 'package:aflam/features/auth/login/data/model/response/user_model.dart';
import '../../../../auth/login/data/model/response/profile_model.dart';
import 'student_profile_repository.dart';

class StudentProfileRepositoryImpl extends StudentProfileRepository {
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
