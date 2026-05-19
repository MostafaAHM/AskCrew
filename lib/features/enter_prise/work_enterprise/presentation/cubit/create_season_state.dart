abstract class CreateSeasonState {}

class CreateSeasonInitial extends CreateSeasonState {}

class CreateSeasonLoading extends CreateSeasonState {}

class CreateSeasonSuccess extends CreateSeasonState {
  final int seasonId;
  final String message;

  CreateSeasonSuccess({
    required this.seasonId,
    required this.message,
  });
}

class CreateSeasonError extends CreateSeasonState {
  final String message;

  CreateSeasonError(this.message);
}
