import '../../../../enter_prise/work_enterprise/data/models/response/category_model.dart';
import '../../../../enter_prise/work_enterprise/data/models/response/movie_model.dart';

class MoviesWithSeriesResponseModel {
  final int count;
  final String? next;
  final String? previous;
  final List<MovieOrSeriesItem> results;

  MoviesWithSeriesResponseModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory MoviesWithSeriesResponseModel.fromJson(Map<String, dynamic> json) {
    return MoviesWithSeriesResponseModel(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? (json['results'] as List)
                .map(
                  (e) => MovieOrSeriesItem.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }
}

/// Unified model that can represent either a Movie or a Series
class MovieOrSeriesItem {
  final int id;
  final String? title; // For series
  final String? name; // For movies
  final String about;
  final String price;
  final String? coverPhoto; // For series
  final String? coverImage; // For movies
  final List<MovieActorModel> actors;
  final String? trailer;
  final int viewsCount;
  final CategoryModel? category;
  final bool isReady;
  final bool adminApproved;
  final String? adminApprovedAt;
  final String? adminApprovedBy;
  final String? video; // For movies
  final bool isFavorite;
  final bool isRated;
  final bool? isPaid; // Payment status
  final double? userRating;
  final double? ratingMean;
  final int? ratingCount;
  final String? artWorkType; // 'movie' or 'series'
  final String createdAt;
  final String updatedAt;

  // Series-specific fields
  final String? seasonNumber;
  final int? seasonsCount;
  final int? categoryId;
  final int? createdBy;

  MovieOrSeriesItem({
    required this.id,
    this.title,
    this.name,
    required this.about,
    required this.price,
    this.coverPhoto,
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
    this.isPaid,
    this.userRating,
    this.ratingMean,
    this.ratingCount,
    this.artWorkType,
    required this.createdAt,
    required this.updatedAt,
    this.seasonNumber,
    this.seasonsCount,
    this.categoryId,
    this.createdBy,
  });

  /// Get display name (title for series, name for movies)
  String get displayName => title ?? name ?? '';

  /// Get cover image (coverPhoto for series, coverImage for movies)
  String? get displayCoverImage => coverPhoto ?? coverImage;

  /// Determine if this is a series (has title but no name)
  bool get isSeries => title != null && name == null;

  /// Determine if this is a movie (has name but no title)
  bool get isMovie => name != null && title == null;

  /// Get content type for navigation
  String get contentType => artWorkType ?? (isSeries ? 'series' : 'movie');

  factory MovieOrSeriesItem.fromJson(Map<String, dynamic> json) {
    final item = MovieOrSeriesItem(
      id: json['id'] ?? 0,
      title: json['title'],
      name: json['name'],
      about: json['about'] ?? '',
      price: json['price'] ?? '0.00',
      coverPhoto: json['cover_photo'],
      coverImage: json['cover_image'],
      actors: json['actors'] != null
          ? (json['actors'] as List)
                .map((e) => MovieActorModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      trailer: json['trailer'],
      viewsCount: json['views_count'] ?? 0,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      isReady: json['is_ready'] ?? false,
      adminApproved: json['admin_approved'] ?? false,
      adminApprovedAt: json['admin_approved_at'],
      adminApprovedBy: json['admin_approved_by']?.toString(),
      video: json['video'],
      isFavorite: json['is_favorite'] ?? false,
      isRated: json['is_rated'] ?? false,
      isPaid: json['is_paid'] == null
          ? null
          : (json['is_paid'] == true ||
                json['is_paid'] == 1 ||
                json['is_paid'] == 'true'),
      userRating: json['user_rating'] != null
          ? (json['user_rating'] as num).toDouble()
          : null,
      ratingMean: json['rating_mean'] != null
          ? (json['rating_mean'] as num).toDouble()
          : null,
      ratingCount: json['rating_count'],
      artWorkType: json['art_work_type'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      seasonNumber: json['season_number']?.toString(),
      seasonsCount: json['seasons_count'],
      categoryId: json['category'] != null ? json['category']['id'] : null,
      createdBy: json['created_by'],
    );
    print(
      '📦 [MovieOrSeriesItem] ID: ${item.id}, isPaid RAW: ${json['is_paid']}, PARSED: ${item.isPaid}, PRICE: ${item.price}',
    );
    return item;
  }
}
