import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../../../../../core/video_upload/video_upload.dart';
import '../../../../../core/widgets/animations/animated_slide_in.dart';

import 'package:easy_localization/easy_localization.dart';
import '../../../../../../core/app_config/app_strings.dart';
import '../../../../../../core/di/service_locator.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';
import '../../../../../../config/routes/routes.dart';

import '../../data/models/response/create_advertise_response_model.dart';
import 'package:shimmer/shimmer.dart';

class UploadAdvertiseScreen extends StatefulWidget {
  final CreateAdvertiseResponseModel? advertiseToUpdate;
  const UploadAdvertiseScreen({super.key, this.advertiseToUpdate});

  @override
  State<UploadAdvertiseScreen> createState() => _UploadAdvertiseScreenState();
}

class _UploadAdvertiseScreenState extends State<UploadAdvertiseScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _advertiseNameController = TextEditingController();

  File? _advertiseFile;
  File? _trailerFile;
  int? _selectedCategoryId;

  String? _uploadedVideoId;
  String? _uploadedTrailerId;
  bool _isUploadingAdvertise = false;
  bool _isUploadingTrailer = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();

    if (widget.advertiseToUpdate != null) {
      _advertiseNameController.text = widget.advertiseToUpdate!.name;
      _selectedCategoryId = widget.advertiseToUpdate!.category.id;
      // Load existing video and trailer IDs if available
      // Note: CreateAdvertiseResponseModel may need 'video' field added
      // For now, we'll check if it exists in the JSON response
      _uploadedTrailerId = widget.advertiseToUpdate!.trailer.isNotEmpty
          ? widget.advertiseToUpdate!.trailer
          : null;
    }
  }

  @override
  void dispose() {
    _advertiseNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CategoriesCubit>()..fetchCategories(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
        body: BlocListener<VideoUploadCubit, VideoUploadState>(
          listener: (context, state) {
            if (state is VideoUploadSuccess) {
              setState(() {
                if (_isUploadingAdvertise) {
                  _uploadedVideoId = state.videoId;
                  _isUploadingAdvertise = false;
                } else if (_isUploadingTrailer) {
                  _uploadedTrailerId = state.videoId;
                  _isUploadingTrailer = false;
                }
              });
            } else if (state is VideoUploadError) {
              setState(() {
                _isUploadingAdvertise = false;
                _isUploadingTrailer = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is VideoUploadInitial) {
              setState(() {
                _isUploadingAdvertise = false;
                _isUploadingTrailer = false;
              });
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 10.h,
              bottom: 100.h,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSlideIn(
                    index: 0,
                    controller: _animationController,
                    child: _buildProgressIndicator(
                      currentStep: 2,
                      totalSteps: 3,
                    ),
                  ),

                  SizedBox(height: 30.h),

                  AnimatedSlideIn(
                    index: 1,
                    controller: _animationController,
                    child: _buildFloatingLabelInput(
                      controller: _advertiseNameController,
                      label: AppStrings.advertiseName.tr(),
                      hint: AppStrings.enterAdvertiseName.tr(),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  AnimatedSlideIn(
                    index: 2,
                    controller: _animationController,
                    child: Text(
                      AppStrings.uploadYourAdvertise.tr(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  AnimatedSlideIn(
                    index: 3,
                    controller: _animationController,
                    child: Text(
                      AppStrings.chooseAdvertiseProject.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  AnimatedSlideIn(
                    index: 4,
                    controller: _animationController,
                    child: _buildUploadSection(
                      titlePart1: AppStrings.chooseVideoOrFile.tr(),
                      titlePart2: AppStrings.toUploadYourAdvertise.tr(),
                      subtitle: AppStrings.supportedFormatsMp4Pdf.tr(),
                      file: _advertiseFile,
                      isUploading: _isUploadingAdvertise,
                      uploadedId: _uploadedVideoId,
                      onTap: _pickAdvertiseFile,
                      onRemove: () {
                        setState(() {
                          _advertiseFile = null;
                          _uploadedVideoId = null;
                          _isUploadingAdvertise = false;
                        });
                        context.read<VideoUploadCubit>().reset();
                      },
                    ),
                  ),

                  SizedBox(height: 30.h),

                  AnimatedSlideIn(
                    index: 5,
                    controller: _animationController,
                    child: Text(
                      AppStrings.uploadAdvertiseTrailer.tr(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  AnimatedSlideIn(
                    index: 6,
                    controller: _animationController,
                    child: Text(
                      AppStrings.chooseAdvertiseTrailer.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  AnimatedSlideIn(
                    index: 7,
                    controller: _animationController,
                    child: _buildUploadSection(
                      titlePart1: AppStrings.chooseVideoOrFile.tr(),
                      titlePart2: AppStrings.toUploadTheTrailer.tr(),
                      subtitle: AppStrings.supportedFormatsJpegPdf.tr(),
                      file: _trailerFile,
                      isUploading: _isUploadingTrailer,
                      uploadedId: _uploadedTrailerId,
                      onTap: _pickTrailerFile,
                      onRemove: () {
                        setState(() {
                          _trailerFile = null;
                          _uploadedTrailerId = null;
                          _isUploadingTrailer = false;
                        });
                        context.read<VideoUploadCubit>().reset();
                      },
                    ),
                  ),

                  SizedBox(height: 30.h),

                  AnimatedSlideIn(
                    index: 8,
                    controller: _animationController,
                    child: BlocBuilder<CategoriesCubit, CategoriesState>(
                      builder: (context, state) {
                        List<DropdownMenuItem<int>> items = [];

                        if (state is CategoriesLoading) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              height: 60.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                          );
                        } else if (state is CategoriesLoaded) {
                          items = state.categories.map((category) {
                            return DropdownMenuItem<int>(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList();
                        } else if (state is CategoriesError) {
                          items = [
                            DropdownMenuItem(
                              value: null,
                              child: Text(
                                AppStrings.errorLoadingCategories.tr(),
                              ),
                            ),
                          ];
                        }

                        return _buildFloatingLabelDropdown(
                          label: AppStrings.advertiseCategory.tr(),
                          hint: AppStrings.selectAdvertiseCategory.tr(),
                          value: _selectedCategoryId,
                          items: items,
                          onChanged: (int? value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 40.h),

                  AnimatedSlideIn(
                    index: 9,
                    controller: _animationController,
                    child: Container(
                      width: double.infinity,
                      height: 56.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.secondaryColor,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: ElevatedButton(
                        onPressed: _canProceed() ? _onNext : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          AppStrings.next.tr(),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection({
    required String titlePart1,
    required String titlePart2,
    required String subtitle,
    required File? file,
    required bool isUploading,
    required String? uploadedId,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    if (isUploading) {
      return const VideoUploadProgressWidget();
    }

    // Check if video is uploaded (either from new upload or existing from edit)
    if (uploadedId != null && uploadedId.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Icon(Icons.check, color: Colors.green, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.uploadedSuccessfully.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    file != null
                        ? file.path.split('/').last
                        : (uploadedId.isNotEmpty
                              ? 'Video Already Uploaded (ID: ${uploadedId.length > 20 ? '${uploadedId.substring(0, 20)}...' : uploadedId})'
                              : 'Existing File'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.green.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.green.shade700),
              onPressed: onRemove,
            ),
          ],
        ),
      );
    }

    return _buildDottedUploadBox(
      titlePart1: titlePart1,
      titlePart2: titlePart2,
      subtitle: subtitle,
      file: file,
      onTap: onTap,
      isUploading: false,
    );
  }

  Widget _buildProgressIndicator({
    required int currentStep,
    required int totalSteps,
  }) {
    return Row(
      children: List.generate(
        totalSteps,
        (index) => Expanded(
          child: Container(
            height: 6.h,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8.w : 0),
            decoration: BoxDecoration(
              color: index < currentStep
                  ? const Color(0xFFFF5722)
                  : const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingLabelInput({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 8.h),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16.sp,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 18.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: const BorderSide(color: Color(0xFFFF5722)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '${AppStrings.fieldIsRequired.tr()} $label'; // Using generic required string
              }
              return null;
            },
          ),
        ),
        Positioned(
          left: 24.w,
          top: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            color: const Color(0xFFFDFDFD), // Match background
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingLabelDropdown({
    required String label,
    required String hint,
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required Function(int?)? onChanged,
  }) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 8.h),
          child: DropdownButtonFormField<int>(
            initialValue: value,
            items: items,
            onChanged: onChanged,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFF5722)),
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16.sp,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 18.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: const BorderSide(color: Color(0xFFFF5722)),
              ),
            ),
          ),
        ),
        Positioned(
          left: 24.w,
          top: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            color: const Color(0xFFFDFDFD), // Match background
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDottedUploadBox({
    required String titlePart1,
    required String titlePart2,
    required String subtitle,
    required File? file,
    required VoidCallback onTap,
    required bool isUploading,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        color: Colors.grey.shade300,
        strokeWidth: 1.5,
        dashPattern: const [6, 4],
        borderType: BorderType.RRect,
        radius: Radius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: titlePart1,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: const Color(0xFFFF5722),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: titlePart2,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.file_upload_outlined,
                  size: 26.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAdvertiseFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _advertiseFile = File(result.files.single.path!);
        _isUploadingAdvertise = true;
      });

      if (!mounted) return;
      context.read<VideoUploadCubit>().uploadVideo(videoFile: _advertiseFile!);
    }
  }

  Future<void> _pickTrailerFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _trailerFile = File(result.files.single.path!);
        _isUploadingTrailer = true;
      });

      if (!mounted) return;
      context.read<VideoUploadCubit>().uploadVideo(videoFile: _trailerFile!);
    }
  }

  bool _canProceed() {
    return _advertiseNameController.text.isNotEmpty &&
        _uploadedVideoId != null &&
        _selectedCategoryId != null &&
        !_isUploadingAdvertise &&
        !_isUploadingTrailer;
  }

  void _onNext() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_canProceed()) return;

    final result = await context.pushNamed(
      Routes.addAdvertiseDetailsScreen,
      extra: {
        'movieName':
            _advertiseNameController.text, // Keep keys consistent for map usage
        'videoId': _uploadedVideoId,
        'trailerId': _uploadedTrailerId,
        'categoryId': _selectedCategoryId,
        'advertiseToUpdate': widget.advertiseToUpdate, // Passed prop
      },
    );

    if (result == true && mounted) {
      context.pop(true);
    }
  }
}
