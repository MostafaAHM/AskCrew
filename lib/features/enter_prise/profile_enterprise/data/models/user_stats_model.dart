class UserStatsModel {
  final double meanRating;
  final int totalCompletedWorkshops;
  final int totalChatRooms;
  final int totalRentedProducts;
  final int totalProductsForRent;

  UserStatsModel({
    required this.meanRating,
    required this.totalCompletedWorkshops,
    required this.totalChatRooms,
    required this.totalRentedProducts,
    required this.totalProductsForRent,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      meanRating: (json['mean_rating'] as num?)?.toDouble() ?? 0.0,
      totalCompletedWorkshops: json['total_completed_workshops'] as int? ?? 0,
      totalChatRooms: json['total_chat_rooms'] as int? ?? 0,
      totalRentedProducts: json['total_rented_products'] as int? ?? 0,
      totalProductsForRent: json['total_products_for_rent'] as int? ?? 0,
    );
  }
}
