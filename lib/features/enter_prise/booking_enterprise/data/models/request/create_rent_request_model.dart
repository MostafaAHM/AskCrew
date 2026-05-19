class CreateRentRequestModel {
  final int itemId;
  final String? name;
  final String? message;
  final DateTime startDate;
  final DateTime endDate;
  final int quantity;

  CreateRentRequestModel({
    required this.itemId,
    this.name,
    this.message,
    required this.startDate,
    required this.endDate,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'item': itemId,
      'start_date': startDate.toIso8601String().split(
        'T',
      )[0], // Format as yyyy-MM-dd
      'end_date': endDate.toIso8601String().split(
        'T',
      )[0], // Format as yyyy-MM-dd
      'quantity': quantity,
      if (name != null && name!.isNotEmpty) 'name': name,
      if (message != null && message!.isNotEmpty) 'message': message,
    };
  }
}
