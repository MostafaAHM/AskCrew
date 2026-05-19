import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';

abstract class DeleteAccountRepository {
  Future<Either<CustomException, void>> deleteAccount();
}

