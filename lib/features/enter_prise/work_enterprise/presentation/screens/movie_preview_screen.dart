import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/movie_model.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/series_response_model.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/episodes_response_model.dart';
import 'package:aflam/features/enter_prise/work_enterprise/presentation/cubit/get_seasons_cubit.dart';
import 'package:aflam/features/enter_prise/work_enterprise/presentation/cubit/get_episodes_cubit.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/widgets/animations/animated_slide_in.dart';
import '../../presentation/cubit/content_management_cubit.dart';
import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import '../../../../../../config/routes/routes.dart';

class MoviePreviewScreen extends StatefulWidget {
  final dynamic content; 
  const MoviePreviewScreen({super.key, required this.content});

  @override
  State<MoviePreviewScreen> createState() => _MoviePreviewScreenState();
}

class _MoviePreviewScreenState extends State<MoviePreviewScreen> with TickerProviderStateMixin {
  static const Color _primaryOrange = Color(0xFFFF5722);
  
  late final bool _isSeries;
  TabController? _tabController;
  int _currentSeasonNumber = 1;
  int _currentEpisodeNumber = 1;
  
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _isSeries = widget.content is SeriesModel;
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSeries) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => getIt<GetSeasonsCubit>()..getSeasons((widget.content as SeriesModel).id)),
          BlocProvider(create: (context) => getIt<GetEpisodesCubit>()),
          BlocProvider(create: (context) => getIt<ContentManagementCubit>()),
        ],
        child: BlocListener<ContentManagementCubit, ContentManagementState>(
          listener: (context, state) {
            if (state is ContentManagementSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
              if (state.message.contains('Episode deleted')) {
                final currentSeasonIndex = _tabController?.index ?? 0;
                final seasonsState = context.read<GetSeasonsCubit>().state;
                if (seasonsState is GetSeasonsLoaded) {
                   context.read<GetEpisodesCubit>().getEpisodes(seasonsState.seasons[currentSeasonIndex].id);
                }
              } else if (state.message.contains('Series deleted')) {
                Navigator.of(context).pop();
              }
            } else if (state is ContentManagementError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: _buildScaffold(),
        ),
      );
    }
    return _buildScaffold();
  }

  Widget _buildScaffold() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.backAppBar(
        showLogoInBackAppBar: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSlideIn(
              index: 0,
              controller: _animationController,
              child: _buildVideoPlayer(),
            ),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  AnimatedSlideIn(
                    index: 1,
                    controller: _animationController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleSection(),
                        16.height,
                        _buildAboutSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: AnimatedSlideIn(
                index: 2,
                controller: _animationController,
                child: _isSeries
                    ? _buildSeriesTabsAndList()
                    : _buildMovieActors(),
              ),
            ),
            
            20.height,
          ],
        ),
      ),
    );
  }

  String _getName() {
    if (_isSeries) return (widget.content as SeriesModel).title;
    return (widget.content as MovieModel).name;
  }
  
  String _getAbout() {
    if (_isSeries) return (widget.content as SeriesModel).about;
    return (widget.content as MovieModel).about;
  }

  String _getDate() {
    if (_isSeries) return (widget.content as SeriesModel).createdAt;
    return (widget.content as MovieModel).createdAt;
  }
  
  String _getViews() {
    if (_isSeries) return (widget.content as SeriesModel).viewsCount.toString();
    return (widget.content as MovieModel).viewsCount.toString();
  }

  String? _getCover() {
    if (_isSeries) return (widget.content as SeriesModel).coverPhoto;
    return (widget.content as MovieModel).coverImage;
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _getName(),
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
            if (_isSeries)
              Text(
                "Season $_currentSeasonNumber _ Episode $_currentEpisodeNumber",
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              )
            else
              Text(
                _formatDate(_getDate()),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        if (!_isSeries) ...[
          8.height,
          Row(
            children: [
              Icon(Icons.visibility_outlined, color: _primaryOrange, size: 18.sp),
              6.width,
              Text(
                _getViews(),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ]
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        8.height,
        Text(
          _getAbout(),
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        20.height,
      ],
    );
  }

  Widget _buildSeriesTabsAndList() {
    return BlocBuilder<GetSeasonsCubit, GetSeasonsState>(
      builder: (context, state) {
        if (state is GetSeasonsLoading) {
          return _buildListShimmer();
        } else if (state is GetSeasonsLoaded) {
          if (state.seasons.isEmpty) return const Text("No seasons found.");
          
          if (_tabController == null || _tabController!.length != state.seasons.length) {
              _tabController?.dispose();
              _tabController = TabController(length: state.seasons.length, vsync: this);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _currentSeasonNumber = state.seasons.first.seasonNumber;
                  });
                }
              });
              context.read<GetEpisodesCubit>().getEpisodes(state.seasons.first.id);
              _tabController!.addListener(() {
                 if (!_tabController!.indexIsChanging && _tabController!.index < state.seasons.length) {
                     final season = state.seasons[_tabController!.index];
                     setState(() {
                       _currentSeasonNumber = season.seasonNumber;
                     });
                     context.read<GetEpisodesCubit>().getEpisodes(season.id);
                 }
              });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: const Color(0xFFFF5722),
                unselectedLabelColor: Colors.grey[500],
                indicatorColor: const Color(0xFFFF5722),
                indicatorSize: TabBarIndicatorSize.label,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: const Color(0xFFFF5722),
                    width: 3.h,
                  ),
                  insets: EdgeInsets.symmetric(horizontal: -2.w),
                ),
                labelStyle: TextStyle(
                  fontSize: 18.sp, 
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 18.sp, 
                  fontWeight: FontWeight.w400,
                ),
                labelPadding: EdgeInsets.only(right: 24.w),
                padding: EdgeInsets.zero,
                dividerColor: Colors.transparent,
                tabs: state.seasons.map((s) => Tab(text: s.name)).toList(),
                onTap: (index) {},
              ),
              14.height,
              SizedBox( // Use SizedBox with fixed height or constraints if ListView inside ScrollView causes issues, effectively using shrinkWrap
                height: 400.h,
                child: _buildEpisodesList(),
              ),
            ],
          );
        } else if (state is GetSeasonsError) {
          return Text("Error: ${state.message}");
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEpisodesList() {
    return BlocBuilder<GetEpisodesCubit, GetEpisodesState>(
      builder: (context, state) {
        if (state is GetEpisodesLoading) {
           return _buildListShimmer();
        } else if (state is GetEpisodesLoaded) {
           if (state.episodes.isNotEmpty) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
               if (mounted) {
                 setState(() {
                   _currentEpisodeNumber = state.episodes.first.episodeNumber;
                 });
               }
             });
           }
           
           return ListView.separated(
             padding: EdgeInsets.only(bottom: 20.h),
             shrinkWrap: true, // Important inside another ScrollView
             physics: const ClampingScrollPhysics(), // Important for nested scrolling
             itemCount: state.episodes.length,
             separatorBuilder: (_, __) => 12.height,
             itemBuilder: (context, index) {
               final episode = state.episodes[index];
               return _buildEpisodeCard(episode);
             },
           );
        } else if (state is GetEpisodesError) {
          return Text("Error loading episodes: ${state.message}");
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildListShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => 12.height,
        itemBuilder: (_, __) => Container(
          height: 100.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEpisodeCard(EpisodeModel episode) {
    return GestureDetector(
      onTap: () {
        // Navigate to video player for this episode
        context.pushNamed(
          Routes.videoPlayer,
          pathParameters: {
            'contentType': 'episode',
            'contentId': episode.id.toString(),
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE).withOpacity(0.7),
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.all(10.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomCachedNetworkImage(
                    url: episode.image ?? '',
                    width: 85.w,
                    height: 85.w,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: 85.w,
                    height: 85.w,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                  ),
                ],
              ),
            ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600, 
                    fontSize: 22.sp,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                2.height,
                Text(
                  episode.about,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600], 
                    fontSize: 19.sp,
                    height: 1.1,
                  ),
                ),
                4.height,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Episode ${episode.episodeNumber}", 
                      style: TextStyle(
                        color: Colors.grey[500], 
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w400,
                      )
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          color: Colors.grey[400],
                          size: 26.sp,
                        ),
                        6.height,
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: const Color(0xFFFF5722), size: 18.sp),
                            3.width,
                            Text(
                              episode.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.w600, 
                                fontSize: 19.sp,
                                color: Colors.black87,
                              )
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
  
  Widget _buildMovieActors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Actors",
          style: TextStyle(
            fontSize: 25.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        16.height,
        _buildActorsList(),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    // Get content ID and type
    int? contentId;
    String contentType;
    
    if (_isSeries) {
      final series = widget.content as SeriesModel;
      contentId = series.id;
      contentType = 'series';
      
      // We must fetch the trailer through the first season to match Viewer logic.
      // Use BlocBuilder to access the available seasons.
      return BlocBuilder<GetSeasonsCubit, GetSeasonsState>(
        builder: (context, seasonsState) {
          int? finalContentId = contentId;
          String finalContentType = contentType;
          if (seasonsState is GetSeasonsLoaded && seasonsState.seasons.isNotEmpty) {
            finalContentId = seasonsState.seasons.first.id;
            finalContentType = 'season';
          }
          return _buildVideoPlayerWidget(finalContentId, finalContentType, isTrailer: true);
        },
      );
    } else {
      final movie = widget.content as MovieModel;
      contentId = movie.id;
      contentType = 'movie';
      return _buildVideoPlayerWidget(contentId, contentType, isTrailer: true);
    }
  }

  Widget _buildVideoPlayerWidget(int? contentId, String contentType, {bool isTrailer = false}) {
    return GestureDetector(
      onTap: () {
        if (contentId != null) {
          context.pushNamed(
            isTrailer ? Routes.trailerPlayer : Routes.videoPlayer,
            pathParameters: {
              'contentType': contentType,
              'contentId': contentId.toString(),
            },
          );
        }
      },
      child: Container(
        height: 220.h,
        decoration: BoxDecoration(
          color: Colors.black,
          image: _getCover() != null
              ? DecorationImage(
                  image: NetworkImage(_getCover()!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              )
            ),
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 35.sp),
            ),
          
          ],
        ),
      ),
    );
  }

  Widget _buildActorsList() {
    final actors = _isSeries ? (widget.content as SeriesModel).actors : (widget.content as MovieModel).actors;
    if (actors.isEmpty) {
      return Text("No actors listed", style: TextStyle(color: Colors.grey, fontSize: 14.sp));
    }
    return SizedBox(
      height: 80.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actors.length,
        separatorBuilder: (_, __) => 20.width,
        itemBuilder: (context, index) {
          final actor = actors[index];
          return SizedBox(
            width: 55.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: CustomCachedNetworkImage(
                    url: actor.image ?? '',
                    width: 40.w,
                    height: 40.w,
                    fit: BoxFit.cover,
                  ),
                ),
                2.height,
                Flexible(
                  child: Text(
                    actor.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
