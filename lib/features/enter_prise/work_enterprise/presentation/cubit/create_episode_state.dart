abstract class CreateEpisodeState {}

class CreateEpisodeInitial extends CreateEpisodeState {}

class CreateEpisodeLoading extends CreateEpisodeState {}

class CreateEpisodeSuccess extends CreateEpisodeState {
  final int episodeId;
  final String message;

  CreateEpisodeSuccess({
    required this.episodeId,
    required this.message,
  });
}

class CreateEpisodeError extends CreateEpisodeState {
  final String message;

  CreateEpisodeError(this.message);
}
