
abstract class UpdateSeriesState {}

class UpdateSeriesInitial extends UpdateSeriesState {}

class UpdateSeriesLoading extends UpdateSeriesState {}

class UpdateSeriesSuccess extends UpdateSeriesState {
  final int seriesId;
  final String message;

  UpdateSeriesSuccess({
    required this.seriesId,
    required this.message,
  });
}

class UpdateSeriesError extends UpdateSeriesState {
  final String message;

  UpdateSeriesError(this.message);
}
