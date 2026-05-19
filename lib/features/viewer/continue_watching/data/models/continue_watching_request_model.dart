class UpdateContinueWatchingRequest {
  final String? artWorkType; // 'movie', 'episode', 'advertise'
  final int? contentId;
  final int? continueWatchingId;
  final int progress;

  UpdateContinueWatchingRequest({
    this.artWorkType,
    this.contentId,
    this.continueWatchingId,
    required this.progress,
  });

  Map<String, dynamic> toFormData() {
    final map = <String, dynamic>{'progress': progress};
    if (continueWatchingId != null) {
      map['continue_watching_id'] = continueWatchingId;
    } else {
      if (artWorkType != null) map['content_type'] = artWorkType;
      if (contentId != null) map['content_id'] = contentId;
    }
    return map;
  }
}
