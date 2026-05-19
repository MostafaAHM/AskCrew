import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/get_movies_repository.dart';
import 'get_movies_state.dart';

class GetMoviesCubit extends Cubit<GetMoviesState> {
  final GetMoviesRepository _repository;
  int _page = 1;
  bool _isFetching = false;

  GetMoviesCubit(this._repository) : super(GetMoviesInitial());

  Future<void> getMovies({bool refresh = false}) async {
    if (_isFetching) return;
    if (refresh) {
      _page = 1;
      emit(GetMoviesLoading());
    }

    _isFetching = true;
    final result = await _repository.getMovies(page: _page);
    _isFetching = false;

    result.fold(
      (failure) => emit(GetMoviesError(failure.message)),
      (response) {
        if (refresh) {
          emit(GetMoviesLoaded(response.results, hasMore: response.next != null));
        } else {
          final currentState = state;
          if (currentState is GetMoviesLoaded) {
            final currentIds = currentState.movies.map((m) => m.id).toSet();
            final newMovies = response.results.where((m) => !currentIds.contains(m.id)).toList();
            emit(GetMoviesLoaded(
              currentState.movies + newMovies,
              hasMore: response.next != null,
            ));
          } else {
            emit(GetMoviesLoaded(response.results, hasMore: response.next != null));
          }
        }
        if (response.next != null) {
          _page++;
        }
      },
    );
  }
  void removeMovie(int id) {
    if (state is GetMoviesLoaded) {
      final currentMovies = (state as GetMoviesLoaded).movies;
      final updatedMovies = currentMovies.where((m) => m.id != id).toList();
      emit(GetMoviesLoaded(updatedMovies, hasMore: (state as GetMoviesLoaded).hasMore));
    }
  }
}
