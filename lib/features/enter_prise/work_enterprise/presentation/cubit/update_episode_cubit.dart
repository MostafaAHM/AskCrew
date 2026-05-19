
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/update_episode_repository.dart';
import '../../data/models/request/update_episode_request_model.dart';
import 'update_episode_state.dart';

class UpdateEpisodeCubit extends Cubit<UpdateEpisodeState> {
  final UpdateEpisodeRepository _repository;

  UpdateEpisodeCubit(this._repository) : super(UpdateEpisodeInitial());

  Future<void> updateEpisode(UpdateEpisodeRequestModel request) async {
    emit(UpdateEpisodeLoading());
    
    final result = await _repository.updateEpisode(model: request);
    
    result.fold(
      (exception) => emit(UpdateEpisodeError(exception.message)),
      (response) => emit(UpdateEpisodeSuccess(
        episodeId: response.id,
        message: response.message,
      )),
    );
  }
}
