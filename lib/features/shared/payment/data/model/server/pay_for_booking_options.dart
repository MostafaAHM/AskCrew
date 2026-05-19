class PayForBookingOptions {
  final int bookingId;
  final double? amount;
  final String? code;
  final bool? usePoints;

  PayForBookingOptions({
    required this.bookingId,
    this.amount,
    this.code,
    this.usePoints,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {'booking_id': bookingId.toString()};

    if (amount != null) {
      json['amount'] = amount.toString();
    }

    if (code != null && code!.isNotEmpty) {
      json['code'] = code;
    }

    if (usePoints != null && usePoints == true) {
      json['use_points'] = "1";
    }

    return json;
  }
}
