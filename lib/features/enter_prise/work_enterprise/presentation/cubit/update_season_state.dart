
abstract class UpdateSeasonState {}

class UpdateSeasonInitial extends UpdateSeasonState {}

class UpdateSeasonLoading extends UpdateSeasonState {}

class UpdateSeasonSuccess extends UpdateSeasonState {
  final int seasonId;
  final String message;

  UpdateSeasonSuccess({
    required this.seasonId,
    required this.message,
  });
}

class UpdateSeasonError extends UpdateSeasonState {
  final String message;

  UpdateSeasonError(this.message);
}
