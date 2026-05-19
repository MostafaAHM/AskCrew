class VideoInitResponse {
  final String videoId;
  final String libraryId;
  final String uploadEndpoint;
  final String authorizationSignature;
  final int authorizationExpire;

  VideoInitResponse({
    required this.videoId,
    required this.libraryId,
    required this.uploadEndpoint,
    required this.authorizationSignature,
    required this.authorizationExpire,
  });

  factory VideoInitResponse.fromJson(Map<String, dynamic> json) {
    return VideoInitResponse(
      videoId: json['video_id'] as String,
      libraryId: json['library_id'] as String,
      uploadEndpoint: json['upload_endpoint'] as String,
      authorizationSignature: json['authorization_signature'] as String,
      authorizationExpire: json['authorization_expire'] as int,
    );
  }
}
