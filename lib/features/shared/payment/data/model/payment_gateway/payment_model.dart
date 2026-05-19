import 'package:flutter_paymob/billing_data.dart';
import 'package:flutter_paymob/paymob_response.dart';

abstract class BasePaymentRequestModel {
  final String currency;
  final num? amount;

  void Function(PaymentPaymobResponse)? onPayment;
  BasePaymentRequestModel({
    required this.currency,
    required this.amount,
    this.onPayment,
  });
}

class BillingDataModel {
  final String? email;
  final String? firstName;
  final String? phoneNumber;
  BillingData toBillingData() {
    return BillingData(
        email: email, firstName: firstName, phoneNumber: phoneNumber);
  }

  BillingDataModel({
    this.email,
    this.firstName,
    this.phoneNumber,
  });
}

class CardPaymentRequestModel extends BasePaymentRequestModel {
  CardPaymentRequestModel(
      {required super.currency, required super.amount, super.onPayment});
}

class WalletPaymentRequestModel extends BasePaymentRequestModel {
  final String walletNumber;

  WalletPaymentRequestModel({
    required super.currency,
    required super.amount,
    required this.walletNumber,
    super.onPayment,
  });

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'amount': amount,
      'walletNumber': walletNumber,
    };
  }
}
