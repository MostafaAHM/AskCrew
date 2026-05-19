import 'package:aflam/core/app_config/content_types.dart';
import '../../../home_viewer/data/model/movies_with_series_model.dart';

class FavoritesResponseModel {
  final int count;
  final String? next;
  final String? previous;
  final List<FavoriteItemModel> results;

  FavoritesResponseModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory FavoritesResponseModel.fromJson(Map<String, dynamic> json) {
    return FavoritesResponseModel(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? (json['results'] as List)
                .map(
                  (e) => FavoriteItemModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }
}

class FavoriteItemModel {
  final int id;
  final String contentType;
  final int objectId;
  final MovieOrSeriesItem? contentObject;
  final String createdAt;

  FavoriteItemModel({
    required this.id,
    required this.contentType,
    required this.objectId,
    this.contentObject,
    required this.createdAt,
  });

  factory FavoriteItemModel.fromJson(Map<String, dynamic> json) {
    final contentObjectJson = json['content_object'] as Map<String, dynamic>?;
    final contentObject = contentObjectJson != null
        ? MovieOrSeriesItem.fromJson(contentObjectJson)
        : null;

    // Use art_work_type from content_object for string representation if possible
    // otherwise fallback to stringified content_type ID
    String type = json['content_type']?.toString() ?? '';
    if (contentObject != null) {
      type = contentObject.contentType;
    }

    return FavoriteItemModel(
      id: json['id'] ?? 0,
      contentType: type,
      objectId: json['object_id'] ?? 0,
      contentObject: contentObject,
      createdAt: json['created_at'] ?? '',
    );
  }

  String get key => '${AppContentTypes.mapForFavorite(contentType)}_$objectId';
}
