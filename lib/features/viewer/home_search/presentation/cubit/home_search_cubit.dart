import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aflam/core/models/movie_model.dart' as core_model;
import 'package:aflam/features/enter_prise/work_enterprise/data/repository/get_movies_repository.dart';
import 'home_search_state.dart';

class HomeSearchCubit extends Cubit<HomeSearchState> {
  final GetMoviesRepository _getMoviesRepository;
  Timer? _debounce;

  HomeSearchCubit(this._getMoviesRepository) : super(HomeSearchInitial());

  void searchMovies(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      emit(HomeSearchInitial());
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _executeSearch(query);
    });
  }

  Future<void> _executeSearch(String query) async {
    emit(HomeSearchLoading());

    final result = await _getMoviesRepository.getMovies(query: query);

    result.fold((failure) => emit(HomeSearchError(message: failure.message)), (
      response,
    ) {
      if (response.results.isEmpty) {
        emit(HomeSearchEmpty());
      } else {
        final movies = response.results.map((e) {
          return core_model.MovieModel(
            id: e.id.toString(),
            title: e.name,
            posterUrl: e.coverImage ?? '',
            releaseDate: DateTime.tryParse(e.createdAt) ?? DateTime.now(),
            rating: e.ratingMean ?? 0.0,
          );
        }).toList();
        emit(HomeSearchLoaded(movies: movies));
      }
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
