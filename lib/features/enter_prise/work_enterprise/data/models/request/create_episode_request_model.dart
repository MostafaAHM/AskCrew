import 'package:dio/dio.dart';

class CreateEpisodeRequestModel {
  final int seasonId;
  final int episodeNumber;
  final String title;
  final String description;
  final String video; // Video ID from Bunny

  CreateEpisodeRequestModel({
    required this.seasonId,
    required this.episodeNumber,
    required this.title,
    required this.description,
    required this.video,
  });

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'season_id': seasonId,
      'episode_number': episodeNumber,
      'title': title,
      'description': description,
      'video': video,
    });
  }
}
