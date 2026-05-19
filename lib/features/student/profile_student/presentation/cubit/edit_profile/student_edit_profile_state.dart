import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:aflam/features/auth/login/data/model/response/user_model.dart';
import 'package:aflam/features/auth/enterprise/enterprise_auth_flow/data/models/response/enterprise_onboarding_data.dart';

abstract class StudentEditProfileState extends Equatable {
  const StudentEditProfileState();

  @override
  List<Object?> get props => [];
}

class StudentEditProfileInitial extends StudentEditProfileState {}

class StudentEditProfileLoading extends StudentEditProfileState {}

class StudentEditProfileSuccess extends StudentEditProfileState {
  final UserModel user;

  const StudentEditProfileSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class StudentEditProfileFailure extends StudentEditProfileState {
  final String message;

  const StudentEditProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class StudentEditProfilePhotoSelected extends StudentEditProfileState {
  final File file;

  const StudentEditProfilePhotoSelected(this.file);

  @override
  List<Object?> get props => [file];
}

class StudentEditProfileWorksLoaded extends StudentEditProfileState {
  final List<ContentCatalogItem> searchResults;
  final List<SelectedWorkItem> selectedWorkItems;
  final bool isSearching;

  const StudentEditProfileWorksLoaded({
    this.searchResults = const [],
    this.selectedWorkItems = const [],
    this.isSearching = false,
  });

  @override
  List<Object?> get props => [searchResults, selectedWorkItems, isSearching];
}
