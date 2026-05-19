import 'category_model.dart';

class MoviesResponseModel {
  final int count;
  final String? next;
  final String? previous;
  final List<MovieModel> results;

  MoviesResponseModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory MoviesResponseModel.fromJson(Map<String, dynamic> json) {
    return MoviesResponseModel(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? (json['results'] as List).map((e) => MovieModel.fromJson(e)).toList()
          : [],
    );
  }
}

class MovieModel {
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
  final String? video;
  final String createdAt;
  final bool? isFavorite;
  final bool? isRated;
  final bool? isPaid; // Payment status
  final double? userRating;
  final double? ratingMean;
  final int? ratingCount;
  final String? artWorkType;
  final bool isOwner;
  final int subscribedCount;

  MovieModel({
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
    this.video,
    required this.createdAt,
    this.isFavorite,
    this.isRated,
    this.isPaid,
    this.userRating,
    this.ratingMean,
    this.ratingCount,
    this.artWorkType,
    this.isOwner = false,
    this.subscribedCount = 0,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
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
      video: json['video'],
      createdAt: json['created_at'] ?? '',
      isFavorite: json['is_favorite'],
      isRated: json['is_rated'],
      isPaid: json['is_paid'] == null 
          ? null 
          : (json['is_paid'] == true || json['is_paid'] == 1 || json['is_paid'] == 'true'),
      userRating: json['user_rating'] != null ? (json['user_rating'] as num).toDouble() : null,
      ratingMean: json['rating_mean'] != null ? (json['rating_mean'] as num).toDouble() : null,
      ratingCount: json['rating_count'],
      artWorkType: json['art_work_type'],
      isOwner: json['is_owner'] ?? false,
      subscribedCount: json['subscribed_count'] ?? 0,
    );
  }
}

class MovieActorModel {
  final int id;
  final String name;
  final String? image;

  MovieActorModel({
    required this.id,
    required this.name,
    this.image,
  });

  factory MovieActorModel.fromJson(Map<String, dynamic> json) {
    return MovieActorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'],
    );
  }
}
