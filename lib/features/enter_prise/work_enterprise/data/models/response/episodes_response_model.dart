class EpisodesResponseModel {
  final int count;
  final String? next;
  final String? previous;
  final List<EpisodeModel> results;

  EpisodesResponseModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory EpisodesResponseModel.fromJson(Map<String, dynamic> json) {
    return EpisodesResponseModel(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? (json['results'] as List).map((e) => EpisodeModel.fromJson(e)).toList()
          : [],
    );
  }
}

class EpisodeModel {
  final int id;
  final String name;
  final String about;
  final String? image;
  final String? video;
  final int season;
  final int episodeNumber;
  final double rating;
  final int viewsCount;
  final bool isReady;
  final String createdAt;

  EpisodeModel({
    required this.id,
    required this.name,
    required this.about,
    this.image,
    this.video,
    required this.season,
    required this.episodeNumber,
    this.rating = 0.0,
    required this.viewsCount,
    this.isReady = false,
    required this.createdAt,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    String? coverPhoto;
    if (json['cover_photo'] != null) {
      coverPhoto = json['cover_photo'];
    } else if (json['season'] is Map && json['season']['series'] is Map) {
      coverPhoto = json['season']['series']['cover_photo'];
    } else if (json['image'] != null) {
      coverPhoto = json['image'];
    }
    
    return EpisodeModel(
      id: json['id'] ?? 0,
      name: json['title'] ?? json['name'] ?? '',
      about: json['description'] ?? json['about'] ?? '',
      image: coverPhoto,
      video: json['video'],
      season: json['season'] is int ? json['season'] : (json['season'] != null ? json['season']['id'] : 0),
      episodeNumber: json['episode_number'] ?? 1,
      rating: (json['rating'] ?? 0.0).toDouble(),
      viewsCount: json['views_count'] ?? 0,
      isReady: json['is_ready'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }
}
