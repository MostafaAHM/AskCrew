import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/advertise_model.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/widgets/animations/animated_slide_in.dart';
import '../../presentation/cubit/content_management_cubit.dart';
import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import '../../../../../../config/routes/routes.dart';

class AdvertisePreviewScreen extends StatefulWidget {
  final AdvertiseModel advertise;
  const AdvertisePreviewScreen({super.key, required this.advertise});

  @override
  State<AdvertisePreviewScreen> createState() => _AdvertisePreviewScreenState();
}

class _AdvertisePreviewScreenState extends State<AdvertisePreviewScreen> with TickerProviderStateMixin {
  static const Color _primaryOrange = Color(0xFFFF5722);
  
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ContentManagementCubit>(),
      child: _buildScaffold(),
    );
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
                        16.height,
                        _buildInfoSection(),
                        16.height,
                        _buildRatingSection(),
                        16.height,
                        _buildStatusSection(),
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
                child: _buildActorsList(),
              ),
            ),
            
            20.height,
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                widget.advertise.name,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
            ),
            Text(
              _formatDate(widget.advertise.createdAt),
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        8.height,
        Row(
          children: [
            Icon(Icons.visibility_outlined, color: _primaryOrange, size: 18.sp),
            6.width,
            Text(
              widget.advertise.viewsCount.toString(),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            20.width,
            if (widget.advertise.price.isNotEmpty) ...[
              Icon(Icons.attach_money, color: _primaryOrange, size: 18.sp),
              6.width,
              Text(
                widget.advertise.price,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    if (widget.advertise.about.isEmpty) {
      return const SizedBox.shrink();
    }
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
          widget.advertise.about,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.advertise.category.name.isNotEmpty) ...[
          Row(
            children: [
              Text(
                "Category: ",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                widget.advertise.category.name,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: _primaryOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRatingSection() {
    return Row(
      children: [
        Icon(Icons.star, color: _primaryOrange, size: 20.sp),
        6.width,
        Text(
          widget.advertise.ratingMean.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        8.width,
        Text(
          "(${widget.advertise.ratingCount} ${widget.advertise.ratingCount == 1 ? 'rating' : 'ratings'})",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        if (widget.advertise.isRated && widget.advertise.userRating != null) ...[
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: _primaryOrange, size: 16.sp),
                4.width,
                Text(
                  "Your rating: ${widget.advertise.userRating!.toStringAsFixed(1)}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _primaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusSection() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 8.h,
      children: [
        if (widget.advertise.isReady)
          _buildStatusChip("Ready", Colors.green),
        if (widget.advertise.adminApproved)
          _buildStatusChip("Approved", Colors.blue)
        else
          _buildStatusChip("Pending Approval", Colors.orange),
        if (widget.advertise.isFavorite)
          _buildStatusChip("Favorite", Colors.red),
      ],
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: () {
        // Navigate to video player with advertise ID
        context.pushNamed(
          Routes.videoPlayer,
          pathParameters: {
            'contentType': 'advertise',
            'contentId': widget.advertise.id.toString(),
          },
        );
      },
      child: Container(
        height: 220.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          image: widget.advertise.coverImage.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(widget.advertise.coverImage),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    // Handle image loading error silently
                  },
                )
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Container(
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
                ),
              ),
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
    final actors = widget.advertise.actors;
    if (actors.isEmpty) {
      return const SizedBox.shrink();
    }

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
        SizedBox(
          height: 90.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: actors.length,
            separatorBuilder: (_, __) => 20.width,
            itemBuilder: (context, index) {
              final actor = actors[index];
              return SizedBox(
                width: 60.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: CustomCachedNetworkImage(
                        url: actor.image,
                        width: 45.w,
                        height: 45.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    3.height,
                    Flexible(
                      child: Text(
                        actor.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.sp,
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
        ),
      ],
    );
  }
}

