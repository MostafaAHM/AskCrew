import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/app_urls.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String name;
  final String profession;
  final String profileImage;
  final bool isVerified;
  final double rating;
  final int reviewsCount;
  final bool isAvailable;
  final List<String>? images; // Profile images for gallery

  const ProfileHeaderWidget({
    super.key,
    required this.name,
    required this.profession,
    required this.profileImage,
    this.isVerified = false,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.isAvailable = false,
    this.images,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AvatarStatus(
          image: profileImage,
          isAvailable: isAvailable,
          images: images,
        ),
        16.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Name + verified
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isVerified) ...[
                    6.width,
                    Icon(
                      Icons.verified,
                      color: const Color(0xFF2F80ED),
                      size: 20.sp,
                    ),
                  ],
                ],
              ),

              6.height,

              /// Actor + stars + rating
              Row(
                children: [
                  Flexible(
                    child: Text(
                      profession,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.greyText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  10.width,

                  ...List.generate(5, (index) {
                    final filled = index < rating.floor();
                    return Icon(
                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: AppColors.secondaryColor,
                      size: 18.sp,
                    );
                  }),

                  8.width,

                  Text(
                    rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                ],
              ),

              6.height,

              /// reviews
              Text(
                '($reviewsCount reviews)',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvatarStatus extends StatelessWidget {
  final String image;
  final bool isAvailable;
  final List<String>? images;

  const _AvatarStatus({
    required this.image,
    required this.isAvailable,
    this.images,
  });

  @override
  Widget build(BuildContext context) {
    // Check if there are images to show in gallery
    final hasImages = images != null && images!.isNotEmpty;

    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: hasImages
                  ? () => _ImageGalleryDialog.show(context, images!)
                  : null,
              child: ClipOval(
                child: CustomCachedNetworkImage(
                  url: image,
                  width: 78.w,
                  height: 78.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (isAvailable)
              Positioned(
                right: 4.w,
                bottom: 4.w,
                child: Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.whiteColor, width: 2),
                  ),
                ),
              ),
          ],
        ),
        8.height,
        Text(
          'Available',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.greyText,
          ),
        ),
      ],
    );
  }
}

class _ImageGalleryDialog extends StatefulWidget {
  final List<String> images;

  const _ImageGalleryDialog({required this.images});

  static void show(BuildContext context, List<String> images) {
    showDialog(
      context: context,
      builder: (context) => _ImageGalleryDialog(images: images),
    );
  }

  @override
  State<_ImageGalleryDialog> createState() => _ImageGalleryDialogState();
}

class _ImageGalleryDialogState extends State<_ImageGalleryDialog> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Photo gallery
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              final imageUrl = widget.images[index];
              final fullUrl = imageUrl.startsWith('http')
                  ? imageUrl
                  : AppUrls.imageLink(imageUrl);

              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(fullUrl),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            itemCount: widget.images.length,
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
              ),
            ),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          // Close button
          Positioned(
            top: 40.h,
            right: 16.w,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30.sp),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // Image counter
          if (widget.images.length > 1)
            Positioned(
              bottom: 40.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
