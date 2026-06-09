import 'package:aflam/core/widgets/animated_loading/animated_loading.dart';
import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/episodes_response_model.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/seasons_response_model.dart';
import 'package:aflam/features/enter_prise/work_enterprise/presentation/cubit/get_episodes_cubit.dart';
import 'package:aflam/features/enter_prise/work_enterprise/presentation/cubit/get_seasons_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:aflam/features/viewer/continue_watching/presentation/cubit/continue_watching_cubit.dart';
import 'package:aflam/features/viewer/continue_watching/data/models/continue_watching_request_model.dart';

import '../../../../config/routes/routes.dart';

/// Seasons and Episodes section for series
class SeriesSeasonsEpisodesWidget extends StatefulWidget {
  final int seriesId;
  final bool isPaid;
  final VoidCallback onEpisodePlay;

  const SeriesSeasonsEpisodesWidget({
    super.key,
    required this.seriesId,
    required this.isPaid,
    required this.onEpisodePlay,
  });

  @override
  State<SeriesSeasonsEpisodesWidget> createState() =>
      _SeriesSeasonsEpisodesWidgetState();
}

class _SeriesSeasonsEpisodesWidgetState
    extends State<SeriesSeasonsEpisodesWidget> {
  int? _selectedSeasonId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<GetSeasonsCubit>()..getSeasons(widget.seriesId),
        ),
        BlocProvider(create: (context) => getIt<GetEpisodesCubit>()),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seasons tabs
          BlocBuilder<GetSeasonsCubit, GetSeasonsState>(
            builder: (context, seasonsState) {
              if (seasonsState is GetSeasonsLoaded &&
                  seasonsState.seasons.isNotEmpty) {
                final seasons = seasonsState.seasons;

                // Auto-select first season if none selected
                if (_selectedSeasonId == null && seasons.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _selectedSeasonId = seasons.first.id;
                    });
                    context.read<GetEpisodesCubit>().getEpisodes(
                      seasons.first.id,
                    );
                  });
                }

                return _SeasonsTabsWidget(
                  seasons: seasons,
                  selectedSeasonId: _selectedSeasonId,
                  onSeasonSelected: (seasonId, seasonNumber) {
                    setState(() {
                      _selectedSeasonId = seasonId;
                    });
                    context.read<GetEpisodesCubit>().getEpisodes(seasonId);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Episodes list
          if (_selectedSeasonId != null) ...[
            16.height,
            BlocBuilder<GetEpisodesCubit, GetEpisodesState>(
              builder: (context, episodesState) {
                if (episodesState is GetEpisodesLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: AnimatedLoading(),
                    ),
                  );
                }

                if (episodesState is GetEpisodesError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.h),
                      child: Text(
                        episodesState.message,
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    ),
                  );
                }

                if (episodesState is GetEpisodesLoaded) {
                  final episodes = episodesState.episodes;
                  if (episodes.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.h),
                        child: Text(
                          'No episodes found'.tr(),
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return _EpisodesListWidget(
                    episodes: episodes,
                    isPaid: widget.isPaid,
                    onEpisodeTap: (episode) async {
                      if (!widget.isPaid) {
                        AppMessages.showError(context, 'Please pay first'.tr());
                        return;
                      }

                      final cwCubit = context.read<ContinueWatchingCubit>();
                      await cwCubit.loadContinueWatching();
                      final cwId = cwCubit.getContinueWatchingId(
                        episode.id,
                        'episode',
                      );

                      if (!context.mounted) return;

                      // Navigate to video player for episode
                      // Use 'episode' as contentType for episodes, not 'series'
                      context.pushNamed(
                        Routes.videoPlayer,
                        pathParameters: {
                          'contentType': 'episode',
                          'contentId': episode.id.toString(),
                        },
                        extra: {
                          'onProgress': (int progress) {
                            cwCubit.updateProgress(
                              UpdateContinueWatchingRequest(
                                contentId: episode.id,
                                artWorkType: 'episode',
                                progress: progress,
                                continueWatchingId: cwId,
                              ),
                            );
                          },
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Seasons tabs widget
class _SeasonsTabsWidget extends StatelessWidget {
  final List<SeasonModel> seasons;
  final int? selectedSeasonId;
  final Function(int seasonId, int seasonNumber) onSeasonSelected;

  const _SeasonsTabsWidget({
    required this.seasons,
    required this.selectedSeasonId,
    required this.onSeasonSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: seasons.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final season = seasons[index];
          final isSelected = season.id == selectedSeasonId;

          return GestureDetector(
            onTap: () => onSeasonSelected(season.id, season.seasonNumber),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? AppColors.secondaryColor
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  'Season ${season.seasonNumber}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.secondaryColor
                        : AppColors.lightSecMainText,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Episodes list widget
class _EpisodesListWidget extends StatelessWidget {
  final List<EpisodeModel> episodes;
  final bool isPaid;
  final Function(EpisodeModel) onEpisodeTap;

  const _EpisodesListWidget({
    required this.episodes,
    required this.isPaid,
    required this.onEpisodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: episodes.length,
      separatorBuilder: (_, __) => 16.height,
      itemBuilder: (context, index) {
        final episode = episodes[index];
        return _EpisodeCard(
          episode: episode,
          isPaid: isPaid,
          onTap: () => onEpisodeTap(episode),
        );
      },
    );
  }
}

/// Individual episode card
class _EpisodeCard extends StatelessWidget {
  final EpisodeModel episode;
  final bool isPaid;
  final VoidCallback onTap;

  const _EpisodeCard({
    required this.episode,
    required this.isPaid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isPaid ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Episode thumbnail
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                bottomLeft: Radius.circular(12.r),
              ),
              child: episode.image != null
                  ? CustomCachedNetworkImage(
                      url: episode.image!,
                      serverImage: true,
                      width: 120.w,
                      height: 80.h,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 120.w,
                      height: 80.h,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 40.sp,
                        color: Colors.grey[600],
                      ),
                    ),
            ),
            12.width,
            // Episode details
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      episode.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: AppColors.lightMainText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.height,
                    Text(
                      'Episode ${episode.episodeNumber}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.lightSecMainText,
                      ),
                    ),
                    if (episode.about.isNotEmpty) ...[
                      4.height,
                      Text(
                        episode.about,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.sp,
                          color: AppColors.lightSecMainText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Rating and play icon
            Padding(
              padding: EdgeInsets.only(right: 8.w, top: 8.h),
              child: Column(
                children: [
                  if (episode.rating > 0) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 16.sp),
                        4.width,
                        Text(
                          episode.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    8.height,
                  ],
                  Icon(
                    Icons.play_circle_outline,
                    color: isPaid ? AppColors.primaryColor : Colors.grey[400],
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
