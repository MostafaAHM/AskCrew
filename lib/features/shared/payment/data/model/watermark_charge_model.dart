import 'package:equatable/equatable.dart';

import 'payment_gateway/tap_payment_charge_response.dart';

class WatermarkChargeModel extends Equatable {
  final TapPaymentTransaction transaction;
  final String id;
  final String status;

  const WatermarkChargeModel({
    required this.transaction,
    required this.id,
    required this.status,
  });

  factory WatermarkChargeModel.fromJson(Map<String, dynamic> json) {
    return WatermarkChargeModel(
      transaction: TapPaymentTransaction.fromJson(json['transaction']),
      id: json['id'] ?? '',
      status: json['status'] ?? '',
    );
  }

  @override
  List<Object> get props => [transaction, id, status];

  String get transactionUrl => transaction.url ?? '';
}
