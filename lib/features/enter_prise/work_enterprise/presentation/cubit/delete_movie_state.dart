
abstract class DeleteMovieState {}

class DeleteMovieInitial extends DeleteMovieState {}

class DeleteMovieLoading extends DeleteMovieState {}

class DeleteMovieSuccess extends DeleteMovieState {
  final int id;
  final String message;
  DeleteMovieSuccess({required this.id, required this.message});
}

class DeleteMovieError extends DeleteMovieState {
  final String message;
  DeleteMovieError(this.message);
}
