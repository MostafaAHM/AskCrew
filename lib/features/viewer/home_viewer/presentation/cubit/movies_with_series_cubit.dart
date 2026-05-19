import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/movies_with_series_repository.dart';
import 'movies_with_series_state.dart';

class MoviesWithSeriesCubit extends Cubit<MoviesWithSeriesState> {
  final MoviesWithSeriesRepository _repository;

  MoviesWithSeriesCubit(this._repository) : super(MoviesWithSeriesInitial());

  Future<void> getMoviesWithSeries({int? categoryId}) async {
    emit(MoviesWithSeriesLoading());
    
    final result = await _repository.getMoviesWithSeries(categoryId: categoryId);
    
    result.fold(
      (error) => emit(MoviesWithSeriesError(error.message)),
      (response) => emit(MoviesWithSeriesLoaded(response)),
    );
  }
}

