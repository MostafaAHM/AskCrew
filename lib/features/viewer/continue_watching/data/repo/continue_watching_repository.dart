import 'package:dartz/dartz.dart';
import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/repository/repository.dart';
import '../models/continue_watching_item_model.dart';
import '../models/continue_watching_request_model.dart';

abstract class ContinueWatchingRepository extends Repository {
  Future<Either<CustomException, List<ContinueWatchingItemModel>>>
  getContinueWatching();
  Future<Either<CustomException, void>> updateContinueWatching({
    required UpdateContinueWatchingRequest request,
  });
}
