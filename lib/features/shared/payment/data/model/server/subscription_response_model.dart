class SubscriptionResponseModel {
  SubscriptionResponseModel({
    this.orderId,
    this.amount,
    this.currency,
  });
  final String? orderId;
  final num? amount;
  final String? currency;

  factory SubscriptionResponseModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponseModel(
      orderId: json['orderId'],
      amount: json['amount'],
      currency: json['currency'] ?? "KWD",
    );
  }
}
