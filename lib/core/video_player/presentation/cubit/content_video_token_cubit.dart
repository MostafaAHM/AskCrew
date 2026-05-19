import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/content_video_token_repository.dart';
import '../../data/models/video_token_response_model.dart';

part 'content_video_token_state.dart';

class ContentVideoTokenCubit extends Cubit<ContentVideoTokenState> {
  final ContentVideoTokenRepository _repository;

  ContentVideoTokenCubit(this._repository) : super(ContentVideoTokenInitial());

  Future<void> getContentVideoToken({
    required String contentType,
    required int contentId,
  }) async {
    emit(ContentVideoTokenLoading());

    final result = await _repository.getContentVideoToken(
      contentType: contentType,
      contentId: contentId,
    );

    result.fold(
      (error) => emit(ContentVideoTokenError(error.message)),
      (videoToken) => emit(ContentVideoTokenLoaded(videoToken)),
    );
  }

  Future<void> getContentVideoTokenForAdvertise({
    required int advertiseId,
  }) async {
    await getContentVideoToken(
      contentType: 'advertise',
      contentId: advertiseId,
    );
  }
}
