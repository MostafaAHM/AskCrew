class CreateEpisodeResponseModel {
  final int id;
  final int seasonId;
  final int episodeNumber;
  final String title;
  final String description;
  final String video;
  final int viewsCount;
  final String message;

  CreateEpisodeResponseModel({
    required this.id,
    required this.seasonId,
    required this.episodeNumber,
    required this.title,
    required this.description,
    required this.video,
    required this.viewsCount,
    required this.message,
  });

  factory CreateEpisodeResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateEpisodeResponseModel(
      id: json['id'] ?? json['data']?['id'] ?? 0,
      seasonId: json['season']?['id'] ?? json['season_id'] ?? json['data']?['season_id'] ?? 0,
      episodeNumber: json['episode_number'] ?? json['data']?['episode_number'] ?? 0,
      title: json['title'] ?? json['data']?['title'] ?? '',
      description: json['description'] ?? json['data']?['description'] ?? '',
      video: json['video'] ?? json['data']?['video'] ?? '',
      viewsCount: json['views_count'] ?? json['data']?['views_count'] ?? 0,
      message: json['message'] ?? 'Episode created successfully',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'season_id': seasonId,
      'episode_number': episodeNumber,
      'title': title,
      'description': description,
      'video': video,
      'views_count': viewsCount,
      'message': message,
    };
  }
}
