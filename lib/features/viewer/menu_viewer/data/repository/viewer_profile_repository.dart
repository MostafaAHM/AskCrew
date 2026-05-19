import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../../../core/error/exceptions.dart';
import 'package:aflam/features/auth/login/data/model/response/user_model.dart';
import '../../../../../../core/repository/repository.dart';

abstract class ViewerProfileRepository extends Repository {
  Future<Either<CustomException, UserModel>> updateProfile({
    required String fullname,
    File? profilePhoto,
    String? personalInfo,
    required bool isAvailable,
  });
}
