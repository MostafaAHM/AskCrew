part of 'video_upload_cubit.dart';

abstract class VideoUploadState extends Equatable {
  const VideoUploadState();

  @override
  List<Object?> get props => [];
}

class VideoUploadInitial extends VideoUploadState {}

class VideoUploadLoading extends VideoUploadState {}

class VideoUploadProgress extends VideoUploadState {
  final int progress;

  const VideoUploadProgress(this.progress);

  @override
  List<Object?> get props => [progress];
}

class VideoUploadPaused extends VideoUploadState {
  final int progress;

  const VideoUploadPaused(this.progress);

  @override
  List<Object?> get props => [progress];
}

class VideoUploadSuccess extends VideoUploadState {
  final String videoId;

  const VideoUploadSuccess({required this.videoId});

  @override
  List<Object?> get props => [videoId];
}

class VideoUploadError extends VideoUploadState {
  final String message;

  const VideoUploadError({required this.message});

  @override
  List<Object?> get props => [message];
}
