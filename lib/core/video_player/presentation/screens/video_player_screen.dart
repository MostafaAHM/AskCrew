import 'package:aflam/core/widgets/animated_loading/animated_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../cubit/video_player_cubit.dart';
import '../widgets/bunny_embed_player.dart';
import '../../../../core/extensions/space_extension.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String contentType; // 'movie', 'series', 'episode', etc.
  final int contentId;
  final bool playTrailer; // If true, play trailer instead of full video
  final Function(int progress)? onProgress;

  const VideoPlayerScreen({
    super.key,
    required this.contentType,
    required this.contentId,
    this.playTrailer = false,
    this.onProgress,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  @override
  void initState() {
    super.initState();
    // Set orientation to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Hide system UI for fullscreen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Load video token
    context.read<VideoPlayerCubit>().getVideoToken(
      contentType: widget.contentType,
      contentId: widget.contentId,
      playTrailer: widget.playTrailer,
    );
  }

  @override
  void dispose() {
    // Restore orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Show system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<VideoPlayerCubit, VideoPlayerState>(
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
              child: AnimatedLoading(color: Colors.white),
            );
          }

          if (state is VideoPlayerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 64.r),
                  16.height,
                  Text(
                    'Error loading video',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                  8.height,
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    textAlign: TextAlign.center,
                  ),
                  24.height,
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (state is VideoPlayerLoaded) {
            return Stack(
              children: [
                // WebView player with embed_url
                BunnyEmbedPlayer(
                  videoToken: state.videoToken,
                  onVideoEnded: () {
                    context.pop();
                  },
                  onProgress: widget.onProgress,
                ),
                // Close button
                Positioned(
                  top: 16.h,
                  left: 16.w,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 32.r),
                    onPressed: () => context.pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      padding: EdgeInsets.all(8.w),
                    ),
                  ),
                ),
              ],
            );
          }

          return SizedBox.shrink();
        },
      ),
    );
  }
}
