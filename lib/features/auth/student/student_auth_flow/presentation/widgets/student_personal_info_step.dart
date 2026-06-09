import 'dart:async';

import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/validations/validators.dart';
import 'package:aflam/core/widgets/fields/custom_text_field.dart';
import 'package:aflam/features/auth/enterprise/enterprise_auth_flow/presentation/widgets/dashed_border_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aflam/core/app_config/app_roles.dart';
import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/features/auth/enterprise/enterprise_auth_flow/data/models/response/enterprise_onboarding_data.dart'
    hide WorkItem;
import '../cubit/student_onboarding_cubit.dart';
import '../cubit/student_onboarding_state.dart';

class StudentPersonalInfoStep extends StatefulWidget {
  const StudentPersonalInfoStep({super.key});

  @override
  State<StudentPersonalInfoStep> createState() =>
      _StudentPersonalInfoStepState();
}

class _StudentPersonalInfoStepState extends State<StudentPersonalInfoStep> {
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _personalInfoController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _emailAddressController = TextEditingController();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  Timer? _debounce;
  String _searchQuery = '';

  String? _selectedPictureFileName;
  String? _selectedCvFileName;

  bool _isVisible = false;
  bool _isPicturePressed = false;
  bool _isCvPressed = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<StudentOnboardingCubit>().state;
    if (state is StudentOnboardingInProgress) {
      final data = state.data;
      _countryController.text = data.country ?? '';
      _cityController.text = data.city ?? '';
      _personalInfoController.text = data.personalInfo ?? '';
      _selectedPictureFileName = data.profilePicturePath?.split('/').last;
      _selectedCvFileName = data.cvPath?.split('/').last;
      _facebookController.text = data.facebookLink ?? '';
      _instagramController.text = data.instagramLink ?? '';
      _linkedinController.text = data.linkedinLink ?? '';
      _youtubeController.text = data.youtubeLink ?? '';
      _emailAddressController.text = data.emailAddress ?? '';
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
    _personalInfoController.dispose();
    _portfolioController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    _youtubeController.dispose();
    _emailAddressController.dispose();
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
      context.read<StudentOnboardingCubit>().searchContentCatalog(query);
    });
  }

  Future<void> _pickPicture() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedPictureFileName = image.name;
        });

        context.read<StudentOnboardingCubit>().updateProfilePicture(image.path);
      }
    } catch (e) {
      debugPrint('Error picking picture: $e');
    }
  }

  Future<void> _pickCv() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedCvFileName = result.files.single.name;
        });

        context.read<StudentOnboardingCubit>().updateCvPath(
          result.files.single.path!,
        );
      }
    } catch (e) {
      debugPrint('Error picking CV: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentOnboardingCubit, StudentOnboardingState>(
      builder: (context, state) {
        if (state is! StudentOnboardingInProgress) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<StudentOnboardingCubit>();

        final hasPicture = _selectedPictureFileName != null;
        final hasCv = _selectedCvFileName != null;

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
          opacity: _isVisible ? 1 : 0,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOut,
            offset: _isVisible ? Offset.zero : const Offset(0, 0.04),
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
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                  32.height,
                  Row(
                    children: [
                      Text(
                        'yourCountry'.tr(),
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
                    hint: 'enterYourCountryName'.tr(),
                    controller: _countryController,
                    validator: CustomValidators.validateEmpty,
                    onChanged: cubit.updateCountry,
                  ),
                  20.height,
                  Row(
                    children: [
                      Text(
                        'yourCity'.tr(),
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
                    hint: 'enterYourCityName'.tr(),
                    controller: _cityController,
                    validator: CustomValidators.validateEmpty,
                    onChanged: cubit.updateCity,
                  ),
                  20.height,
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
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        padding: EdgeInsets.all(hasPicture ? 3.w : 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: hasPicture
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
                        child: DashedBorderContainer(
                          borderColor: hasPicture
                              ? AppColors.secondaryColor
                              : AppColors.borderColor,
                          borderWidth: 1.5,
                          borderRadius: 10.r,
                          backgroundColor: AppColors.lightBGColor,
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
                                    TextSpan(text: 'toUploadYourPicture'.tr()),
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
                                    _isPicturePressed = true;
                                  });
                                },
                                onTapUp: (_) {
                                  setState(() {
                                    _isPicturePressed = false;
                                  });
                                  _pickPicture();
                                },
                                onTapCancel: () {
                                  setState(() {
                                    _isPicturePressed = false;
                                  });
                                },
                                child: AnimatedScale(
                                  scale: _isPicturePressed ? 0.9 : 1.0,
                                  duration: const Duration(milliseconds: 120),
                                  curve: Curves.easeOut,
                                  child: Container(
                                    width: 56.w,
                                    height: 56.h,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: hasPicture
                                          ? LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppColors.secondaryColor
                                                    .withOpacity(0.18),
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
                                        width: 44.w,
                                        height: 44.h,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: Icon(
                                          Icons.upload_outlined,
                                          color: hasPicture
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
                                duration: const Duration(milliseconds: 220),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                child: _selectedPictureFileName == null
                                    ? const SizedBox.shrink()
                                    : TweenAnimationBuilder<double>(
                                        key: const ValueKey(
                                          'picture_file_name',
                                        ),
                                        tween: Tween(begin: 10, end: 0),
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        curve: Curves.easeOut,
                                        builder: (context, value, child) {
                                          return Transform.translate(
                                            offset: Offset(0, value),
                                            child: Opacity(
                                              opacity:
                                                  1 - (value / 10).clamp(0, 1),
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
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: AppColors.green,
                                                    size: 16.sp,
                                                  ),
                                                  8.width,
                                                  Flexible(
                                                    child: Text(
                                                      _selectedPictureFileName!,
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        color: AppColors
                                                            .lightMainText,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                  32.height,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${'uploadYourCv'.tr()} (optional)',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTText,
                      ),
                    ),
                  ),
                  16.height,
                  Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 360.w),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        padding: EdgeInsets.all(hasCv ? 3.w : 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: hasCv
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
                        child: DashedBorderContainer(
                          borderColor: hasCv
                              ? AppColors.secondaryColor
                              : AppColors.borderColor,
                          borderWidth: 1.5,
                          borderRadius: 10.r,
                          backgroundColor: AppColors.lightBGColor,
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
                                      text: 'chooseFile'.tr(),
                                      style: TextStyle(
                                        color: AppColors.secondaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(text: 'toUploadYourCv'.tr()),
                                  ],
                                ),
                              ),
                              8.height,
                              Text(
                                'supportedFormatsPdf'.tr(),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.greyText,
                                ),
                              ),
                              16.height,
                              GestureDetector(
                                onTapDown: (_) {
                                  setState(() {
                                    _isCvPressed = true;
                                  });
                                },
                                onTapUp: (_) {
                                  setState(() {
                                    _isCvPressed = false;
                                  });
                                  _pickCv();
                                },
                                onTapCancel: () {
                                  setState(() {
                                    _isCvPressed = false;
                                  });
                                },
                                child: AnimatedScale(
                                  scale: _isCvPressed ? 0.9 : 1.0,
                                  duration: const Duration(milliseconds: 120),
                                  curve: Curves.easeOut,
                                  child: Container(
                                    width: 56.w,
                                    height: 56.h,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: hasCv
                                          ? LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppColors.secondaryColor
                                                    .withOpacity(0.18),
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
                                        width: 44.w,
                                        height: 44.h,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: Icon(
                                          Icons.upload_outlined,
                                          color: hasCv
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
                                duration: const Duration(milliseconds: 220),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                child: _selectedCvFileName == null
                                    ? const SizedBox.shrink()
                                    : TweenAnimationBuilder<double>(
                                        key: const ValueKey('cv_file_name'),
                                        tween: Tween(begin: 10, end: 0),
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        curve: Curves.easeOut,
                                        builder: (context, value, child) {
                                          return Transform.translate(
                                            offset: Offset(0, value),
                                            child: Opacity(
                                              opacity:
                                                  1 - (value / 10).clamp(0, 1),
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
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: AppColors.green,
                                                    size: 16.sp,
                                                  ),
                                                  8.width,
                                                  Flexible(
                                                    child: Text(
                                                      _selectedCvFileName!,
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        color: AppColors
                                                            .lightMainText,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                  32.height,
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 12, end: 0),
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, value),
                        child: Opacity(
                          opacity: 1 - (value / 12).clamp(0, 1),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'skills'.tr(),
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
                          hint: 'describeYourSkills'.tr(),
                          controller: _personalInfoController,
                          maxLines: 5,
                          minLines: 3,
                          onChanged: cubit.updatePersonalInfo,
                        ),
                      ],
                    ),
                  ),
                  24.height,
                  Text(
                    '${'shareYourSocialMedia'.tr()} (optional)',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightTText,
                    ),
                  ),
                  16.height,
                  CustomTextField(
                    label: '${'facebook'.tr()} (optional)',
                    hint: 'facebookLink'.tr(),
                    controller: _facebookController,
                    keyboardType: TextInputType.url,
                    onChanged: cubit.updateFacebookLink,
                  ),
                  16.height,
                  CustomTextField(
                    label: '${'instagram'.tr()} (optional)',
                    hint: 'instagramLink'.tr(),
                    controller: _instagramController,
                    keyboardType: TextInputType.url,
                    onChanged: cubit.updateInstagramLink,
                  ),
                  16.height,
                  CustomTextField(
                    label: '${'linkedin'.tr()} (optional)',
                    hint: 'linkedinLink'.tr(),
                    controller: _linkedinController,
                    keyboardType: TextInputType.url,
                    onChanged: cubit.updateLinkedinLink,
                  ),
                  16.height,
                  CustomTextField(
                    label: '${'youtube'.tr()} (optional)',
                    hint: 'youtubeLink'.tr(),
                    controller: _youtubeController,
                    keyboardType: TextInputType.url,
                    onChanged: cubit.updateYoutubeLink,
                  ),
                  16.height,
                  CustomTextField(
                    label: '${'secondaryEmail'.tr()} (optional)',
                    hint: 'emailLink'.tr(),
                    controller: _emailAddressController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (val) => cubit.updateEmailAddress(val),
                  ),
                  32.height,
                  Text(
                    '${'portfolioLinks'.tr()} (optional)',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightTText,
                    ),
                  ),
                  16.height,
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          hint: 'addPortfolioLink'.tr(),
                          controller: _portfolioController,
                        ),
                      ),
                      12.width,
                      GestureDetector(
                        onTap: () {
                          if (_portfolioController.text.isNotEmpty) {
                            cubit.addPortfolioLink(_portfolioController.text);
                            _portfolioController.clear();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (state.data.portfolioLinks.isNotEmpty) ...[
                    16.height,
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: state.data.portfolioLinks.asMap().entries.map((
                        entry,
                      ) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightBGColor,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                entry.value.length > 25
                                    ? '${entry.value.substring(0, 22)}...'
                                    : entry.value,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.lightMainText,
                                ),
                              ),
                              8.width,
                              GestureDetector(
                                onTap: () =>
                                    cubit.removePortfolioLink(entry.key),
                                child: Icon(
                                  Icons.close,
                                  size: 16.sp,
                                  color: AppColors.greyText,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  40.height,
                ],
              ),
            ),
          ),
        );
      },
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
                    context.read<StudentOnboardingCubit>().clearSearchResults();
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
    return BlocBuilder<StudentOnboardingCubit, StudentOnboardingState>(
      builder: (context, state) {
        if (state is! StudentOnboardingInProgress) {
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
                  final cubit = context.read<StudentOnboardingCubit>();
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
    return BlocBuilder<StudentOnboardingCubit, StudentOnboardingState>(
      builder: (context, state) {
        if (state is! StudentOnboardingInProgress) {
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
                context.read<StudentOnboardingCubit>().removeSelectedWorkItem(
                  item.id,
                  item.type,
                );
              },
              onRoleChanged: (role) {
                context.read<StudentOnboardingCubit>().updateWorkItemRole(
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
