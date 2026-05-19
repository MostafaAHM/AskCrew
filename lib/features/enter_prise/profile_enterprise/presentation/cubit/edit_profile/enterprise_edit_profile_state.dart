import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:aflam/features/auth/login/data/model/response/user_model.dart';
import 'package:aflam/features/auth/enterprise/enterprise_auth_flow/data/models/response/enterprise_onboarding_data.dart';

abstract class EnterpriseEditProfileState extends Equatable {
  const EnterpriseEditProfileState();

  @override
  List<Object?> get props => [];
}

class EnterpriseEditProfileInitial extends EnterpriseEditProfileState {}

class EnterpriseEditProfileLoading extends EnterpriseEditProfileState {}

class EnterpriseEditProfileSuccess extends EnterpriseEditProfileState {
  final UserModel user;

  const EnterpriseEditProfileSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class EnterpriseEditProfileFailure extends EnterpriseEditProfileState {
  final String message;

  const EnterpriseEditProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class EnterpriseEditProfilePhotoSelected extends EnterpriseEditProfileState {
  final File file;

  const EnterpriseEditProfilePhotoSelected(this.file);

  @override
  List<Object?> get props => [file];
}

class EnterpriseEditProfileWorksLoaded extends EnterpriseEditProfileState {
  final List<ContentCatalogItem> searchResults;
  final List<SelectedWorkItem> selectedWorkItems;
  final bool isSearching;

  const EnterpriseEditProfileWorksLoaded({
    this.searchResults = const [],
    this.selectedWorkItems = const [],
    this.isSearching = false,
  });

  @override
  List<Object?> get props => [searchResults, selectedWorkItems, isSearching];
}
