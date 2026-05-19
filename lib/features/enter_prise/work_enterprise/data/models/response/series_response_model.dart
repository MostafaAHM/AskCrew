import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/movie_model.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/category_model.dart';

class SeriesResponseModel {
  final int count;
  final String? next;
  final String? previous;
  final List<SeriesModel> results;

  SeriesResponseModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory SeriesResponseModel.fromJson(Map<String, dynamic> json) {
    return SeriesResponseModel(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? (json['results'] as List).map((e) => SeriesModel.fromJson(e)).toList()
          : [],
    );
  }
}

class SeriesModel {
  final int id;
  final String title;
  final String about;
  final String price;
  final String? coverPhoto;
  final List<MovieActorModel> actors;
  final String? trailer;
  final int viewsCount;
  final CategoryModel? category;
  final bool isReady;
  final bool adminApproved;
  final String createdAt;
  final String? seasonNumber;
  final int seasonsCount;
  final int categoryId;
  final bool isOwner;
  final double? ratingMean;
  final int subscribedCount;

  SeriesModel({
    required this.id,
    required this.title,
    required this.about,
    required this.price,
    this.coverPhoto,
    required this.actors,
    this.trailer,
    required this.viewsCount,
    this.category,
    required this.isReady,
    required this.adminApproved,
    required this.createdAt,
    this.seasonNumber,
    required this.seasonsCount,
    required this.categoryId,
    this.isOwner = false,
    this.ratingMean,
    this.subscribedCount = 0,
  });

  factory SeriesModel.fromJson(Map<String, dynamic> json) {
    return SeriesModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      about: json['about'] ?? '',
      price: json['price'] ?? '0.00',
      coverPhoto: json['cover_photo'] ?? json['cover_image'],
      actors: json['actors'] != null
          ? (json['actors'] as List).map((e) => MovieActorModel.fromJson(e)).toList()
          : [],
      trailer: json['trailer'],
      viewsCount: json['views_count'] ?? 0,
      category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,
      isReady: json['is_ready'] ?? false,
      adminApproved: json['admin_approved'] ?? false,
      createdAt: json['created_at'] ?? '',
      seasonNumber: json['season_number']?.toString(),
      seasonsCount: json['seasons_count'] ?? 0,
      categoryId: json['category'] != null ? json['category']['id'] ?? 0 : 0,
      isOwner: json['is_owner'] ?? false,
      ratingMean: json['rating_mean'] != null ? (json['rating_mean'] as num).toDouble() : null,
      subscribedCount: json['subscribed_count'] ?? 0,
    );
  }
}
