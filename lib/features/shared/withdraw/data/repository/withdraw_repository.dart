import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../model/collect_request_model.dart';

abstract class WithdrawRepository {
  Future<Either<CustomException, CollectRequestModel>> createCollectRequest({
    required int amount,
    required String source, // 'wallet' | 'points'
  });

  Future<Either<CustomException, CollectRequestsResponse>> getCollectRequests();
}
