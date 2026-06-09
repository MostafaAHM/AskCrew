import 'dart:async';

import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/validations/validators.dart';
import 'package:aflam/core/widgets/fields/custom_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aflam/core/app_config/app_roles.dart';
import '../../data/models/response/enterprise_onboarding_data.dart';
import '../cubit/enterprise_onboarding_cubit.dart';
import '../cubit/enterprise_onboarding_state.dart';
import 'dashed_border_container.dart';

class CompanyInfoStep extends StatefulWidget {
  const CompanyInfoStep({super.key});

  @override
  State<CompanyInfoStep> createState() => _CompanyInfoStepState();
}

class _CompanyInfoStepState extends State<CompanyInfoStep> {
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String? _selectedFileName;
  bool _isVisible = false;
  bool _isUploadPressed = false;
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final state = context.read<EnterpriseOnboardingCubit>().state;
    if (state is EnterpriseOnboardingInProgress) {
      final data = state.data;
      _countryController.text = data.country ?? '';
      _cityController.text = data.city ?? '';
      _selectedFileName = data.profilePicturePath?.split('/').last;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _countryController.dispose();
    _cityController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<EnterpriseOnboardingCubit>().searchContentCatalog(query);
    });
  }

  Future<void> _pickFile() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedFileName = image.name;
        });

        context.read<EnterpriseOnboardingCubit>().updateProfilePicture(
          image.path,
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = _selectedFileName != null;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: AnimatedOpacity(
        key: const ValueKey('company_info_step'),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        opacity: _isVisible ? 1 : 0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          offset: _isVisible ? Offset.zero : const Offset(0, 0.05),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                24.height,
                Text(
                  AppStrings.completePersonalInfoTitle.tr(),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightTText,
                  ),
                ),
                8.height,
                Text(
                  AppStrings.completePersonalInfoSubtitle.tr(),
                  style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
                ),
                32.height,
                Row(
                  children: [
                    Text(
                      AppStrings.yourCountry.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTText,
                      ),
                    ),
                    4.width,
                    Text(
                      '*',
                      style: TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
                8.height,
                CustomTextField(
                  label: '',
                  hint: AppStrings.enterYourCountryName.tr(),
                  controller: _countryController,
                  validator: CustomValidators.validateEmpty,
                  onChanged: (value) {
                    context.read<EnterpriseOnboardingCubit>().updateCountry(
                      value,
                    );
                  },
                ),
                20.height,
                Row(
                  children: [
                    Text(
                      AppStrings.yourCity.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTText,
                      ),
                    ),
                    4.width,
                    Text(
                      '*',
                      style: TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
                8.height,
                CustomTextField(
                  label: '',
                  hint: AppStrings.enterYourCityName.tr(),
                  controller: _cityController,
                  validator: CustomValidators.validateEmpty,
                  onChanged: (value) {
                    context.read<EnterpriseOnboardingCubit>().updateCity(value);
                  },
                ),
                32.height,
                Text(
                  '${AppStrings.work.tr()} (optional)',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTText,
                  ),
                ),
                8.height,
                _buildSearchBar(),
                8.height,
                _buildSearchResults(),
                12.height,
                _buildSelectedWorkItems(),
                32.height,
                Row(
                  children: [
                    Text(
                      'uploadYourProfileImage'.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTText,
                      ),
                    ),
                    4.width,
                    Text(
                      '*',
                      style: TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
                16.height,
                Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 360.w),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.all(hasFile ? 3.w : 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: hasFile
                            ? [
                                BoxShadow(
                                  color: AppColors.secondaryColor.withOpacity(
                                    0.12,
                                  ),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : [],
                      ),
                      child: Transform.scale(
                        scale: hasFile ? 1.01 : 1.0,
                        child: DashedBorderContainer(
                          borderColor: hasFile
                              ? AppColors.secondaryColor
                              : AppColors.borderColor,
                          borderWidth: 1.5,
                          borderRadius: 10.r,
                          backgroundColor: AppColors.lightBGColor,
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              children: [
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.greyText,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'choosePhoto'.tr(),
                                        style: TextStyle(
                                          color: AppColors.secondaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'toUploadYourPicture'.tr(),
                                      ),
                                    ],
                                  ),
                                ),
                                8.height,
                                Text(
                                  'supportedFormatsJpegPng'.tr(),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.greyText,
                                  ),
                                ),
                                16.height,
                                GestureDetector(
                                  onTapDown: (_) {
                                    setState(() {
                                      _isUploadPressed = true;
                                    });
                                  },
                                  onTapUp: (_) {
                                    setState(() {
                                      _isUploadPressed = false;
                                    });
                                    _pickFile();
                                  },
                                  onTapCancel: () {
                                    setState(() {
                                      _isUploadPressed = false;
                                    });
                                  },
                                  child: AnimatedScale(
                                    scale: _isUploadPressed ? 0.9 : 1.0,
                                    duration: const Duration(milliseconds: 120),
                                    curve: Curves.easeOut,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      curve: Curves.easeOut,
                                      width: 64.w,
                                      height: 64.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: hasFile
                                            ? LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  AppColors.secondaryColor
                                                      .withOpacity(0.16),
                                                  Colors.white,
                                                ],
                                              )
                                            : const LinearGradient(
                                                colors: [
                                                  Colors.white,
                                                  Colors.white,
                                                ],
                                              ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 48.w,
                                          height: 48.h,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                          child: Icon(
                                            Icons.upload_outlined,
                                            color: hasFile
                                                ? AppColors.secondaryColor
                                                : AppColors.greyText,
                                            size: 24.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                8.height,
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  switchInCurve: Curves.easeOut,
                                  switchOutCurve: Curves.easeIn,
                                  child: _selectedFileName == null
                                      ? const SizedBox.shrink()
                                      : TweenAnimationBuilder<double>(
                                          key: const ValueKey('file_name'),
                                          tween: Tween(begin: 10, end: 0),
                                          duration: const Duration(
                                            milliseconds: 220,
                                          ),
                                          curve: Curves.easeOut,
                                          builder: (context, value, child) {
                                            return Transform.translate(
                                              offset: Offset(0, value),
                                              child: Opacity(
                                                opacity:
                                                    1 -
                                                    (value / 10).clamp(0, 1),
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              8.height,
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12.w,
                                                  vertical: 8.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        999.r,
                                                      ),
                                                  border: Border.all(
                                                    color: AppColors
                                                        .secondaryColor
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: AppColors.green,
                                                      size: 16.sp,
                                                    ),
                                                    8.width,
                                                    Flexible(
                                                      child: Text(
                                                        _selectedFileName!,
                                                        style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color: AppColors
                                                              .lightMainText,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              4.height,
                                            ],
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                24.height,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        style: TextStyle(fontSize: 14.sp, color: AppColors.lightMainText),
        decoration: InputDecoration(
          hintText: AppStrings.selectYourWork.tr(),
          hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.hintColor),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.secondaryColor,
            size: 22.sp,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    context
                        .read<EnterpriseOnboardingCubit>()
                        .clearSearchResults();
                  },
                  child: Icon(
                    Icons.close,
                    color: AppColors.greyText,
                    size: 20.sp,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<EnterpriseOnboardingCubit, EnterpriseOnboardingState>(
      builder: (context, state) {
        if (state is! EnterpriseOnboardingInProgress) {
          return const SizedBox.shrink();
        }

        final results = state.data.searchResults ?? [];
        final selectedItems = state.data.selectedWorkItems ?? [];

        if (results.isEmpty) return const SizedBox.shrink();

        return Container(
          constraints: BoxConstraints(maxHeight: 220.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: results.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: AppColors.borderColor, indent: 60.w),
            itemBuilder: (context, index) {
              final item = results[index];
              final isSelected = selectedItems.any(
                (s) => s.id == item.id && s.type == item.type,
              );

              return ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: item.poster != null
                      ? Image.network(
                          item.poster!,
                          width: 40.w,
                          height: 56.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 40.w,
                            height: 56.h,
                            color: AppColors.lightBGColor,
                            child: Icon(
                              Icons.movie_outlined,
                              size: 20.sp,
                              color: AppColors.greyText,
                            ),
                          ),
                        )
                      : Container(
                          width: 40.w,
                          height: 56.h,
                          color: AppColors.lightBGColor,
                          child: Icon(
                            Icons.movie_outlined,
                            size: 20.sp,
                            color: AppColors.greyText,
                          ),
                        ),
                ),
                title: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightMainText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  item.type,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: AppColors.secondaryColor,
                        size: 22.sp,
                      )
                    : Icon(
                        Icons.add_circle_outline,
                        color: AppColors.greyText,
                        size: 22.sp,
                      ),
                onTap: () {
                  final cubit = context.read<EnterpriseOnboardingCubit>();
                  if (isSelected) {
                    cubit.removeSelectedWorkItem(item.id, item.type);
                  } else {
                    cubit.addSelectedWorkItem(item);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSelectedWorkItems() {
    return BlocBuilder<EnterpriseOnboardingCubit, EnterpriseOnboardingState>(
      builder: (context, state) {
        if (state is! EnterpriseOnboardingInProgress) {
          return const SizedBox.shrink();
        }

        final selectedItems = state.data.selectedWorkItems ?? [];
        if (selectedItems.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: selectedItems.map((item) {
            return _SelectedWorkItemCard(
              item: item,
              onRemove: () {
                context
                    .read<EnterpriseOnboardingCubit>()
                    .removeSelectedWorkItem(item.id, item.type);
              },
              onRoleChanged: (role) {
                context.read<EnterpriseOnboardingCubit>().updateWorkItemRole(
                  item.id,
                  item.type,
                  role,
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class _SelectedWorkItemCard extends StatelessWidget {
  final SelectedWorkItem item;
  final VoidCallback onRemove;
  final ValueChanged<String> onRoleChanged;

  const _SelectedWorkItemCard({
    required this.item,
    required this.onRemove,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.secondaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: item.poster != null
                ? Image.network(
                    item.poster!,
                    width: 48.w,
                    height: 64.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 48.w,
                      height: 64.h,
                      color: AppColors.lightBGColor,
                      child: Icon(
                        Icons.movie_outlined,
                        size: 24.sp,
                        color: AppColors.greyText,
                      ),
                    ),
                  )
                : Container(
                    width: 48.w,
                    height: 64.h,
                    color: AppColors.lightBGColor,
                    child: Icon(
                      Icons.movie_outlined,
                      size: 24.sp,
                      color: AppColors.greyText,
                    ),
                  ),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightMainText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: onRemove,
                      child: Icon(
                        Icons.close,
                        size: 18.sp,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
                4.height,
                Text(
                  item.type,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
                ),
                8.height,
                Container(
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: AppColors.lightBGColor,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: item.role != null
                          ? AppColors.secondaryColor
                          : AppColors.borderColor,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: Colors.white,
                      value: item.role,
                      hint: Text(
                        "Your role".tr(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.hintColor,
                        ),
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.secondaryColor,
                        size: 18.sp,
                      ),
                      isExpanded: true,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.lightMainText,
                      ),
                      items: AppRoles.roles.map((String role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(
                            role.replaceAll('_', ' ').tr(),
                            style: TextStyle(fontSize: 12.sp),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          onRoleChanged(value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
