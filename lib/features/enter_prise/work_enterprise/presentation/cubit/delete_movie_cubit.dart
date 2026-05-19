
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/delete_movie_repository.dart';
import 'delete_movie_state.dart';

class DeleteMovieCubit extends Cubit<DeleteMovieState> {
  final DeleteMovieRepository _repository;

  DeleteMovieCubit(this._repository) : super(DeleteMovieInitial());

  Future<void> deleteMovie(int id) async {
    emit(DeleteMovieLoading());
    final result = await _repository.deleteMovie(id);
    result.fold(
      (error) => emit(DeleteMovieError(error.message)),
      (message) => emit(DeleteMovieSuccess(id: id, message: message)),
    );
  }
}
