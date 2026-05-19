import '../../data/models/response/movie_model.dart';

abstract class GetMoviesState {}

class GetMoviesInitial extends GetMoviesState {}

class GetMoviesLoading extends GetMoviesState {}

class GetMoviesLoaded extends GetMoviesState {
  final List<MovieModel> movies;
  final bool hasMore;
  GetMoviesLoaded(this.movies, {this.hasMore = false});
}

class GetMoviesError extends GetMoviesState {
  final String message;
  GetMoviesError(this.message);
}
