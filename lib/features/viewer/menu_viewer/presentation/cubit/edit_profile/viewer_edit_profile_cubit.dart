import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aflam/features/auth/login/data/model/response/user_model.dart';
import '../../../data/repository/viewer_profile_repository.dart';
import 'viewer_edit_profile_state.dart';

class ViewerEditProfileCubit extends Cubit<ViewerEditProfileState> {
  final ViewerProfileRepository profileRepository;

  ViewerEditProfileCubit({required this.profileRepository})
    : super(ViewerEditProfileInitial());

  File? selectedProfilePhoto;
  bool? isAvailable;

  void init(UserModel currentUser) {
    if (currentUser.profile?.isAvailable != null) {
      isAvailable = currentUser.profile!.isAvailable;
    } else {
      isAvailable = false;
    }
  }

  void pickImage(File file) {
    selectedProfilePhoto = file;
    emit(ViewerEditProfilePhotoSelected(file));
  }

  void toggleAvailable(bool value) {
    isAvailable = value;
    emit(ViewerEditProfileInitial());
  }

  Future<void> updateProfile({
    required String fullname,
    String? personalInfo,
  }) async {
    emit(ViewerEditProfileLoading());

    final result = await profileRepository.updateProfile(
      fullname: fullname,
      profilePhoto: selectedProfilePhoto,
      personalInfo: personalInfo,
      isAvailable: isAvailable ?? false,
    );

    result.fold(
      (failure) => emit(ViewerEditProfileFailure(failure.message)),
      (user) => emit(ViewerEditProfileSuccess(user)),
    );
  }
}
