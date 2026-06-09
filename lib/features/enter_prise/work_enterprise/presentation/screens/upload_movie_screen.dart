import 'package:aflam/core/widgets/animated_loading/animated_loading.dart';
import 'dart:async';
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

import 'package:easy_localization/easy_localization.dart';
import '../../../../../../core/app_config/app_strings.dart';
import '../../../../../../core/di/service_locator.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';
import '../cubit/get_movies_cubit.dart';
import '../cubit/get_movies_state.dart';
import '../../../../../../config/routes/routes.dart';

import '../../data/models/response/movie_model.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/widgets/animations/animated_slide_in.dart';

class UploadMovieScreen extends StatefulWidget {
  final MovieModel? movieToUpdate;
  const UploadMovieScreen({super.key, this.movieToUpdate});

  @override
  State<UploadMovieScreen> createState() => _UploadMovieScreenState();
}

class _UploadMovieScreenState extends State<UploadMovieScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _movieNameController = TextEditingController();

  late AnimationController _animationController;

  File? _movieFile;
  File? _trailerFile;
  int? _selectedCategoryId;

  String? _uploadedVideoId;
  String? _uploadedTrailerId;
  bool _isUploadingMovie = false;
  bool _isUploadingTrailer = false;
  bool _isVideoReady = true;
  Timer? _statusCheckTimer;
  bool _isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();

    if (widget.movieToUpdate != null) {
      _movieNameController.text = widget.movieToUpdate!.name;
      _selectedCategoryId = widget.movieToUpdate!.category?.id;
      _uploadedVideoId = widget.movieToUpdate!.video;
      _uploadedTrailerId = widget.movieToUpdate!.trailer;
      _isVideoReady = widget.movieToUpdate!.isReady;

      // Start status check if video is not ready
      if (!_isVideoReady &&
          _uploadedVideoId != null &&
          _uploadedVideoId!.isNotEmpty) {
        _startStatusCheck();
      }
    }
  }

  void _startStatusCheck() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) async {
      if (!mounted || _isVideoReady) {
        timer.cancel();
        return;
      }

      if (_isCheckingStatus || widget.movieToUpdate == null) return;
      _isCheckingStatus = true;

      try {
        final moviesCubit = getIt<GetMoviesCubit>();
        await moviesCubit.getMovies(refresh: true);

        if (mounted && moviesCubit.state is GetMoviesLoaded) {
          final movies = (moviesCubit.state as GetMoviesLoaded).movies;
          final movieId = widget.movieToUpdate!.id;
          final currentMovie = movies.where((m) => m.id == movieId).firstOrNull;

          if (currentMovie != null && currentMovie.isReady != _isVideoReady) {
            if (mounted) {
              setState(() {
                _isVideoReady = currentMovie.isReady;
              });

              if (_isVideoReady) {
                timer.cancel();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Video is now ready!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            }
          }
        }
      } catch (e) {
        // Silently handle errors
      } finally {
        _isCheckingStatus = false;
      }
    });
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    _movieNameController.dispose();
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
                if (_isUploadingMovie) {
                  _uploadedVideoId = state.videoId;
                  _isUploadingMovie = false;
                } else if (_isUploadingTrailer) {
                  _uploadedTrailerId = state.videoId;
                  _isUploadingTrailer = false;
                }
              });
            } else if (state is VideoUploadError) {
              setState(() {
                _isUploadingMovie = false;
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
                _isUploadingMovie = false;
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
                      controller: _movieNameController,
                      label: AppStrings.movieName.tr(),
                      hint: AppStrings.enterYourMovieName.tr(),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  AnimatedSlideIn(
                    index: 2,
                    controller: _animationController,
                    child: Text(
                      AppStrings.uploadYourMovie.tr(),
                      style: TextStyle(
                        fontSize: 25.sp,
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
                      AppStrings.chooseMovieProject.tr(),
                      style: TextStyle(
                        fontSize: 21.sp,
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
                      titlePart2: AppStrings.toUploadYourMovie.tr(),
                      subtitle: AppStrings.supportedFormatsMp4Pdf.tr(),
                      file: _movieFile,
                      isUploading: _isUploadingMovie,
                      uploadedId: _uploadedVideoId,
                      isVideo: true,
                      onTap: _pickMovieFile,
                      onRemove: () {
                        setState(() {
                          _movieFile = null;
                          _uploadedVideoId = null;
                          _isUploadingMovie = false;
                          _isVideoReady = true;
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
                      AppStrings.uploadMovieTrailer.tr(),
                      style: TextStyle(
                        fontSize: 25.sp,
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
                      AppStrings.chooseMovieTrailer.tr(),
                      style: TextStyle(
                        fontSize: 21.sp,
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
                      isVideo: false,
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
                        if (state is CategoriesLoading) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              height: 60.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                          );
                        }

                        List<DropdownMenuItem<int>> items = [];
                        if (state is CategoriesLoaded) {
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
                          label: AppStrings.movieCategory.tr(),
                          hint: AppStrings.selectYourMovieCategory.tr(),
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
    required bool isVideo,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    if (isUploading) {
      return const VideoUploadProgressWidget();
    }

    if (uploadedId != null && uploadedId.isNotEmpty) {
      // Check if this is the video (not trailer) and if it's ready
      final isReady = isVideo
          ? _isVideoReady
          : true; // Trailers are always ready

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isReady ? Colors.green.shade50 : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isReady ? Colors.green.shade200 : Colors.orange.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isReady
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                ),
              ),
              child: isReady
                  ? Icon(Icons.check, color: Colors.green, size: 20.sp)
                  : SizedBox(
                      width: 20.sp,
                      height: 20.sp,
                      child: AnimatedLoading(
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isReady
                        ? AppStrings.uploadedSuccessfully.tr()
                        : 'Processing...',
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w600,
                      color: isReady
                          ? Colors.green.shade800
                          : Colors.orange.shade800,
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
                      fontSize: 17.sp,
                      color: isReady
                          ? Colors.green.shade600
                          : Colors.orange.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isReady && isVideo) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'Video is not ready yet. Please wait for upload to complete.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.orange.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: isReady ? Colors.green.shade700 : Colors.orange.shade700,
              ),
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
                fontSize: 19.sp,
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
                return 'Please enter $label';
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
                fontSize: 17.sp,
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
                fontSize: 19.sp,
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
                fontSize: 17.sp,
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
                        fontSize: 19.sp,
                        color: const Color(0xFFFF5722),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: titlePart2,
                      style: TextStyle(
                        fontSize: 19.sp,
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
                style: TextStyle(fontSize: 17.sp, color: Colors.grey.shade400),
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
                  size: 24.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickMovieFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _movieFile = File(result.files.single.path!);
        _isUploadingMovie = true;
      });

      if (!mounted) return;
      context.read<VideoUploadCubit>().uploadVideo(videoFile: _movieFile!);
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
    return _movieNameController.text.isNotEmpty &&
        _uploadedVideoId != null &&
        _selectedCategoryId != null &&
        !_isUploadingMovie &&
        !_isUploadingTrailer;
  }

  void _onNext() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_canProceed()) return;

    final result = await context.pushNamed(
      Routes.addActorsPriceScreen,
      extra: {
        'movieName': _movieNameController.text,
        'videoId': _uploadedVideoId,
        'trailerId': _uploadedTrailerId,
        'categoryId': _selectedCategoryId,
        'movieToUpdate': widget.movieToUpdate,
      },
    );

    if (result == true && mounted) {
      context.pop(true);
    }
  }
}
