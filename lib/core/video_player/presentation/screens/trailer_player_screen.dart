import 'package:aflam/core/widgets/animated_loading/animated_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../cubit/video_player_cubit.dart';
import '../widgets/bunny_embed_player.dart';
import '../../../../core/extensions/space_extension.dart';

class TrailerPlayerScreen extends StatefulWidget {
  final String contentType;
  final int contentId;

  const TrailerPlayerScreen({
    super.key,
    required this.contentType,
    required this.contentId,
  });

  @override
  State<TrailerPlayerScreen> createState() => _TrailerPlayerScreenState();
}

class _TrailerPlayerScreenState extends State<TrailerPlayerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VideoPlayerCubit>().getVideoToken(
      contentType: widget.contentType,
      contentId: widget.contentId,
      playTrailer: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text('Trailer', style: TextStyle(color: Colors.white, fontSize: 18.sp)),
      ),
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
            return Center(child: AnimatedLoading(color: Colors.white));
          }
          if (state is VideoPlayerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 64.sp),
                  16.height,
                  Text('Error loading trailer', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                  8.height,
                  Text(state.message, style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                ],
              ),
            );
          }
          if (state is VideoPlayerLoaded) {
            return Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: BunnyEmbedPlayer(
                  videoToken: state.videoToken,
                  onVideoEnded: () => context.pop(),
                ),
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
