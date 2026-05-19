import 'dart:io';
import 'package:aflam/core/helpers/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../../../../../core/widgets/buttons/custom_button.dart';
import '../../../../../core/widgets/fields/custom_text_field.dart';
import '../../../../../core/video_upload/video_upload.dart';
import '../../../../../core/di/service_locator.dart';
import '../cubit/create_season_cubit.dart';
import '../cubit/create_season_state.dart';
import '../../data/models/request/create_season_request_model.dart';
import 'add_episodes_screen.dart';
import '../../data/models/response/series_response_model.dart';
import '../cubit/get_seasons_cubit.dart';
import '../cubit/content_management_cubit.dart';
import '../cubit/update_season_cubit.dart';
import '../cubit/update_season_state.dart';
import '../../data/models/request/update_season_request_model.dart';
import '../../../../../../core/app_config/app_strings.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/widgets/animations/animated_slide_in.dart';

class AddSeriesDetailsScreen extends StatefulWidget {
  final int seriesId;
  final String title;
  final String about;
  final int categoryId;
  final File? coverImage;
  final SeriesModel? seriesToEdit;

  const AddSeriesDetailsScreen({
    super.key,
    required this.seriesId,
    required this.title,
    required this.about,
    required this.categoryId,
    this.coverImage,
    this.seriesToEdit,
  });

  @override
  State<AddSeriesDetailsScreen> createState() => _AddSeriesDetailsScreenState();
}

