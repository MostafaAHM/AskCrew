import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_request.dart';
import '../model/watermark_charge_model.dart';
import 'watermark_payment_repository.dart';

class WatermarkPaymentRepositoryImpl extends WatermarkPaymentRepository {
  @override
  Future<Either<CustomException, WatermarkChargeModel>> createWatermarkCharge({
    bool? usePoints,
  }) async {
    return exceptionHandler(() async {
      final Map<String, dynamic> data = {};
      if (usePoints != null && usePoints == true) {
        data['use_points'] = "1";
      }

      final response = await dioService.callApi(
        NetworkRequest(
          AppUrls.watermarkPayment,
          method: RequestMethod.post,
          isFormData: true,
          formDataBody: data.isNotEmpty ? FormData.fromMap(data) : null,
        ),
        mapper: (json) => WatermarkChargeModel.fromJson(json),
      );
      return response;
    });
  }
}
