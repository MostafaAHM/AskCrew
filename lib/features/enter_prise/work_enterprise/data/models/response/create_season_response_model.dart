class CreateSeasonResponseModel {
  final int id;
  final int seriesId;
  final String seasonNumber;
  final String trailer;
  final double price;
  final String coverPhoto;
  final String message;

  CreateSeasonResponseModel({
    required this.id,
    required this.seriesId,
    required this.seasonNumber,
    required this.trailer,
    required this.price,
    required this.coverPhoto,
    required this.message,
  });

  factory CreateSeasonResponseModel.fromJson(Map<String, dynamic> json) {
    final priceValue = json['price'] ?? json['data']?['price'] ?? 0;
    final price = priceValue is String ? double.tryParse(priceValue) ?? 0.0 : (priceValue as num).toDouble();
    
    return CreateSeasonResponseModel(
      id: json['id'] ?? json['data']?['id'] ?? 0,
      seriesId: json['series']?['id'] ?? json['series_id'] ?? json['data']?['series_id'] ?? 0,
      seasonNumber: (json['season_number'] ?? json['data']?['season_number'] ?? '').toString(),
      trailer: json['trailer'] ?? json['data']?['trailer'] ?? '',
      price: price,
      coverPhoto: json['cover_photo'] ?? json['data']?['cover_photo'] ?? '',
      message: json['message'] ?? 'Season created successfully',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'series_id': seriesId,
      'season_number': seasonNumber,
      'trailer': trailer,
      'price': price,
      'cover_photo': coverPhoto,
      'message': message,
    };
  }
}
