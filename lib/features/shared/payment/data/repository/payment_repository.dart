import 'package:dartz/dartz.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/models/base_response_model.dart';
import '../../../../../core/repository/repository.dart';
import '../model/payment_gateway/initialize_payment.dart';
import '../model/payment_gateway/payment_model.dart';
import '../model/payment_gateway/tap_payment_charge_response.dart';
import '../model/server/pay_for_content_options.dart';
import '../model/server/save_payment_status_options.dart';
import '../model/server/subscribe_to_package_options.dart';
import '../model/server/subscription_response_model.dart';
import '../model/server/wallet_add_options.dart';
import '../model/server/pay_for_booking_options.dart';

abstract class PaymentRepository extends Repository {
  Future<Either<CustomException, bool>> initializePayment(
    InitializePaymentModel options,
  );
  Future<Either<CustomException, SubscriptionResponseModel>> subscribeToPackage(
    SubscribeToPackagePromotionOptions options,
  );

  Future<Either<CustomException, dynamic>> payWithCard(
    CardPaymentRequestModel options,
  );
  Future<Either<CustomException, dynamic>> payWithWallet(
    WalletPaymentRequestModel options,
  );

  Future<Either<CustomException, BaseResponseModel>> savePaymentResponse(
    SavePaymentStatusOptions options,
  );

  Future<Either<CustomException, TapPaymentChargeResponse>> payForContent(
    PayForContentOptions options,
  );

  Future<Either<CustomException, TapPaymentChargeResponse>> walletAdd(
    WalletAddOptions options,
  );

  Future<Either<CustomException, TapPaymentChargeResponse>> payForBooking(
    PayForBookingOptions options,
  );
}
