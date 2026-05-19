
import '../../../../../../core/app_config/app_urls.dart';
import '../../../presentation/screens/payment_screen.dart';

class SubscribeToPackagePromotionOptions {
  // package or promotion id
  final String id;
  final PaymentType type;
  // in case of promotion send ad id
  final String? adId;
  String get url => type == PaymentType.package
      ? AppUrls.subscribeToPackage
      : AppUrls.subscribeToPromotion;

  SubscribeToPackagePromotionOptions(
      {required this.id, required this.type, this.adId});

  Map<String, dynamic> toJson() =>
      type == PaymentType.package ? toPackageJson() : toPromotionJson();

  Map<String, dynamic> toPackageJson() {
    return {
      'packageId': id,
    };
  }

  Map<String, dynamic> toPromotionJson() {
    return {
      'promotionId': id,
      'adId': adId,
    };
  }
}
