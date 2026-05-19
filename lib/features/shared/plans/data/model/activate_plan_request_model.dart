class ActivatePlanRequestModel {
  final String planId;
  final int durationMonths;

  ActivatePlanRequestModel({
    required this.planId,
    required this.durationMonths,
  });

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'duration_months': durationMonths.toString(),
    };
  }
}

/// Top-level response from activate-plan API.
/// The API returns the charge/transaction directly at the root level (not nested under "payment").
/// Example: { "id": "chg_xxx", "transaction": { "url": "https://..." }, ... }
class ActivatePlanResponseModel {
  final String? chargeId;
  final String? status;
  final TransactionData? transaction;

  ActivatePlanResponseModel({
    this.chargeId,
    this.status,
    this.transaction,
  });

  factory ActivatePlanResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle both old nested structure (payment.transaction.url)
    // AND the actual API structure where transaction is at the root level.
    TransactionData? txn;

    // New structure: transaction is directly in the root
    if (json['transaction'] != null) {
      txn = TransactionData.fromJson(json['transaction'] as Map<String, dynamic>);
    }
    // Old/fallback structure: payment.transaction
    else if (json['payment'] != null) {
      final payment = json['payment'] as Map<String, dynamic>;
      if (payment['transaction'] != null) {
        txn = TransactionData.fromJson(payment['transaction'] as Map<String, dynamic>);
      }
    }

    return ActivatePlanResponseModel(
      chargeId: json['id'] as String?,
      status: json['status'] as String?,
      transaction: txn,
    );
  }

  /// Convenience getter to get the payment URL regardless of nesting
  String? get paymentUrl => transaction?.url;
}

class TransactionData {
  final String? url;

  TransactionData({this.url});

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      url: json['url'] as String?,
    );
  }
}
