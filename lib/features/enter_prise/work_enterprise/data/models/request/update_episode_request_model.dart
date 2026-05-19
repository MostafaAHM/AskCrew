
import 'package:dio/dio.dart';

class UpdateEpisodeRequestModel {
  final int episodeId;
  final int? seasonId;
  final int? episodeNumber;
  final String? title;
  final String? description;
  final String? video; // Video ID

  UpdateEpisodeRequestModel({
    required this.episodeId,
    this.seasonId,
    this.episodeNumber,
    this.title,
    this.description,
    this.video,
  });

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      '_method': 'PATCH',
    };

    if (seasonId != null) map['season_id'] = seasonId;
    if (episodeNumber != null) map['episode_number'] = episodeNumber;
    if (title != null) map['title'] = title;
    if (description != null) map['description'] = description;
    if (video != null) map['video'] = video;

    return FormData.fromMap(map);
  }
}
