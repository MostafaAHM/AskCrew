import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/response/episodes_response_model.dart';
import '../../data/repository/get_episodes_repository.dart';

part 'get_episodes_state.dart';

class GetEpisodesCubit extends Cubit<GetEpisodesState> {
  final GetEpisodesRepository _repository;

  GetEpisodesCubit(this._repository) : super(GetEpisodesInitial());

  Future<void> getEpisodes(int seasonId) async {
    emit(GetEpisodesLoading());
    final result = await _repository.getEpisodes(seasonId);
    result.fold(
      (error) => emit(GetEpisodesError(error.message)),
      (response) => emit(GetEpisodesLoaded(response.results)),
    );
  }
}
