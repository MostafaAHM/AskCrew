import '../../../home_viewer/data/model/movies_with_series_model.dart';

class ContinueWatchingItemModel {
  final int id;
  final int user;
  final int? contentType;
  final int objectId;
  final int progress;
  final String createdAt;
  final String updatedAt;
  final MovieOrSeriesItem? contentData;

  ContinueWatchingItemModel({
    required this.id,
    required this.user,
    this.contentType,
    required this.objectId,
    required this.progress,
    required this.createdAt,
    required this.updatedAt,
    this.contentData,
  });

  factory ContinueWatchingItemModel.fromJson(Map<String, dynamic> json) {
    return ContinueWatchingItemModel(
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
      contentType: json['content_type'],
      objectId: json['object_id'] ?? 0,
      progress: json['progress'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      contentData: json['content_data'] != null
          ? MovieOrSeriesItem.fromJson(json['content_data'])
          : null,
    );
  }
}
