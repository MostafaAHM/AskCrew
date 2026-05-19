
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/request/update_movie_request_model.dart';
import '../../data/repository/update_movie_repository.dart';
import 'update_movie_state.dart';

class UpdateMovieCubit extends Cubit<UpdateMovieState> {
  final UpdateMovieRepository repository;

  UpdateMovieCubit(this.repository) : super(UpdateMovieInitial());

  Future<void> updateMovie(UpdateMovieRequestModel model) async {
    emit(UpdateMovieLoading());
    final result = await repository.updateMovie(model: model);
    result.fold(
      (error) => emit(UpdateMovieError(error.message)),
      (success) => emit(UpdateMovieSuccess("Movie updated successfully", success)),
    );
  }
}
