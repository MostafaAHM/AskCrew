part of 'content_video_token_cubit.dart';

abstract class ContentVideoTokenState extends Equatable {
  const ContentVideoTokenState();

  @override
  List<Object?> get props => [];
}

class ContentVideoTokenInitial extends ContentVideoTokenState {
  const ContentVideoTokenInitial();
}

class ContentVideoTokenLoading extends ContentVideoTokenState {
  const ContentVideoTokenLoading();
}

class ContentVideoTokenLoaded extends ContentVideoTokenState {
  final VideoTokenResponseModel videoToken;

  const ContentVideoTokenLoaded(this.videoToken);

  @override
  List<Object?> get props => [videoToken];
}

class ContentVideoTokenError extends ContentVideoTokenState {
  final String message;

  const ContentVideoTokenError(this.message);

  @override
  List<Object?> get props => [message];
}
