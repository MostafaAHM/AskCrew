import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/repository/repository.dart';
import '../model/watermark_charge_model.dart';

abstract class WatermarkPaymentRepository extends Repository {
  Future<Either<CustomException, WatermarkChargeModel>> createWatermarkCharge({
    bool? usePoints,
  });
}
