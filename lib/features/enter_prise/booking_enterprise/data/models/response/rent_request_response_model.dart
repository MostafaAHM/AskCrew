class RentRequestResponseModel {
  final int id;
  final int item;
  final String? itemName;
  final int user;
  final String? userEmail;
  final String? userFullname;
  final String? userPhoto;
  final int? userRatingCount;
  final double? userRatingMean;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? quantity;
  final bool? isPaid;
  final double? paymentAmount;

  RentRequestResponseModel({
    required this.id,
    required this.item,
    this.itemName,
    required this.user,
    this.userEmail,
    this.userFullname,
    this.userPhoto,
    this.userRatingCount,
    this.userRatingMean,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.startDate,
    this.endDate,
    this.quantity,
    this.isPaid,
    this.paymentAmount,
  });

  factory RentRequestResponseModel.fromJson(Map<String, dynamic> json) {
    return RentRequestResponseModel(
      id: json['id'] is int
          ? json['id']
          : (json['id'] is String ? int.tryParse(json['id']) ?? 0 : 0),
      item: json['item'] is int
          ? json['item']
          : (json['item'] is String ? int.tryParse(json['item']) ?? 0 : 0),
      itemName: json['item_name']?.toString(),
      user: json['user'] is int
          ? json['user']
          : (json['user'] is String ? int.tryParse(json['user']) ?? 0 : 0),
      userEmail: json['user_email']?.toString(),
      userFullname: json['user_fullname']?.toString(),
      userPhoto: json['user_photo']?.toString(),
      userRatingCount: json['user_rating_count'] is int
          ? json['user_rating_count']
          : (json['user_rating_count'] is String
                ? int.tryParse(json['user_rating_count'])
                : null),
      userRatingMean: json['user_rating_mean'] is double
          ? json['user_rating_mean']
          : (json['user_rating_mean'] is num
                ? json['user_rating_mean'].toDouble()
                : (json['user_rating_mean'] is String
                      ? double.tryParse(json['user_rating_mean'])
                      : null)),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at'] != null
          ? (json['created_at'] is DateTime
                ? json['created_at']
                : DateTime.tryParse(json['created_at'].toString()) ??
                      DateTime.now())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'] is DateTime
                ? json['updated_at']
                : DateTime.tryParse(json['updated_at'].toString()))
          : null,
      startDate: json['start_date'] != null
          ? (json['start_date'] is DateTime
                ? json['start_date']
                : _parseDate(json['start_date'].toString()))
          : null,
      endDate: json['end_date'] != null
          ? (json['end_date'] is DateTime
                ? json['end_date']
                : _parseDate(json['end_date'].toString()))
          : null,
      quantity: json['quantity'] is int
          ? json['quantity']
          : (json['quantity'] is String
                ? int.tryParse(json['quantity'])
                : null),
      isPaid: json['is_paid'] is bool ? json['is_paid'] : null,
      paymentAmount: json['payment_amount'] is double
          ? json['payment_amount']
          : (json['payment_amount'] is num
                ? json['payment_amount'].toDouble()
                : (json['payment_amount'] is String
                      ? double.tryParse(json['payment_amount'])
                      : null)),
    );
  }

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  static DateTime? _parseDate(String dateString) {
    // Try parsing as ISO8601 first
    DateTime? date = DateTime.tryParse(dateString);
    if (date != null) return date;

    // If that fails, try parsing as "yyyy-MM-dd" format
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      // If parsing fails, return null
    }
    return null;
  }
}
