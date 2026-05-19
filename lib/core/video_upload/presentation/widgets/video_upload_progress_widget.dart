import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/video_upload_cubit.dart';

class VideoUploadProgressWidget extends StatelessWidget {
  const VideoUploadProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoUploadCubit, VideoUploadState>(
      builder: (context, state) {
        if (state is VideoUploadInitial) {
          return const SizedBox.shrink();
        }

        if (state is VideoUploadLoading) {
          return _buildProgressCard(
            progress: 0,
            statusText: 'Initializing upload...',
            showControls: false,
          );
        }

        if (state is VideoUploadProgress) {
          return _buildProgressCard(
            progress: state.progress / 100,
            statusText: 'Uploading...',
            percentage: state.progress,
            timeRemaining: 'Calculating...',
            showControls: true,
            isPaused: false,
            onPause: () {
              context.read<VideoUploadCubit>().pauseUpload();
            },
            onCancel: () {
              context.read<VideoUploadCubit>().cancelUpload();
            },
          );
        }

        if (state is VideoUploadPaused) {
          return _buildProgressCard(
            progress: state.progress / 100,
            statusText: 'Paused',
            percentage: state.progress,
            timeRemaining: 'Paused',
            showControls: true,
            isPaused: true,
            onPause: () {
              context.read<VideoUploadCubit>().resumeUpload();
            },
            onCancel: () {
              context.read<VideoUploadCubit>().cancelUpload();
            },
          );
        }

        if (state is VideoUploadSuccess) {
          return _buildSuccessCard();
        }

        if (state is VideoUploadError) {
          return _buildErrorCard(state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProgressCard({
    required double progress,
    required String statusText,
    int? percentage,
    String? timeRemaining,
    bool showControls = false,
    bool isPaused = false,
    VoidCallback? onPause,
    VoidCallback? onCancel,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  if (percentage != null)
                    Text(
                      '$percentage% • ${timeRemaining ?? "Calculating..."}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
              if (showControls)
                Row(
                  children: [
                    if (onPause != null)
                      GestureDetector(
                        onTap: onPause,
                        child: Icon(
                          isPaused
                              ? Icons.play_circle_outline
                              : Icons.pause_circle_outline,
                          color: Colors.grey.shade600,
                          size: 28.sp,
                        ),
                      ),
                    SizedBox(width: 12.w),
                    if (onCancel != null)
                      GestureDetector(
                        onTap: onCancel,
                        child: Icon(
                          Icons.cancel_outlined,
                          color: const Color(0xFFFF5252), // Red color
                          size: 28.sp,
                        ),
                      ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF673AB7),
              ), // Purple
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700, size: 24.sp),
          SizedBox(width: 12.w),
          Text(
            'Upload Completed Successfully!',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Upload Failed: $message',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.red.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
