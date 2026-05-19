import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';

abstract class DeleteAdvertiseRepository {
  Future<Either<CustomException, void>> deleteAdvertise({required int advertiseId});
}
