import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/video_player_repository.dart';
import '../../data/models/video_token_response_model.dart';

part 'video_player_state.dart';

class VideoPlayerCubit extends Cubit<VideoPlayerState> {
  final VideoPlayerRepository _repository;

  VideoPlayerCubit(this._repository) : super(VideoPlayerInitial());

  Future<void> getVideoToken({
    required String contentType,
    required int contentId,
    bool playTrailer = false,
  }) async {
    emit(VideoPlayerLoading());

    final result = await _repository.getVideoToken(
      contentType: contentType,
      contentId: contentId,
      playTrailer: playTrailer,
    );

    result.fold(
      (error) => emit(VideoPlayerError(error.message)),
      (videoToken) => emit(VideoPlayerLoaded(videoToken)),
    );
  }
}
