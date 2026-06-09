import 'package:aflam/core/widgets/animated_loading/animated_loading.dart';
import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:get_it/get_it.dart';

// Core
import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/helpers/messages.dart';

// Repositories
import '../../../../../core/widgets/buttons/custom_button.dart';
import '../../data/repository/create_season_repository.dart';
import '../../data/repository/create_episode_repository.dart';
// Models
import '../../data/models/request/create_season_request_model.dart';
import '../../data/models/request/create_episode_request_model.dart';
// Cubits
import '../../../../../core/video_upload/presentation/cubit/video_upload_cubit.dart';
// Widgets
import '../../data/repository/update_episode_repository.dart';
import '../../data/models/request/update_episode_request_model.dart';
import '../cubit/get_episodes_cubit.dart';
import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';

import '../../../../../core/widgets/animations/animated_slide_in.dart';

class AddEpisodesScreen extends StatefulWidget {
  final int seasonId;
  final int seriesId;

  const AddEpisodesScreen({
    super.key,
    required this.seasonId,
    required this.seriesId,
  });

  @override
  State<AddEpisodesScreen> createState() => _AddEpisodesScreenState();
}

class _AddEpisodesScreenState extends State<AddEpisodesScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final List<SeasonData> _seasons = [];
  bool _isLoading = false;
  late AnimationController _animationController;
  Timer? _statusCheckTimer;
  bool _isCheckingStatus = false;

  late GetEpisodesCubit _getEpisodesCubit;

  @override
  void initState() {
    super.initState();
    _seasons.add(SeasonData(seasonNumber: 1, existingId: widget.seasonId));

    _getEpisodesCubit = GetIt.I<GetEpisodesCubit>();
    _getEpisodesCubit.getEpisodes(widget.seasonId);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();

    // Start status check for episodes that are not ready
    _startStatusCheck();
  }

  void _startStatusCheck() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Check if any episode is not ready
      bool hasNotReadyEpisodes = false;
      for (var season in _seasons) {
        for (var episode in season.episodes) {
          if (episode.existingId != null && !episode.isReady) {
            hasNotReadyEpisodes = true;
            break;
          }
        }
        if (hasNotReadyEpisodes) break;
      }

      if (!hasNotReadyEpisodes) {
        timer.cancel();
        return;
      }

      if (_isCheckingStatus) return;
      _isCheckingStatus = true;

      try {
        await _getEpisodesCubit.getEpisodes(widget.seasonId);
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
    _getEpisodesCubit.close();
    _animationController.dispose();
    for (var season in _seasons) {
      season.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 80.h),
            child: BlocListener<GetEpisodesCubit, GetEpisodesState>(
              bloc: _getEpisodesCubit,
              listener: (context, state) {
                if (state is GetEpisodesLoaded) {
                  setState(() {
                    if (_seasons.isNotEmpty && state.episodes.isNotEmpty) {
                      final seasonData = _seasons[0];
                      // Update existing episodes or add new ones
                      final existingEpisodesMap = <int, EpisodeData>{};
                      final newEpisodes =
                          <EpisodeData>[]; // Preserve unsaved new episodes
                      for (var epData in seasonData.episodes) {
                        if (epData.existingId != null) {
                          existingEpisodesMap[epData.existingId!] = epData;
                        } else {
                          if (epData.titleController.text.isNotEmpty ||
                              epData.descriptionController.text.isNotEmpty ||
                              epData.uploadedVideoId != null) {
                            newEpisodes.add(epData);
                          } else if (seasonData.episodes.length == 1) {
                            // Keep the empty episode if it's the only one to avoid UI flicker
                            newEpisodes.add(epData);
                          }
                        }
                      }

                      seasonData.episodes.clear();

                      // Sort fetched episodes by episodeNumber to maintain valid index orders
                      final sortedEpisodes = List.from(state.episodes)
                        ..sort(
                          (a, b) => a.episodeNumber.compareTo(b.episodeNumber),
                        );

                      for (var ep in sortedEpisodes) {
                        final epData =
                            existingEpisodesMap[ep.id] ?? EpisodeData();
                        // Only update text controllers if they are empty or haven't been modified by user since load
                        // For simplicity and avoiding overriding user typing while timer runs, we can just set it if it's new
                        // But since it's an existing episode, updating is fine. To avoid keyboard jumping, maybe we shouldn't overwrite if not empty, or carefully.
                        // The simplest is just setting text. The user might be typing, so we only update if it's empty or from a fresh load to avoid disruption,
                        // but doing text = ep.name moves cursor to start. Let's just do it carefully.
                        if (epData.titleController.text != ep.name) {
                          epData.titleController.text = ep.name;
                        }
                        if (epData.descriptionController.text != ep.about) {
                          epData.descriptionController.text = ep.about;
                        }

                        // Store original video ID if not set
                        epData.originalVideoId ??= ep.video;

                        // Update uploadedVideoId only if it's currently null or matches original (meaning user hasn't replaced it)
                        if (epData.uploadedVideoId == null ||
                            epData.uploadedVideoId == epData.originalVideoId) {
                          epData.uploadedVideoId = ep.video;
                        }
                        epData.existingId = ep.id;

                        // Update isReady status only if video hasn't changed locally
                        if (epData.uploadedVideoId == epData.originalVideoId) {
                          final wasNotReady = !epData.isReady;
                          epData.isReady = ep.isReady;

                          // If video became ready, show notification
                          if (wasNotReady && epData.isReady && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Episode ${ep.episodeNumber} video is now ready!',
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }

                        seasonData.episodes.add(epData);
                      }

                      seasonData.episodes.addAll(newEpisodes);

                      if (seasonData.episodes.isEmpty) {
                        seasonData.episodes.add(EpisodeData());
                      }
                    }
                  });
                } else if (state is GetEpisodesError) {
                  AppMessages.showError(context, state.message);
                }
              },
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSlideIn(
                      index: 0,
                      controller: _animationController,
                      child: _buildProgressIndicator(
                        currentStep: 3,
                        totalSteps: 3,
                      ),
                    ),

                    SizedBox(height: 30.h),
                    AnimatedSlideIn(
                      index: 1,
                      controller: _animationController,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.seasons.tr(),
                            style: TextStyle(
                              fontSize: 25.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: _addSeason,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B35),
                                    Color(0xFFFF8E53),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    AppStrings.addSeasons.tr(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 19.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Seasons List
                    ..._seasons.asMap().entries.map((entry) {
                      final index = entry.key;
                      final season = entry.value;
                      return AnimatedSlideIn(
                        index: 2 + index,
                        controller: _animationController,
                        child: _buildSeasonCard(season, index),
                      );
                    }),

                    SizedBox(height: 24.h),
                    AnimatedSlideIn(
                      index: 2 + _seasons.length,
                      controller: _animationController,
                      child: CustomButton(
                        text: AppStrings.endThisSeason.tr(),
                        onTap: _onEndSeason,
                        isBackgroundGradient: true,
                      ),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: AnimatedLoading(color: Color(0xFFFF6B35)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSeasonCard(SeasonData season, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() => season.isExpanded = !season.isExpanded);
            },
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Season ${season.seasonNumber}',
                    style: TextStyle(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      if (index > 0)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _removeSeason(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      SizedBox(width: 12.w),
                      Icon(
                        season.isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: season.isExpanded
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(height: 1, color: Colors.grey[200]),
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (index > 0) ...[
                              _buildUploadBox(
                                title: 'Upload Season Photo',
                                file: season.coverPhoto,
                                onTap: () => _pickSeasonCoverPhoto(season),
                              ),
                              SizedBox(height: 16.h),
                              BlocProvider(
                                create: (_) => GetIt.I<VideoUploadCubit>(),
                                child: SeasonTrailerUploadWidget(
                                  season: season,
                                ),
                              ),
                              SizedBox(height: 24.h),
                            ],
                            ...season.episodes.asMap().entries.map((entry) {
                              final episodeIndex = entry.key;
                              final episode = entry.value;
                              return BlocProvider(
                                create: (_) => GetIt.I<VideoUploadCubit>(),
                                child: EpisodeItemWidget(
                                  episode: episode,
                                  index: episodeIndex,
                                  onRemove: () =>
                                      _removeEpisode(season, episodeIndex),
                                  onVideoUploaded: () {
                                    setState(() {
                                      // Trigger rebuild to show updated video status
                                    });
                                  },
                                ),
                              );
                            }),
                            SizedBox(height: 16.h),
                            OutlinedButton(
                              onPressed: () => _addEpisode(season),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.black),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add, color: Colors.black),
                                  SizedBox(width: 8.w),
                                  Text(
                                    AppStrings.addEpisode.tr(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 19.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox({
    required String title,
    required File? file,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: onTap,
          child: DottedBorder(
            color: const Color(0xFFFF6B35),
            strokeWidth: 1.5,
            dashPattern: const [6, 3],
            borderType: BorderType.RRect,
            radius: Radius.circular(8.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F0),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  if (file == null) ...[
                    Text(
                      'Choose file to upload the cover*',
                      style: TextStyle(
                        color: const Color(0xFFFF6B35),
                        fontSize: 17.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '(Supported formats: .jpeg, .png)',
                      style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                    ),
                    SizedBox(height: 8.h),
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: Colors.grey,
                      size: 24.sp,
                    ),
                  ] else ...[
                    Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
                    SizedBox(height: 8.h),
                    Text(
                      file.path.split('/').last,
                      style: TextStyle(fontSize: 17.sp, color: Colors.black87),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
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
                  ? const Color(0xFFFF6B35)
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickSeasonCoverPhoto(SeasonData season) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        season.coverPhoto = File(result.files.single.path!);
      });
    }
  }

  void _addSeason() {
    setState(() {
      _seasons.add(SeasonData(seasonNumber: _seasons.length + 1));
    });
  }

  void _removeSeason(int index) {
    setState(() {
      _seasons[index].dispose();
      _seasons.removeAt(index);
      for (int i = 0; i < _seasons.length; i++) {
        _seasons[i].seasonNumber = i + 1;
      }
    });
  }

  void _addEpisode(SeasonData season) {
    setState(() {
      season.episodes.add(EpisodeData());
    });
  }

  void _removeEpisode(SeasonData season, int index) {
    setState(() {
      season.episodes[index].dispose();
      season.episodes.removeAt(index);
    });
  }

  Future<void> _onEndSeason() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if any episode video is not uploaded (not checking isReady - allow processing videos)
    for (var season in _seasons) {
      for (int i = 0; i < season.episodes.length; i++) {
        final episode = season.episodes[i];
        if (episode.uploadedVideoId == null) {
          if (mounted) {
            AppMessages.showError(
              context,
              '${AppStrings.season.tr()} ${season.seasonNumber} ${AppStrings.episode.tr()} ${i + 1}: ${AppStrings.videoNotUploaded.tr()}',
            );
          }
          return;
        }
      }
    }

    setState(() => _isLoading = true);

    try {
      final createSeasonRepo = GetIt.I<CreateSeasonRepository>();
      final createEpisodeRepo = GetIt.I<CreateEpisodeRepository>();
      final updateEpisodeRepo = GetIt.I<UpdateEpisodeRepository>();

      for (var season in _seasons) {
        int? currentSeasonId = season.existingId;

        if (currentSeasonId == null) {
          if (season.coverPhoto == null || season.uploadedTrailerId == null) {
            if (mounted) {
              setState(() => _isLoading = false);
              Navigator.pop(context);
              AppMessages.showError(
                context,
                AppStrings.pleaseFillAllFields.tr(),
              );
            }
            return;
          }

          final seasonReq = CreateSeasonRequestModel(
            seriesId: widget.seriesId,
            trailer: season.uploadedTrailerId!,
            actorsData: [],
            price: 0,
            coverPhoto: season.coverPhoto!,
            seasonNumber: season.seasonNumber.toString(),
          );

          final result = await createSeasonRepo.createSeason(model: seasonReq);

          result.fold(
            (error) {
              throw Exception(error.message);
            },
            (response) {
              currentSeasonId = response.id;
            },
          );
        }

        if (currentSeasonId == null) continue;

        for (int i = 0; i < season.episodes.length; i++) {
          final episode = season.episodes[i];
          if (episode.uploadedVideoId == null) {
            if (mounted) {
              setState(() => _isLoading = false);
              Navigator.pop(context);
              AppMessages.showError(
                context,
                '${AppStrings.season.tr()} ${season.seasonNumber} ${AppStrings.episode.tr()} ${i + 1}: ${AppStrings.videoNotUploaded.tr()}',
              );
            }
            return;
          }

          if (episode.existingId != null) {
            // Update
            // Only send video if it changed (new video uploaded)
            final videoChanged =
                episode.originalVideoId != null &&
                episode.uploadedVideoId != null &&
                episode.uploadedVideoId != episode.originalVideoId;

            final updateReq = UpdateEpisodeRequestModel(
              episodeId: episode.existingId!,
              seasonId: currentSeasonId,
              episodeNumber: i + 1,
              title: episode.titleController.text,
              description: episode.descriptionController.text,
              // Only send video if it changed
              video: videoChanged ? episode.uploadedVideoId : null,
            );
            final result = await updateEpisodeRepo.updateEpisode(
              model: updateReq,
            );
            result.fold(
              (error) => throw Exception(error.message),
              (success) => null,
            );
          } else {
            // Create
            final episodeReq = CreateEpisodeRequestModel(
              seasonId: currentSeasonId!,
              episodeNumber: i + 1,
              title: episode.titleController.text,
              description: episode.descriptionController.text,
              video: episode.uploadedVideoId!,
            );

            final result = await createEpisodeRepo.createEpisode(
              model: episodeReq,
            );
            result.fold(
              (error) => throw Exception(error.message),
              (success) => null,
            );
          }
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
        AppMessages.showSuccess(context, AppStrings.uploadedSuccessfully.tr());
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppMessages.showError(
          context,
          '${AppStrings.error.tr()}: ${e.toString()}',
        );
      }
    }
  }
}

class SeasonData {
  int seasonNumber;
  int? existingId;
  File? coverPhoto;
  File? trailerFile;
  String? uploadedTrailerId;
  bool isExpanded;
  final List<EpisodeData> episodes = [EpisodeData()];

  SeasonData({
    required this.seasonNumber,
    this.existingId,
    this.isExpanded = true,
  });

  void dispose() {
    for (var episode in episodes) {
      episode.dispose();
    }
  }
}

class EpisodeData {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? videoFile;
  String? uploadedVideoId;
  String? originalVideoId; // Track original video ID to detect changes
  int? existingId;
  bool isReady = true; // Track video ready status

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
  }
}

class EpisodeItemWidget extends StatelessWidget {
  final EpisodeData episode;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback? onVideoUploaded;

  const EpisodeItemWidget({
    super.key,
    required this.episode,
    required this.index,
    required this.onRemove,
    this.onVideoUploaded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F0),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Episode ${index + 1}',
                style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w600),
              ),
              if (index > 0)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: episode.titleController,
            decoration: _inputDecoration('Episode Title', 'Enter episode name'),
            validator: (value) => value!.isEmpty ? 'Please enter title' : null,
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: episode.descriptionController,
            maxLines: 3,
            decoration: _inputDecoration(
              'Episode Description',
              'Enter description',
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter description' : null,
          ),
          SizedBox(height: 12.h),
          Text(
            'Upload Episode Video',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8.h),

          BlocConsumer<VideoUploadCubit, VideoUploadState>(
            listener: (context, state) {
              if (state is VideoUploadSuccess) {
                // If this is an existing episode and video changed, mark as not ready
                final videoChanged =
                    episode.existingId != null &&
                    episode.uploadedVideoId != null &&
                    episode.uploadedVideoId != state.videoId;

                if (videoChanged) {
                  episode.isReady = false; // New video needs processing
                }

                episode.uploadedVideoId = state.videoId;

                // Trigger rebuild of parent widget
                onVideoUploaded?.call();

                AppMessages.showSuccess(
                  context,
                  'Video for Episode ${index + 1} uploaded!',
                );
              } else if (state is VideoUploadError) {
                AppMessages.showError(
                  context,
                  'Upload failed: ${state.message}',
                );
              }
            },
            builder: (context, state) {
              return InkWell(
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.video,
                  );
                  if (result != null && result.files.single.path != null) {
                    episode.videoFile = File(result.files.single.path!);
                    context.read<VideoUploadCubit>().uploadVideo(
                      videoFile: episode.videoFile!,
                    );
                  }
                },
                child: DottedBorder(
                  color: const Color(0xFFFF6B35),
                  strokeWidth: 1.5,
                  dashPattern: const [6, 3],
                  borderType: BorderType.RRect,
                  radius: Radius.circular(8.r),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: _buildUploadContent(
                      state,
                      episode.videoFile,
                      episode,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUploadContent(
    VideoUploadState state,
    File? file,
    EpisodeData episode,
  ) {
    if (state is VideoUploadLoading || state is VideoUploadProgress) {
      int progress = 0;
      if (state is VideoUploadProgress) progress = state.progress;
      return Column(
        children: [
          CircularProgressIndicator(
            value: progress / 100,
            color: const Color(0xFFFF6B35),
          ),
          SizedBox(height: 8.h),
          Text('$progress%', style: TextStyle(fontSize: 17.sp)),
        ],
      );
    }
    // Check if video is uploaded (either from new upload or existing from edit)
    if (state is VideoUploadSuccess || episode.uploadedVideoId != null) {
      // Check if video is ready (for display purposes only - doesn't block update)
      final videoChanged =
          episode.existingId != null &&
          episode.originalVideoId != null &&
          episode.uploadedVideoId != null &&
          episode.uploadedVideoId != episode.originalVideoId;
      final isReady = episode.existingId == null
          ? true
          : (videoChanged ? false : episode.isReady);

      return Column(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            AppStrings.uploadedSuccessfully.tr(),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          if (file != null) ...[
            SizedBox(height: 4.h),
            Text(
              file.path.split('/').last,
              style: TextStyle(fontSize: 11.sp, color: Colors.black87),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (!isReady && videoChanged) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16.sp,
                  height: 16.sp,
                  child: AnimatedLoading(
                    color: Colors.orange,
                    size: 16,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  'Processing...',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    }
    return Column(
      children: [
        Text(
          'Choose video to upload trailer*',
          style: TextStyle(color: const Color(0xFFFF6B35), fontSize: 11.sp),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        Text(
          '(Supported formats: .mp4, .mov)',
          style: TextStyle(color: Colors.grey, fontSize: 10.sp),
        ),
        SizedBox(height: 8.h),
        Icon(Icons.cloud_upload_outlined, color: Colors.grey, size: 20.sp),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 17.sp, color: Colors.grey),
      hintText: hint,
      hintStyle: TextStyle(fontSize: 17.sp, color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    );
  }
}

class SeasonTrailerUploadWidget extends StatelessWidget {
  final SeasonData season;

  const SeasonTrailerUploadWidget({super.key, required this.season});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Season Trailer',
          style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        BlocConsumer<VideoUploadCubit, VideoUploadState>(
          listener: (context, state) {
            if (state is VideoUploadSuccess) {
              season.uploadedTrailerId = state.videoId;
              AppMessages.showSuccess(context, 'Season trailer uploaded!');
            } else if (state is VideoUploadError) {
              AppMessages.showError(context, 'Upload failed: ${state.message}');
            }
          },
          builder: (context, state) {
            return InkWell(
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.video,
                );
                if (result != null && result.files.single.path != null) {
                  season.trailerFile = File(result.files.single.path!);
                  context.read<VideoUploadCubit>().uploadVideo(
                    videoFile: season.trailerFile!,
                  );
                }
              },
              child: DottedBorder(
                color: const Color(0xFFFF6B35),
                strokeWidth: 1.5,
                dashPattern: const [6, 3],
                borderType: BorderType.RRect,
                radius: Radius.circular(8.r),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F0),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: _buildContent(state, season.trailerFile),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContent(VideoUploadState state, File? file) {
    if (state is VideoUploadLoading || state is VideoUploadProgress) {
      int progress = 0;
      if (state is VideoUploadProgress) progress = state.progress;
      return Column(
        children: [
          CircularProgressIndicator(
            value: progress / 100,
            color: const Color(0xFFFF6B35),
          ),
          SizedBox(height: 8.h),
          Text('$progress%', style: TextStyle(fontSize: 17.sp)),
        ],
      );
    }
    if (state is VideoUploadSuccess ||
        (file != null && season.uploadedTrailerId != null)) {
      return Column(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            file?.path.split('/').last ?? 'Trailer uploaded',
            style: TextStyle(fontSize: 17.sp, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return Column(
      children: [
        Text(
          'Choose video to upload trailer*',
          style: TextStyle(color: const Color(0xFFFF6B35), fontSize: 17.sp),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        Text(
          '(Supported formats: .mp4, .mov)',
          style: TextStyle(color: Colors.grey, fontSize: 10.sp),
        ),
        SizedBox(height: 8.h),
        Icon(Icons.cloud_upload_outlined, color: Colors.grey, size: 24.sp),
      ],
    );
  }
}
