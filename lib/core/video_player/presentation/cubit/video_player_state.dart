part of 'video_player_cubit.dart';

abstract class VideoPlayerState extends Equatable {
  const VideoPlayerState();

  @override
  List<Object?> get props => [];
}

class VideoPlayerInitial extends VideoPlayerState {
  const VideoPlayerInitial();
}

class VideoPlayerLoading extends VideoPlayerState {
  const VideoPlayerLoading();
}

class VideoPlayerLoaded extends VideoPlayerState {
  final VideoTokenResponseModel videoToken;

  const VideoPlayerLoaded(this.videoToken);

  @override
  List<Object?> get props => [videoToken];
}

class VideoPlayerError extends VideoPlayerState {
  final String message;

  const VideoPlayerError(this.message);

  @override
  List<Object?> get props => [message];
}
