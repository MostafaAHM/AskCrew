import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';

abstract class ChangePasswordRepository {
  Future<Either<CustomException, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}

