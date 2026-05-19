abstract class CreateSeriesState {}

class CreateSeriesInitial extends CreateSeriesState {}

class CreateSeriesLoading extends CreateSeriesState {}

class CreateSeriesSuccess extends CreateSeriesState {
  final int seriesId;
  final String message;

  CreateSeriesSuccess({
    required this.seriesId,
    required this.message,
  });
}

class CreateSeriesError extends CreateSeriesState {
  final String message;

  CreateSeriesError(this.message);
}
