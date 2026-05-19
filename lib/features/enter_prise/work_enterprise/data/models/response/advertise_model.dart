class AdvertiseModel {
  final int id;
  final String name;
  final String about;
  final String price;
  final String coverImage;
  final List<ActorData> actors;
  final String trailer;
  final String video;
  final int viewsCount;
  final CategoryData category;
  final bool isReady;
  final bool adminApproved;
  final String? adminApprovedAt;
  final int? adminApprovedBy;
  final bool isFavorite;
  final bool isRated;
  final double? userRating;
  final double ratingMean;
  final int ratingCount;
  final String createdAt;
  final String updatedAt;
  final bool isOwner;
  final int subscribedCount;

  AdvertiseModel({
    required this.id,
    required this.name,
    required this.about,
    required this.price,
    required this.coverImage,
    required this.actors,
    required this.trailer,
    required this.video,
    required this.viewsCount,
    required this.category,
    required this.isReady,
    required this.adminApproved,
    this.adminApprovedAt,
    this.adminApprovedBy,
    required this.isFavorite,
    required this.isRated,
    this.userRating,
    required this.ratingMean,
    required this.ratingCount,
    required this.createdAt,
    required this.updatedAt,
    this.isOwner = false,
    this.subscribedCount = 0,
  });

  factory AdvertiseModel.fromJson(Map<String, dynamic> json) {
    return AdvertiseModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      about: json['about'] ?? '',
      price: json['price'] ?? '',
      coverImage: json['cover_image'] ?? '',
      actors: (json['actors'] as List?)
              ?.map((e) => ActorData.fromJson(e))
              .toList() ??
          [],
      trailer: json['trailer'] ?? '',
      video: json['video'] ?? '',
      viewsCount: json['views_count'] ?? 0,
      category: CategoryData.fromJson(json['category'] ?? {}),
      isReady: json['is_ready'] ?? false,
      adminApproved: json['admin_approved'] ?? false,
      adminApprovedAt: json['admin_approved_at'],
      adminApprovedBy: json['admin_approved_by'],
      isFavorite: json['is_favorite'] ?? false,
      isRated: json['is_rated'] ?? false,
      userRating: json['user_rating']?.toDouble(),
      ratingMean: (json['rating_mean'] ?? 0.0).toDouble(),
      ratingCount: json['rating_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      isOwner: json['is_owner'] ?? false,
      subscribedCount: json['subscribed_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'about': about,
      'price': price,
      'cover_image': coverImage,
      'actors': actors.map((e) => e.toJson()).toList(),
      'trailer': trailer,
      'video': video,
      'views_count': viewsCount,
      'category': category.toJson(),
      'is_ready': isReady,
      'admin_approved': adminApproved,
      'admin_approved_at': adminApprovedAt,
      'admin_approved_by': adminApprovedBy,
      'is_favorite': isFavorite,
      'is_rated': isRated,
      'user_rating': userRating,
      'rating_mean': ratingMean,
      'rating_count': ratingCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_owner': isOwner,
      'subscribed_count': subscribedCount,
    };
  }
}

class ActorData {
  final int id;
  final String name;
  final String image;

  ActorData({
    required this.id,
    required this.name,
    required this.image,
  });

  factory ActorData.fromJson(Map<String, dynamic> json) {
    return ActorData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }
}

class CategoryData {
  final int id;
  final String name;
  final String? image;

  CategoryData({
    required this.id,
    required this.name,
    this.image,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }
}
