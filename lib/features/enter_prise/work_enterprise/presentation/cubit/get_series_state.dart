part of 'get_series_cubit.dart';

abstract class GetSeriesState {}

class GetSeriesInitial extends GetSeriesState {}

class GetSeriesLoading extends GetSeriesState {}

class GetSeriesLoaded extends GetSeriesState {
  final List<SeriesModel> series;
  GetSeriesLoaded(this.series);
}

class GetSeriesError extends GetSeriesState {
  final String message;
  GetSeriesError(this.message);
}
