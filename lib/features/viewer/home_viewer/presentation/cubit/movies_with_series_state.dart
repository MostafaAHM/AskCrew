import 'package:equatable/equatable.dart';
import '../../data/model/movies_with_series_model.dart';

abstract class MoviesWithSeriesState extends Equatable {
  const MoviesWithSeriesState();

  @override
  List<Object?> get props => [];
}

class MoviesWithSeriesInitial extends MoviesWithSeriesState {}

class MoviesWithSeriesLoading extends MoviesWithSeriesState {}

class MoviesWithSeriesLoaded extends MoviesWithSeriesState {
  final MoviesWithSeriesResponseModel response;

  const MoviesWithSeriesLoaded(this.response);

  @override
  List<Object?> get props => [response];
}

class MoviesWithSeriesError extends MoviesWithSeriesState {
  final String message;

  const MoviesWithSeriesError(this.message);

  @override
  List<Object?> get props => [message];
}

