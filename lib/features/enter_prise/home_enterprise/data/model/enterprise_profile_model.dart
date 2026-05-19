class EnterpriseProfileModel {
  final String id;
  final String name;
  final String profession;
  final String profileImage;
  final bool isVerified;
  final bool waterMark;
  final double rating;
  final int reviewsCount;
  final bool isAvailable;
  final List<String>? images; // Profile images URLs

  const EnterpriseProfileModel({
    required this.id,
    required this.name,
    required this.profession,
    required this.profileImage,
    this.isVerified = false,
    this.waterMark = false,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.isAvailable = false,
    this.images,
  });

  factory EnterpriseProfileModel.fromJson(Map<String, dynamic> json) {
    return EnterpriseProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      profession: json['profession'] ?? '',
      profileImage: json['profileImage'] ?? '',
      isVerified: json['isVerified'] ?? false,
      waterMark: json['water_mark'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: json['reviewsCount'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profession': profession,
      'profileImage': profileImage,
      'isVerified': isVerified,
      'water_mark': waterMark,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'isAvailable': isAvailable,
      'images': images,
    };
  }
}
