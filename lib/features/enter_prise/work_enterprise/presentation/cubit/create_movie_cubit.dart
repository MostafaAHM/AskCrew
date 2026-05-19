import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/request/create_movie_request_model.dart';
import '../../data/repository/create_movie_repository.dart';
import 'create_movie_state.dart';

class CreateMovieCubit extends Cubit<CreateMovieState> {
  final CreateMovieRepository _repository;

  CreateMovieCubit(this._repository) : super(const CreateMovieInitial());

  Future<void> createMovie(CreateMovieRequestModel model) async {
    emit(const CreateMovieLoading());

    final result = await _repository.createMovie(model: model);

    result.fold(
      (error) => emit(CreateMovieError(error.message)),
      (response) => emit(const CreateMovieSuccess('Movie created successfully!')),
    );
  }

  void reset() {
    emit(const CreateMovieInitial());
  }
}
