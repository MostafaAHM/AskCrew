import '../../../../enter_prise/work_enterprise/data/models/response/category_model.dart';
import '../../../../enter_prise/work_enterprise/data/models/response/movie_model.dart';

class BannersResponseModel {
  final int count;
  final String? next;
  final String? previous;
  final List<BannerModel> results;

  BannersResponseModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory BannersResponseModel.fromJson(Map<String, dynamic> json) {
    return BannersResponseModel(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? (json['results'] as List).map((e) => BannerModel.fromJson(e)).toList()
          : [],
    );
  }
}

class BannerModel {
  final int id;
  final String contentType;
  final String description;
  final int order;
  final bool isActive;
  final BannerContentObject? contentObject;
  final String createdAt;
  final String updatedAt;

  BannerModel({
    required this.id,
    required this.contentType,
    required this.description,
    required this.order,
    required this.isActive,
    this.contentObject,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      contentType: json['content_type'] ?? '',
      description: json['description'] ?? '',
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? false,
      contentObject: json['content_object'] != null
          ? BannerContentObject.fromJson(json['content_object'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class BannerContentObject {
  final int id;
  final String name;
  final String about;
  final String price;
  final String? coverImage;
  final List<MovieActorModel> actors;
  final String? trailer;
  final int viewsCount;
  final CategoryModel? category;
  final bool isReady;
  final bool adminApproved;
  final String? adminApprovedAt;
  final String? adminApprovedBy;
  final String? video;
  final bool isFavorite;
  final bool isRated;
  final double? userRating;
  final double? ratingMean;
  final int? ratingCount;
  final String artWorkType;
  final bool? isPaid; // If true, user has already paid for this content
  final String createdAt;
  final String updatedAt;

  BannerContentObject({
    required this.id,
    required this.name,
    required this.about,
    required this.price,
    this.coverImage,
    required this.actors,
    this.trailer,
    required this.viewsCount,
    this.category,
    required this.isReady,
    required this.adminApproved,
    this.adminApprovedAt,
    this.adminApprovedBy,
    this.video,
    required this.isFavorite,
    required this.isRated,
    this.userRating,
    this.ratingMean,
    this.ratingCount,
    required this.artWorkType,
    this.isPaid,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BannerContentObject.fromJson(Map<String, dynamic> json) {
    return BannerContentObject(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      about: json['about'] ?? '',
      price: json['price'] ?? '0.00',
      coverImage: json['cover_image'],
      actors: json['actors'] != null
          ? (json['actors'] as List).map((e) => MovieActorModel.fromJson(e)).toList()
          : [],
      trailer: json['trailer'],
      viewsCount: json['views_count'] ?? 0,
      category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,
      isReady: json['is_ready'] ?? false,
      adminApproved: json['admin_approved'] ?? false,
      adminApprovedAt: json['admin_approved_at'],
      adminApprovedBy: json['admin_approved_by']?.toString(),
      video: json['video'],
      isFavorite: json['is_favorite'] ?? false,
      isRated: json['is_rated'] ?? false,
      userRating: json['user_rating'] != null ? (json['user_rating'] as num).toDouble() : null,
      ratingMean: json['rating_mean'] != null ? (json['rating_mean'] as num).toDouble() : null,
      ratingCount: json['rating_count'],
      artWorkType: json['art_work_type'] ?? 'movie',
      isPaid: json['is_paid'] as bool?,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

