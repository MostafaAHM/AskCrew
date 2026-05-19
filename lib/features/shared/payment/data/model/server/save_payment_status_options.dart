
import '../../../../../../core/app_config/app_urls.dart';
import '../../../presentation/screens/payment_screen.dart';

class SavePaymentStatusOptions {
  final String transactionId;
  final String orderId;
  final PaymentType type;

  String get url => type == PaymentType.package
      ? AppUrls.savePaymentStatus
      : AppUrls.savePromotionStatus;

  SavePaymentStatusOptions(
      {required this.transactionId, required this.orderId, required this.type});

  Map<String, dynamic> toJson() =>
      {"transactionId": int.tryParse(transactionId), "orderId": orderId};
}
