class AppContentTypes {
  static const String movie = 'movie';
  static const String advertise = 'advertise';
  static const String episode = 'episode';

  // These might still come from existing models, so we define them for mapping
  static const String series = 'series';
  static const String season = 'season';

  /// Maps content type for API requests.
  /// Backend strictly accepts: 'movie', 'advertise', 'episode'.
  static String mapForFavorite(String contentType) {
    if (contentType == series || contentType == season) {
      return movie;
    }
    // Ensure we return one of the allowed 3
    if (contentType == advertise) return advertise;
    if (contentType == episode) return episode;

    return movie; // Default fallback to movie
  }
}
