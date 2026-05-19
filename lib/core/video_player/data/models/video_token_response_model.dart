class VideoTokenResponseModel {
  final String token;
  final DateTime expiresAt;
  final String videoId;
  final String libraryId;
  final String contentType;
  final int contentId;
  final String embedUrl;

  VideoTokenResponseModel({
    required this.token,
    required this.expiresAt,
    required this.videoId,
    required this.libraryId,
    required this.contentType,
    required this.contentId,
    required this.embedUrl,
  });

  factory VideoTokenResponseModel.fromJson(Map<String, dynamic> json) {
    DateTime expiresAt;
    if (json['expires_at'] is int) {
      expiresAt = DateTime.fromMillisecondsSinceEpoch(
        (json['expires_at'] as int) * 1000,
        isUtc: true,
      );
    } else if (json['expires_at'] is String) {
      expiresAt = DateTime.tryParse(json['expires_at'] ?? '') ?? DateTime.now();
    } else {
      expiresAt = DateTime.now();
    }

    return VideoTokenResponseModel(
      token: json['token'] ?? '',
      expiresAt: expiresAt,
      videoId: json['video_id'] ?? '',
      libraryId: json['library_id'] ?? '',
      contentType: json['content_type'] ?? '',
      contentId: json['content_id'] ?? 0,
      embedUrl: json['embed_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expires_at': expiresAt.millisecondsSinceEpoch ~/ 1000,
      'video_id': videoId,
      'library_id': libraryId,
      'content_type': contentType,
      'content_id': contentId,
      'embed_url': embedUrl,
    };
  }

  int get expiresAtUnix => expiresAt.millisecondsSinceEpoch ~/ 1000;

  bool get isExpired => expiresAt.isBefore(DateTime.now());
}
