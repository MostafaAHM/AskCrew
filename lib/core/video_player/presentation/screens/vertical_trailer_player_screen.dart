import 'package:aflam/features/viewer/favorites/presentation/widgets/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:aflam/config/routes/routes.dart';
import '../cubit/video_player_cubit.dart';
import '../widgets/bunny_embed_player.dart';
import '../../../../core/extensions/space_extension.dart';
import '../../../../features/viewer/explore_viewer/data/models/explore_response_model.dart';

class VerticalTrailerPlayerScreen extends StatefulWidget {
  final List<ExploreItemModel> items;
  final int initialIndex;

  const VerticalTrailerPlayerScreen({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  @override
  State<VerticalTrailerPlayerScreen> createState() =>
      _VerticalTrailerPlayerScreenState();
}

class _VerticalTrailerPlayerScreenState
    extends State<VerticalTrailerPlayerScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: 1.0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: context.read<VideoPlayerCubit>())],
      child: Scaffold(
        backgroundColor: Colors.black,
        body: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: widget.items.length,
          physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final item = widget.items[index];
            return _VideoPage(
              key: ValueKey('video_${item.id}'),
              item: item,
              isVisible: index == _currentIndex,
            );
          },
        ),
      ),
    );
  }
}

class _VideoPage extends StatefulWidget {
  final ExploreItemModel item;
  final bool isVisible;

  const _VideoPage({super.key, required this.item, required this.isVisible});

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.isVisible) {
      context.read<VideoPlayerCubit>().getVideoToken(
        contentType: widget.item.contentType,
        contentId: widget.item.id,
        playTrailer: true,
      );
    }
  }

  @override
  void didUpdateWidget(_VideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      context.read<VideoPlayerCubit>().getVideoToken(
        contentType: widget.item.contentType,
        contentId: widget.item.id,
        playTrailer: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Positioned.fill(
          child: BlocConsumer<VideoPlayerCubit, VideoPlayerState>(
            listener: (context, state) {
              if (state is VideoPlayerError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is VideoPlayerLoading) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (state is VideoPlayerError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 64.sp,
                      ),
                      16.height,
                      Text(
                        'Error loading trailer',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                      8.height,
                      Text(
                        state.message,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (state is VideoPlayerLoaded) {
                return BunnyEmbedPlayer(videoToken: state.videoToken);
              }
              return SizedBox.shrink();
            },
          ),
        ),
        Positioned(
          top: 40.h,
          left: 16.w,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.white, size: 28.sp),
            onPressed: () => context.pop(),
          ),
        ),
        Positioned(
          right: 16.w,
          bottom: 120.h,
          child: Column(
            children: [
              FavoriteButton(
                contentType: widget.item.contentType,
                objectId: widget.item.id,
                size: 32.sp,
                variant: FavoriteStyleVariant.banner,
              ),
              24.height,
              _WatchButton(item: widget.item),
            ],
          ),
        ),
        Positioned(
          left: 16.w,
          bottom: 40.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item.title ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              8.height,
              Text(
                'Tap to play/pause',
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WatchButton extends StatelessWidget {
  final ExploreItemModel item;

  const _WatchButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final movieOrSeriesItem = item.toMovieOrSeriesItem();
        context.pushNamed(Routes.movieDetails, extra: movieOrSeriesItem);
      },
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.45),
        ),
        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32.sp),
      ),
    );
  }
}
