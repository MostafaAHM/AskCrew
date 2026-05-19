import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/get_series_repository.dart';
import '../../data/repository/get_seasons_repository.dart';
import '../../data/repository/get_episodes_repository.dart';
import '../../data/repository/delete_advertise_repository.dart';
import '../../data/repository/delete_movie_repository.dart';


part 'content_management_state.dart';

class ContentManagementCubit extends Cubit<ContentManagementState> {
  final GetSeriesRepository _seriesRepository;
  final GetSeasonsRepository _seasonsRepository;
  final GetEpisodesRepository _episodesRepository;
  final DeleteAdvertiseRepository _deleteAdvertiseRepository;
  final DeleteMovieRepository _deleteMovieRepository;

  ContentManagementCubit(
    this._seriesRepository,
    this._seasonsRepository,
    this._episodesRepository,
    this._deleteAdvertiseRepository,
    this._deleteMovieRepository,
  ) : super(ContentManagementInitial());

  // Movie
  Future<void> deleteMovie(int id) async {
    emit(ContentManagementLoading());
    final result = await _deleteMovieRepository.deleteMovie(id);
    result.fold(
      (l) => emit(ContentManagementError(l.message)),
      (r) => emit(ContentManagementSuccess(message: 'Movie deleted successfully')),
    );
  }

  // Series
  Future<void> deleteSeries(int id) async {
    emit(ContentManagementLoading());
    final result = await _seriesRepository.deleteSeries(id);
    result.fold(
      (l) => emit(ContentManagementError(l.message)),
      (r) => emit(ContentManagementSuccess(message: 'Series deleted successfully')),
    );
  }


  // Season
  Future<void> deleteSeason(int id) async {
     emit(ContentManagementLoading());
     final result = await _seasonsRepository.deleteSeason(id);
     result.fold(
       (l) => emit(ContentManagementError(l.message)),
       (r) => emit(ContentManagementSuccess(message: 'Season deleted successfully')),
     );
  }
  

  // Episode
  Future<void> deleteEpisode(int id) async {
     emit(ContentManagementLoading());
     final result = await _episodesRepository.deleteEpisode(id);
     result.fold(
       (l) => emit(ContentManagementError(l.message)),
       (r) => emit(ContentManagementSuccess(message: 'Episode deleted successfully')),
     );
  }


  // Advertise
  Future<void> deleteAdvertise(int id) async {
     emit(ContentManagementLoading());
     final result = await _deleteAdvertiseRepository.deleteAdvertise(advertiseId: id);
     result.fold(
       (l) => emit(ContentManagementError(l.message)),
       (r) => emit(ContentManagementSuccess(message: 'Advertise deleted successfully')),
     );
  }
}
