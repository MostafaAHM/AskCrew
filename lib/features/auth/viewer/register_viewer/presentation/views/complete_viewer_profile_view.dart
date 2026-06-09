import 'package:aflam/core/widgets/animated_loading/animated_loading.dart';
import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/helpers/user_helper.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/core/widgets/fields/custom_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:aflam/config/routes/routes.dart';
import 'package:aflam/features/shared/categories/presentation/cubit/categories_cubit.dart';
import '../cubit/complete_viewer_profile_cubit.dart';

class CompleteViewerProfileView extends StatefulWidget {
  const CompleteViewerProfileView({super.key});

  @override
  State<CompleteViewerProfileView> createState() =>
      _CompleteViewerProfileViewState();
}

class _CompleteViewerProfileViewState extends State<CompleteViewerProfileView> {
  final _nameController = TextEditingController();
  final List<int> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    final currentUser = UserHelper.userNotifier.value;
    if (currentUser != null) {
      _nameController.text = currentUser.fullname;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleCategory(int categoryId) {
    setState(() {
      if (_selectedCategories.contains(categoryId)) {
        _selectedCategories.remove(categoryId);
      } else {
        _selectedCategories.add(categoryId);
      }
    });
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppMessages.showError(context, 'nameRequired'.tr());
      return;
    }

    context.read<CompleteViewerProfileCubit>().completeProfile(
      name: name,
      favoriteCategories: _selectedCategories.isNotEmpty
          ? _selectedCategories
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CompleteViewerProfileCubit(getIt())),
        BlocProvider(
          create: (context) => getIt<CategoriesCubit>()..getCategories(),
        ),
      ],
      child:
          BlocListener<CompleteViewerProfileCubit, CompleteViewerProfileState>(
            listener: (context, state) {
              if (state is CompleteViewerProfileLoading) {
                AppMessages.showLoading(context);
              } else if (state is CompleteViewerProfileSuccess) {
                AppMessages.hideLoading(context);
                AppMessages.showSuccess(
                  context,
                  state.response.message ?? 'profileCompletedSuccessfully'.tr(),
                );
                context.go(Routes.viewerHome);
              } else if (state is CompleteViewerProfileError) {
                AppMessages.hideLoading(context);
                AppMessages.showError(context, state.message);
              }
            },
            child: Scaffold(
              appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'completeYourProfile'.tr(),
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightTText,
                        ),
                      ),
                      8.height,
                      Text(
                        'completeViewerProfileDescription'.tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      32.height,
                      CustomTextField(
                        label: 'Name'.tr(),
                        hint: 'enterYourName'.tr(),
                        controller: _nameController,
                      ),
                      24.height,
                      Text(
                        'favoriteCategories'.tr(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightTText,
                        ),
                      ),
                      8.height,
                      Text(
                        'selectFavoriteCategoriesOptional'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      16.height,
                      BlocBuilder<CategoriesCubit, CategoriesState>(
                        builder: (context, state) {
                          if (state.status == CategoriesStatus.loading) {
                            return const Center(
                              child: AnimatedLoading(),
                            );
                          }

                          if (state.status == CategoriesStatus.error) {
                            return Center(
                              child: Text(
                                state.errorMessage ??
                                    'errorLoadingCategories'.tr(),
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (state.categories.isEmpty) {
                            return Center(
                              child: Text('noCategoriesAvailable'.tr()),
                            );
                          }

                          return Wrap(
                            spacing: 12.w,
                            runSpacing: 12.h,
                            children: state.categories.map((category) {
                              final isSelected = _selectedCategories.contains(
                                category.id,
                              );
                              return GestureDetector(
                                onTap: () => _toggleCategory(category.id),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.secondaryColor
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.secondaryColor
                                          : Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    category.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 14.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      40.height,
                      CustomButton(
                        text: 'completeProfile'.tr(),
                        isBackgroundGradient: true,
                        onTap: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
