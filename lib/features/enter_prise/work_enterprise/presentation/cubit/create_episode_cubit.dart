import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/create_episode_repository.dart';
import '../../data/models/request/create_episode_request_model.dart';
import 'create_episode_state.dart';

class CreateEpisodeCubit extends Cubit<CreateEpisodeState> {
  final CreateEpisodeRepository _repository;

  CreateEpisodeCubit(this._repository) : super(CreateEpisodeInitial());

  Future<void> createEpisode(CreateEpisodeRequestModel request) async {
    emit(CreateEpisodeLoading());
    
    final result = await _repository.createEpisode(model: request);
    
    result.fold(
      (exception) => emit(CreateEpisodeError(exception.message)),
      (response) => emit(CreateEpisodeSuccess(
        episodeId: response.id,
        message: response.message,
      )),
    );
  }
}
