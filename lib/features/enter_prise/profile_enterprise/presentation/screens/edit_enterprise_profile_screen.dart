import 'package:aflam/features/auth/enterprise/enterprise_auth_flow/data/repository/enterprise_repository.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/data/repository/profile_repository.dart';
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
import '../../../../../../core/widgets/my_works_section/my_works_section.dart';
import '../cubit/edit_profile/enterprise_edit_profile_cubit.dart';
import '../cubit/edit_profile/enterprise_edit_profile_state.dart';
import '../../../../../../core/helpers/messages.dart';
import '../widgets/enterprise_is_available_switch.dart';
import '../widgets/enterprise_profile_photo_picker.dart';

class EditEnterpriseProfileScreen extends StatefulWidget {
  const EditEnterpriseProfileScreen({super.key});

  @override
  State<EditEnterpriseProfileScreen> createState() =>
      _EditEnterpriseProfileScreenState();
}

class _EditEnterpriseProfileScreenState
    extends State<EditEnterpriseProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final user = UserHelper.userNotifier.value;
    if (user != null) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EnterpriseEditProfileCubit(
        profileRepository: getIt<ProfileRepository>(),
        enterpriseRepository: getIt<EnterpriseRepository>(),
      )..init(UserHelper.userNotifier.value!),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.editEnterpriseProfile.tr()),
          centerTitle: true,
        ),
        body:
            BlocConsumer<
              EnterpriseEditProfileCubit,
              EnterpriseEditProfileState
            >(
              listener: (context, state) {
                if (state is EnterpriseEditProfileSuccess) {
                  AppMessages.showSuccess(
                    context,
                    AppStrings.profileUpdatedSuccessfully.tr(),
                  );
                  context.pop(true);
                } else if (state is EnterpriseEditProfileFailure) {
                  AppMessages.showError(context, state.message);
                }
              },
              builder: (context, state) {
                final isLoading = state is EnterpriseEditProfileLoading;
                final cubit = context.read<EnterpriseEditProfileCubit>();

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 24.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        EnterpriseProfilePhotoPicker(
                          currentPhotoUrl:
                              UserHelper.userNotifier.value?.profilePhoto,
                          selectedFile: cubit.selectedProfilePhoto,
                          onPhotoSelected: cubit.pickImage,
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

                        EnterpriseIsAvailableSwitch(
                          value: cubit.isAvailable ?? false,
                          onChanged: (value) {
                            cubit.toggleAvailable(value);
                          },
                        ),
                        SizedBox(height: 24.h),

                        BlocBuilder<
                          EnterpriseEditProfileCubit,
                          EnterpriseEditProfileState
                        >(
                          builder: (context, state) {
                            final worksState =
                                state is EnterpriseEditProfileWorksLoaded
                                ? state
                                : const EnterpriseEditProfileWorksLoaded();

                            return MyWorksSection(
                              searchResults: worksState.searchResults,
                              selectedWorkItems: worksState.selectedWorkItems,
                              isSearching: worksState.isSearching,
                              onSearch: cubit.searchContentCatalog,
                              onAddWorkItem: cubit.addSelectedWorkItem,
                              onRemoveWorkItem: cubit.removeSelectedWorkItem,
                              onUpdateWorkItemRole: cubit.updateWorkItemRole,
                              onClearSearch: cubit.clearSearchResults,
                            );
                          },
                        ),
                        SizedBox(height: 40.h),

                        if (isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          CustomButton(
                            text: AppStrings.saveChanges.tr(),
                            onTap: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                cubit.updateProfile(
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
