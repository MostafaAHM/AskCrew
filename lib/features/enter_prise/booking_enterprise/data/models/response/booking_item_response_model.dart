class BookingItemResponseModel {
  final int id;
  final String name;
  final String quantity;
  final double pricePerDay;
  final String location;
  final String type;
  final String image;
  final bool isActive;
  final int? createdBy;
  final String? createdByEmail;
  final String? createdByFullname;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? description;

  BookingItemResponseModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.pricePerDay,
    required this.location,
    required this.type,
    required this.image,
    required this.isActive,
    this.createdBy,
    this.createdByEmail,
    this.createdByFullname,
    required this.createdAt,
    required this.updatedAt,
    this.startTime,
    this.endTime,
    this.description,
  });

  factory BookingItemResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle price_per_day conversion
    double pricePerDayValue = 0.0;
    if (json['price_per_day'] != null) {
      if (json['price_per_day'] is num) {
        pricePerDayValue = json['price_per_day'].toDouble();
      } else if (json['price_per_day'] is String) {
        pricePerDayValue = double.tryParse(json['price_per_day']) ?? 0.0;
      }
    }

    return BookingItemResponseModel(
      id: json['id'] is int
          ? json['id']
          : (json['id'] is String ? int.tryParse(json['id']) ?? 0 : 0),
      name: json['name']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '0',
      pricePerDay: pricePerDayValue,
      location: json['location']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      isActive: json['is_active'] is bool
          ? json['is_active']
          : (json['is_active'] == true ||
                json['is_active'] == 'true' ||
                json['is_active'] == 1),
      createdBy: json['created_by'] is int
          ? json['created_by']
          : (json['created_by'] is String
                ? int.tryParse(json['created_by'])
                : null),
      createdByEmail: json['created_by_email']?.toString(),
      createdByFullname: json['created_by_fullname']?.toString(),
      createdAt: json['created_at'] != null
          ? (json['created_at'] is DateTime
                ? json['created_at']
                : DateTime.tryParse(json['created_at'].toString()) ??
                      DateTime.now())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'] is DateTime
                ? json['updated_at']
                : DateTime.tryParse(json['updated_at'].toString()) ??
                      DateTime.now())
          : DateTime.now(),
      startTime: json['start_time'] != null
          ? (json['start_time'] is DateTime
                ? json['start_time']
                : DateTime.tryParse(json['start_time'].toString()))
          : null,
      endTime: json['end_time'] != null
          ? (json['end_time'] is DateTime
                ? json['end_time']
                : DateTime.tryParse(json['end_time'].toString()))
          : null,
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price_per_day': pricePerDay,
      'location': location,
      'type': type,
      'image': image,
      'is_active': isActive,
      'created_by': createdBy,
      'created_by_email': createdByEmail,
      'created_by_fullname': createdByFullname,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (startTime != null) 'start_time': startTime!.toIso8601String(),
      if (endTime != null) 'end_time': endTime!.toIso8601String(),
      if (description != null) 'description': description,
    };
  }
}
