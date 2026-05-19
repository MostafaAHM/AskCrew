
abstract class UpdateEpisodeState {}

class UpdateEpisodeInitial extends UpdateEpisodeState {}

class UpdateEpisodeLoading extends UpdateEpisodeState {}

class UpdateEpisodeSuccess extends UpdateEpisodeState {
  final int episodeId;
  final String message;

  UpdateEpisodeSuccess({
    required this.episodeId,
    required this.message,
  });
}

class UpdateEpisodeError extends UpdateEpisodeState {
  final String message;

  UpdateEpisodeError(this.message);
}