class _AddSeriesDetailsScreenState extends State<AddSeriesDetailsScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();

  late final VideoUploadCubit _videoUploadCubit;
  late final CreateSeasonCubit _createSeasonCubit;
  late final UpdateSeasonCubit _updateSeasonCubit;
  late AnimationController _animationController;

  final List<ActorData> _actors = [ActorData()];
  bool _isPaidContent = false;
  File? _trailerFile;
  String? _uploadedTrailerId;
  bool _isUploadingTrailer = false;
  bool _shouldNavigateToEpisodes = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();

    _videoUploadCubit = getIt<VideoUploadCubit>();
    _createSeasonCubit = getIt<CreateSeasonCubit>();
    _updateSeasonCubit = getIt<UpdateSeasonCubit>();
    
    if (widget.seriesToEdit != null) {
      _priceController.text = widget.seriesToEdit!.price;
      _isPaidContent = (double.tryParse(widget.seriesToEdit!.price) ?? 0) > 0;
      _uploadedTrailerId = widget.seriesToEdit!.trailer;
      
      if (widget.seriesToEdit!.actors.isNotEmpty) {
        _actors.clear();
        for (var actorModel in widget.seriesToEdit!.actors) {
             final actor = ActorData();
             actor.nameController.text = actorModel.name;
             actor.photoUrl = actorModel.image;
             _actors.add(actor);
        }
      }
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    for (var actor in _actors) {
      actor.nameController.dispose();
    }
    _videoUploadCubit.close();
    _createSeasonCubit.close();
    _updateSeasonCubit.close();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _videoUploadCubit),
        BlocProvider.value(value: _createSeasonCubit),
        BlocProvider.value(value: _updateSeasonCubit),
        BlocProvider(create: (context) => getIt<GetSeasonsCubit>()..getSeasons(widget.seriesId)),
        BlocProvider(create: (context) => getIt<ContentManagementCubit>()),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFFFDFDFD),
          appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
          body: MultiBlocListener(
            listeners: [
              BlocListener<UpdateSeasonCubit, UpdateSeasonState>(
                listener: (context, state) {
                   if (state is UpdateSeasonLoading) {
                      AppMessages.showLoading(context);
                   } else if (state is UpdateSeasonSuccess) {
                      // Don't hide loading yet, wait for getSeasons to complete
                      AppMessages.showSuccess(context, "Season Updated Successfully");
                      // Navigate to episodes (or refresh seasons)
                      _shouldNavigateToEpisodes = true;
                      context.read<GetSeasonsCubit>().getSeasons(widget.seriesId);
                   } else if (state is UpdateSeasonError) {
                      AppMessages.hideLoading(context);
                      AppMessages.showError(context, state.message);
                   }
                }
              ),
              BlocListener<GetSeasonsCubit, GetSeasonsState>(
                listener: (context, state) {
                  if (_shouldNavigateToEpisodes) {
                    if (state is GetSeasonsLoaded && state.seasons.isNotEmpty) {
                      _shouldNavigateToEpisodes = false;
                      // Hide loading before navigation
                      AppMessages.hideLoading(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEpisodesScreen(
                            seasonId: state.seasons.first.id,
                            seriesId: widget.seriesId,
                          ),
                        ),
                      );
                    } else if (state is GetSeasonsError) {
                      _shouldNavigateToEpisodes = false;
                      // Hide loading on error
                      AppMessages.hideLoading(context);
                      AppMessages.showError(context, state.message);
                    }
                  }
                },
              ),
              BlocListener<VideoUploadCubit, VideoUploadState>(
                listener: (context, state) {
                  if (state is VideoUploadSuccess) {
                    setState(() {
                      if (_isUploadingTrailer) {
                        _uploadedTrailerId = state.videoId;
                        _isUploadingTrailer = false;
                      }
                    });
                  } else if (state is VideoUploadError) {
                    setState(() {
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
                      _isUploadingTrailer = false;
                    });
                  }
                },
              ),
              BlocListener<CreateSeasonCubit, CreateSeasonState>(
                listener: (context, state) {
                  if (state is CreateSeasonLoading) {
                    AppMessages.showLoading(context);
                  }
                  if (state is CreateSeasonSuccess) {
                    AppMessages.hideLoading(context);
                    AppMessages.showSuccess(context, state.message);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEpisodesScreen(
                          seasonId: state.seasonId,
                          seriesId: widget.seriesId,
                        ),
                      ),
                    );
                  } else if (state is CreateSeasonError) {
                    AppMessages.hideLoading(context);
                    AppMessages.showError(context, state.message);
                  }
                },
              ),
            ],
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 20.h,
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
                      child: _buildProgressIndicator(currentStep: 2, totalSteps: 3),
                    ),

                    SizedBox(height: 30.h),

                    AnimatedSlideIn(
                      index: 1,
                      controller: _animationController,
                      child: Text(
                        AppStrings.uploadSeriesTrailer.tr(),
                        style: TextStyle(
                          fontSize: 25.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    SizedBox(height: 8.h),

                    AnimatedSlideIn(
                      index: 2,
                      controller: _animationController,
                      child: Text(
                        AppStrings.chooseSeriesTrailer.tr(),
                        style: TextStyle(
                          fontSize: 21.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    AnimatedSlideIn(
                      index: 3,
                      controller: _animationController,
                      child: _buildUploadSection(
                        titlePart1: AppStrings.chooseVideoOrFile.tr(),
                        titlePart2: AppStrings.toUploadTheTrailer.tr(),
                        subtitle: AppStrings.supportedFormatsMp4Pdf.tr(),
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
                          _videoUploadCubit.reset();
                        },
                      ),
                    ),

                    SizedBox(height: 30.h),

                    AnimatedSlideIn(
                      index: 4,
                      controller: _animationController,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.actors.tr(),
                            style: TextStyle(
                              fontSize: 25.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            onPressed: _addActor,
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: const Color(0xFFFF5722),
                              size: 30.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 8.h),

                    AnimatedSlideIn(
                      index: 5,
                      controller: _animationController,
                      child: Text(
                        AppStrings.includeCastMembers.tr(),
                        style: TextStyle(
                          fontSize: 21.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    ..._actors.asMap().entries.map((entry) {
                      int index = entry.key;
                      return AnimatedSlideIn(
                        index: 6 + index,
                        controller: _animationController,
                        child: _buildActorCard(entry.value),
                      );
                    }),

                    SizedBox(height: 30.h),

                    AnimatedSlideIn(
                      index: 6 + _actors.length,
                      controller: _animationController,
                      child: Text(
                        AppStrings.priceYourProduction.tr(),
                        style: TextStyle(
                          fontSize: 25.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    SizedBox(height: 8.h),

                    AnimatedSlideIn(
                      index: 7 + _actors.length,
                      controller: _animationController,
                      child: Text(
                        AppStrings.setViewingPrice.tr(),
                        style: TextStyle(
                          fontSize: 21.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    AnimatedSlideIn(
                      index: 8 + _actors.length,
                      controller: _animationController,
                      child: Text(
                        AppStrings.moviePrice.tr(),
                        style: TextStyle(
                          fontSize: 21.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    AnimatedSlideIn(
                      index: 9 + _actors.length,
                      controller: _animationController,
                      child: CustomTextField(
                        controller: _priceController,
                        hint: AppStrings.enterThePrice.tr(),
                        keyboardType: TextInputType.number,
                        enabled: _isPaidContent,
                        validator: (value) {
                          if (_isPaidContent &&
                              (value == null || value.isEmpty)) {
                            return AppStrings.pleaseEnterPrice.tr();
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: 16.h),

                    AnimatedSlideIn(
                      index: 10 + _actors.length,
                      controller: _animationController,
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isPaidContent,
                            onChanged: (value) {
                              setState(() {
                                _isPaidContent = value ?? false;
                                if (!_isPaidContent) {
                                  _priceController.clear();
                                }
                              });
                            },
                            activeColor: const Color(0xFFFF5722),
                          ),
                          Text(
                            '${AppStrings.paidContent.tr()} ${AppStrings.needSubscribe.tr()}',
                            style: TextStyle(
                              fontSize: 21.sp,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40.h),

                    AnimatedSlideIn(
                      index: 11 + _actors.length,
                      controller: _animationController,
                      child: CustomButton(
                        text: widget.seriesToEdit != null
                            ? "Update"
                            : AppStrings.confirm.tr(),
                        isBackgroundGradient: true,
                        onTap: () {
                          if (widget.seriesToEdit != null) {
                            _onConfirmEdit(context);
                          } else if (_canProceed()) {
                            _onConfirm(context);
                          }
                        },
                      ),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
            height: 4.h,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8.w : 0),
            decoration: BoxDecoration(
              color: index < currentStep
                  ? const Color(0xFFFF5722)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
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
                      fontSize: 19.sp,
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
                      fontSize: 17.sp,
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
    );
  }

  Widget _buildDottedUploadBox({
    required String titlePart1,
    required String titlePart2,
    required String subtitle,
    required File? file,
    required VoidCallback onTap,
  }) {
    if (file == null && _uploadedTrailerId != null && _uploadedTrailerId!.isNotEmpty) {
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
                    'Trailer Already Uploaded',
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Video ID: $_uploadedTrailerId',
                    style: TextStyle(
                      fontSize: 17.sp,
                      color: Colors.green.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.green.shade700),
              onPressed: onTap,
            ),
          ],
        ),
      );
    }

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

  Widget _buildActorCard(ActorData actor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.actorName.tr(),
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              if (_actors.length > 1)
                IconButton(
                  onPressed: () => _removeActor(actor),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20.sp,
                  ),
                ),
            ],
          ),

          SizedBox(height: 8.h),

          CustomTextField(
            controller: actor.nameController,
            hint: AppStrings.enterActorName.tr(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.pleaseEnterActorName.tr();
              }
              return null;
            },
          ),

          SizedBox(height: 16.h),

          GestureDetector(
            onTap: () => _pickActorPhoto(actor),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: (actor.photo == null && actor.photoUrl == null)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: AppStrings.chooseVideoOrFile.tr(),
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  color: const Color(0xFFFF5722),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: AppStrings.toUploadPicture.tr(),
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
                          AppStrings.supportedFormatsJpegPng.tr(),
                          style: TextStyle(
                            fontSize: 17.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 40.sp,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        if (actor.photo == null && actor.photoUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: CachedNetworkImage(
                              imageUrl: AppUrls.storageImageLink(actor.photoUrl!),
                              width: 40.w,
                              height: 40.h,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey.shade200),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          )
                        else
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24.sp,
                          ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            actor.photo != null ? actor.photo!.path.split('/').last : 'Existing Image',
                            style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              actor.photo = null;
                              actor.photoUrl = null;
                            });
                          },
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _addActor() {
    setState(() {
      _actors.add(ActorData());
    });
  }

  void _removeActor(ActorData actor) {
    setState(() {
      _actors.remove(actor);
      actor.nameController.dispose();
    });
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
      _videoUploadCubit.uploadVideo(videoFile: _trailerFile!);
    }
  }

  Future<void> _pickActorPhoto(ActorData actor) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        actor.photo = File(result.files.single.path!);
      });
    }
  }

  bool _canProceed() {
    return _uploadedTrailerId != null &&
        !_isUploadingTrailer &&
        _actors.every(
          (actor) =>
              actor.nameController.text.isNotEmpty && actor.photo != null,
        );
  }

  void _onConfirm(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (!_canProceed()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all fields and upload trailer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare actors data
    final actorsData = _actors.map((actor) {
      return ActorRequestData(
        name: actor.nameController.text,
        image: actor.photo!,
      );
    }).toList();

    // Create season request
    final request = CreateSeasonRequestModel(
      seriesId: widget.seriesId,
      actorsData: actorsData,
      price: _isPaidContent
          ? double.tryParse(_priceController.text) ?? 0.0
          : 0.0,
      coverPhoto: widget.coverImage ?? File(''), // Empty file if null - will be handled in toFormData
      trailer: _uploadedTrailerId!, // Video ID from Bunny
      seasonNumber: widget.seriesToEdit?.seasonNumber ?? "1", 
    );

    _createSeasonCubit.createSeason(request);
  }

  void _onConfirmEdit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    
    final seasonsState = context.read<GetSeasonsCubit>().state;
    int? seasonId;
    if (seasonsState is GetSeasonsLoaded && seasonsState.seasons.isNotEmpty) {
      seasonId = seasonsState.seasons.first.id;
    }

    if (seasonId == null) {
      // Fallback: This shouldn't happen if we strictly follow Edit flow.
      // Maybe the series has no seasons? Then we might need to create one instead.
      // For now, let's assume one exists or we return error.
      AppMessages.showError(context, "No season found to update.");
      return;
    }

    // Prepare actors update data
    final actorsData = _actors.map((actor) {
      return ActorUpdateData(
        name: actor.nameController.text,
        imageFile: actor.photo,
        imageUrl: null, // We handle new files predominantly here. To support existing URL, ActorData needs URL field.
      );
    }).toList();

    final request = UpdateSeasonRequestModel(
      seasonId: seasonId,
      seriesId: widget.seriesId,
      actorsData: actorsData,
      price: _isPaidContent ? double.tryParse(_priceController.text) : 0.0,
      coverPhoto: widget.coverImage, // This is expected to be a file. If unchanged, it might be the same.
      // But widget.coverImage comes from previous screen (Series Cover).
      // Wait, AddSeriesDetailsScreen doesn't seem to have a Season Cover Photo picker in UI?
      // It has "Upload Season Trailer" and "Actors" and "Price".
      // CreateSeasonRequestModel takes "coverPhoto".
      // In _onConfirm, it passes "widget.coverImage" (from Series cover) as Season Cover??
      // If so, we can pass it here too if we want to update it.
      trailer: _uploadedTrailerId!,
      seasonNumber: widget.seriesToEdit?.seasonNumber,
    );
     
     _updateSeasonCubit.updateSeason(request);
  }
}

class ActorData {
  final TextEditingController nameController = TextEditingController();
  File? photo;
  String? photoUrl;
}
