part of 'complete_viewer_profile_cubit.dart';

abstract class CompleteViewerProfileState extends Equatable {
  const CompleteViewerProfileState();

  @override
  List<Object?> get props => [];
}

class CompleteViewerProfileInitial extends CompleteViewerProfileState {}

class CompleteViewerProfileLoading extends CompleteViewerProfileState {}

class CompleteViewerProfileSuccess extends CompleteViewerProfileState {
  final BaseResponseModel response;

  const CompleteViewerProfileSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class CompleteViewerProfileError extends CompleteViewerProfileState {
  final String message;

  const CompleteViewerProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
