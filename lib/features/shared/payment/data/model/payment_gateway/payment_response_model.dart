class PaymentResponseModel {
  final bool success;
  final String? transactionId;
  final String? responseCode;
  final String? message;

  PaymentResponseModel({
    required this.success,
    this.transactionId,
    this.responseCode,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'transactionID': transactionId,
      'responseCode': responseCode,
      'message': message,
    };
  }
}
