import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:aflam/core/app_config/app_strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/di/service_locator.dart';
import '../../../../../../core/helpers/user_helper.dart';
import '../../../../../../core/widgets/buttons/custom_button.dart';
import '../../../../../../core/widgets/fields/custom_text_field.dart';
import '../cubit/edit_profile/viewer_edit_profile_cubit.dart';
import '../cubit/edit_profile/viewer_edit_profile_state.dart';
import '../widgets/viewer_is_available_switch.dart';
import '../../../../../../core/helpers/messages.dart';
import '../widgets/viewer_profile_photo_picker.dart';

class EditViewerProfileScreen extends StatefulWidget {
  const EditViewerProfileScreen({super.key});

  @override
  State<EditViewerProfileScreen> createState() =>
      _EditViewerProfileScreenState();
}

class _EditViewerProfileScreenState extends State<EditViewerProfileScreen> {
  late ViewerEditProfileCubit _cubit;
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ViewerEditProfileCubit>();
    final user = UserHelper.userNotifier.value;
    if (user != null) {
      _cubit.init(user);
      _nameController = TextEditingController(text: user.fullname);
      _bioController = TextEditingController(
        text: user.personalInfo?.toString() ?? '',
      );
    } else {
      _nameController = TextEditingController();
      _bioController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.editViewerProfile.tr()),
          centerTitle: true,
        ),
        body: BlocConsumer<ViewerEditProfileCubit, ViewerEditProfileState>(
          listener: (context, state) {
            if (state is ViewerEditProfileSuccess) {
              AppMessages.showSuccess(
                context,
                AppStrings.profileUpdatedSuccessfully.tr(),
              );
              context.pop(true);
            } else if (state is ViewerEditProfileFailure) {
              AppMessages.showError(context, state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is ViewerEditProfileLoading;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    ViewerProfilePhotoPicker(
                      currentPhotoUrl:
                          UserHelper.userNotifier.value?.profilePhoto,
                      selectedFile: _cubit.selectedProfilePhoto,
                      onPhotoSelected: _cubit.pickImage,
                    ),
                    SizedBox(height: 32.h),

                    CustomTextField(
                      controller: _nameController,
                      label: AppStrings.fullname.tr(),
                      hint: AppStrings.enterYourFullName.tr(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.fullNameRequired.tr();
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),

                    CustomTextField(
                      controller: _bioController,
                      label: AppStrings.personalInfo.tr(),
                      hint: AppStrings.tellUsAboutYourself.tr(),
                      minLines: 3,
                      maxLines: 5,
                    ),
                    SizedBox(height: 20.h),

                    ViewerIsAvailableSwitch(
                      value: _cubit.isAvailable ?? false,
                      onChanged: (value) {
                        _cubit.toggleAvailable(value);
                      },
                    ),
                    SizedBox(height: 40.h),

                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      CustomButton(
                        text: 'Save Changes',
                        onTap: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _cubit.updateProfile(
                              fullname: _nameController.text,
                              personalInfo: _bioController.text,
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
