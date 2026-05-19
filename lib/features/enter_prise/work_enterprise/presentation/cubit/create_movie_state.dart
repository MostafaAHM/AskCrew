abstract class CreateMovieState {
  const CreateMovieState();
}

class CreateMovieInitial extends CreateMovieState {
  const CreateMovieInitial();
}

class CreateMovieLoading extends CreateMovieState {
  const CreateMovieLoading();
}

class CreateMovieSuccess extends CreateMovieState {
  final String message;
  
  const CreateMovieSuccess(this.message);
}

class CreateMovieError extends CreateMovieState {
  final String message;
  
  const CreateMovieError(this.message);
}
