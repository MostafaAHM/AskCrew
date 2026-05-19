import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:aflam/features/auth/login/data/model/response/user_model.dart';

abstract class ViewerEditProfileState extends Equatable {
  const ViewerEditProfileState();

  @override
  List<Object?> get props => [];
}

class ViewerEditProfileInitial extends ViewerEditProfileState {}

class ViewerEditProfileLoading extends ViewerEditProfileState {}

class ViewerEditProfileSuccess extends ViewerEditProfileState {
  final UserModel user;

  const ViewerEditProfileSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class ViewerEditProfileFailure extends ViewerEditProfileState {
  final String message;

  const ViewerEditProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ViewerEditProfilePhotoSelected extends ViewerEditProfileState {
  final File file;

  const ViewerEditProfilePhotoSelected(this.file);

  @override
  List<Object?> get props => [file];
}
