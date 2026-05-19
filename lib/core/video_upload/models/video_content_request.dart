/// Base class for video content finalization requests
/// Each content type (movie, episode, etc.) extends this
abstract class VideoContentRequest {
  final String videoId;

  VideoContentRequest({required this.videoId});

  /// Convert to JSON for API request
  Map<String, dynamic> toJson();

  /// Get the endpoint for this content type
  String get endpoint;
}

/// Request model for creating a movie with uploaded video
class CreateMovieRequest extends VideoContentRequest {
  final String title;
  final String description;
  final List<int> actors;
  final int categoryId;
  final String? trailerUrl;
  final String? coverImage;
  final double? price;

  CreateMovieRequest({
    required super.videoId,
    required this.title,
    required this.description,
    required this.actors,
    required this.categoryId,
    this.trailerUrl,
    this.coverImage,
    this.price,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'title': title,
      'description': description,
      'actors': actors,
      'category': categoryId,
      if (trailerUrl != null) 'trailer': trailerUrl,
      if (coverImage != null) 'cover_image': coverImage,
      if (price != null) 'price': price,
    };
  }

  @override
  String get endpoint => '/v1/content/movies/';
}

/// Request model for creating a series episode with uploaded video
class CreateEpisodeRequest extends VideoContentRequest {
  final int seriesId;
  final int seasonNumber;
  final int episodeNumber;
  final String title;
  final String? description;
  final String? coverImage;

  CreateEpisodeRequest({
    required super.videoId,
    required this.seriesId,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.title,
    this.description,
    this.coverImage,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'series_id': seriesId,
      'season_number': seasonNumber,
      'episode_number': episodeNumber,
      'title': title,
      if (description != null) 'description': description,
      if (coverImage != null) 'cover_image': coverImage,
    };
  }

  @override
  String get endpoint => '/v1/content/episodes/';
}

/// Add more content types as needed
/// Example: CreateTrailerRequest, CreateShortRequest, etc.
