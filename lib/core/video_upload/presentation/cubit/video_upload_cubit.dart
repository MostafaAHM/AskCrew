import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../data/video_upload_service.dart';

part 'video_upload_state.dart';

class VideoUploadCubit extends Cubit<VideoUploadState> {
  final VideoUploadService _videoUploadService;

  CancelToken? _cancelToken;

  File? _currentVideoFile;
  String? _videoId;
  String? _libraryId;
  String? _uploadEndpoint;
  String? _authSignature;
  int? _authExpire;
  String? _uploadLocation;
  int _lastProgress = 0;

  VideoUploadCubit(this._videoUploadService) : super(VideoUploadInitial());

  Future<void> uploadVideo({required File videoFile}) async {
    try {
      emit(VideoUploadLoading());

      _currentVideoFile = videoFile;
      _cancelToken = CancelToken();

      final initResponse = await _videoUploadService.initializeVideo();

      _videoId = initResponse.videoId;
      _libraryId = initResponse.libraryId;
      _uploadEndpoint = initResponse.uploadEndpoint;
      _authSignature = initResponse.authorizationSignature;
      _authExpire = initResponse.authorizationExpire;

      await _startUpload();
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        emit(VideoUploadError(message: e.toString()));
      } else {
        emit(VideoUploadError(message: e.toString()));
      }
    }
  }

  Future<void> uploadExploreVideo({required File videoFile}) async {
    try {
      emit(VideoUploadLoading());

      _currentVideoFile = videoFile;
      _cancelToken = CancelToken();

      final initResponse = await _videoUploadService.initializeExploreVideo();

      _videoId = initResponse.videoId;
      _libraryId = initResponse.libraryId;
      _uploadEndpoint = initResponse.uploadEndpoint;
      _authSignature = initResponse.authorizationSignature;
      _authExpire = initResponse.authorizationExpire;

      await _startUpload();
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        emit(VideoUploadError(message: e.toString()));
      } else {
        emit(VideoUploadError(message: e.toString()));
      }
    }
  }

  Future<void> _startUpload() async {
    if (_currentVideoFile == null || _videoId == null) return;

    try {
      _cancelToken = CancelToken();

      final location = await _videoUploadService.uploadVideoToBunny(
        videoFile: _currentVideoFile!,
        videoId: _videoId!,
        libraryId: _libraryId!,
        uploadEndpoint: _uploadEndpoint!,
        authorizationSignature: _authSignature!,
        authorizationExpire: _authExpire!,
        existingUploadLocation: _uploadLocation,
        cancelToken: _cancelToken,
        onProgress: (sent, total) {
          final progress = (sent / total * 100).toInt();
          _lastProgress = progress;
          emit(VideoUploadProgress(progress));
        },
      );

      _uploadLocation = location;
      emit(VideoUploadSuccess(videoId: _videoId!));
      _cleanup();
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
      } else {
        emit(VideoUploadError(message: e.toString()));
        _cleanup();
      }
    }
  }

  void pauseUpload() {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('Paused by user');
      emit(VideoUploadPaused(_lastProgress));
    }
  }

  void resumeUpload() {
    if (state is VideoUploadPaused) {
      emit(VideoUploadProgress(_lastProgress));
      _startUpload();
    }
  }

  void cancelUpload() {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('Cancelled by user');
    }
    _cleanup();
    emit(VideoUploadInitial());
  }

  void _cleanup() {
    _currentVideoFile = null;
    _videoId = null;
    _libraryId = null;
    _uploadEndpoint = null;
    _authSignature = null;
    _authExpire = null;
    _uploadLocation = null;
    _lastProgress = 0;
    _cancelToken = null;
  }

  void reset() {
    cancelUpload();
  }
}
