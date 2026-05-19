
import '../../data/models/response/create_movie_response_model.dart';

abstract class UpdateMovieState {}

class UpdateMovieInitial extends UpdateMovieState {}

class UpdateMovieLoading extends UpdateMovieState {}

class UpdateMovieSuccess extends UpdateMovieState {
  final String message;
  final CreateMovieResponseModel movie;
  UpdateMovieSuccess(this.message, this.movie);
}

class UpdateMovieError extends UpdateMovieState {
  final String message;
  UpdateMovieError(this.message);
}
