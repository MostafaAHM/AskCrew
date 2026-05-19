class SeasonsResponseModel {
  final int count;
  final String? next;
  final String? previous;
  final List<SeasonModel> results;

  SeasonsResponseModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory SeasonsResponseModel.fromJson(Map<String, dynamic> json) {
    return SeasonsResponseModel(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? (json['results'] as List).map((e) => SeasonModel.fromJson(e)).toList()
          : [],
    );
  }
}

class SeasonModel {
  final int id;
  final int seasonNumber;
  final String title;
  final String? coverPhoto;
  final int episodesCount;
  final String createdAt;

  SeasonModel({
    required this.id,
    required this.seasonNumber,
    required this.title,
    this.coverPhoto,
    required this.episodesCount,
    required this.createdAt,
  });

  factory SeasonModel.fromJson(Map<String, dynamic> json) {
    final seasonNum = json['season_number'] ?? 1;
    return SeasonModel(
      id: json['id'] ?? 0,
      seasonNumber: seasonNum,
      title: json['title'] ?? json['name'] ?? 'Season $seasonNum',
      coverPhoto: json['cover_photo'],
      episodesCount: json['episodes_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  String get name => title;
}
