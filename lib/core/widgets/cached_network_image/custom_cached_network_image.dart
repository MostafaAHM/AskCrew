import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/app_urls.dart';
import '../shimmer/custom_shimmer_widget.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  const CustomCachedNetworkImage({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
    this.radius,
    this.url,
    this.serverImage = true,
    this.fit,
  });
  final double? height, width, radius;
  final String? url;
  final bool? serverImage;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  @override
  Widget build(BuildContext context) {
    final hasHeight = height != null && height!.isFinite;
    final hasWidth = width != null && width!.isFinite;

    return Container(
      height: hasHeight ? height : null,
      width: hasWidth ? width : null,
      constraints: (!hasHeight || !hasWidth)
          ? BoxConstraints(
              maxHeight: hasHeight ? height! : double.infinity,
              maxWidth: hasWidth ? width! : double.infinity,
            )
          : null,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(radius ?? 8.r),
      ),
      child: CachedNetworkImage(
        placeholder: (context, url) => CustomShimmerWidget(
          borderRadius: borderRadius ?? BorderRadius.circular(radius ?? 8.r),
          height: hasHeight ? height : null,
          width: hasWidth ? width : null,
        ),
        fit: fit ?? BoxFit.cover,
        errorWidget: (context, url, error) => Container(
          height: hasHeight ? height : null,
          width: hasWidth ? width : null,
          constraints: (!hasHeight || !hasWidth)
              ? BoxConstraints(
                  maxHeight: hasHeight ? height! : double.infinity,
                  maxWidth: hasWidth ? width! : double.infinity,
                )
              : null,
          decoration: BoxDecoration(
            color: AppColors.descriptionColor,
            borderRadius: borderRadius ?? BorderRadius.circular(radius ?? 8.r),
          ),
          child: Icon(
            Icons.broken_image,
            color: AppColors.lightSecGreyText,
            size: (hasHeight ? height! : 50) / 2,
          ),
        ),
        imageUrl: serverImage == true && url?.contains('http') != true
            ? AppUrls.imageLink(url ?? '')
            : (url ?? ''),
        imageBuilder: (context, imageProvider) {
          return Container(
            width: hasWidth ? width : null,
            height: hasHeight ? height : null,
            constraints: (!hasHeight || !hasWidth)
                ? BoxConstraints(
                    maxHeight: hasHeight ? height! : double.infinity,
                    maxWidth: hasWidth ? width! : double.infinity,
                  )
                : null,
            decoration: BoxDecoration(
              color: AppColors.imageBgColor,
              borderRadius:
                  borderRadius ?? BorderRadius.circular(radius ?? 8.r),
              image: DecorationImage(
                image: imageProvider,
                fit: fit ?? BoxFit.cover,
              ),
            ),
          );
        },
        memCacheHeight: height != null && height!.isFinite
            ? height!.toInt()
            : null,
        memCacheWidth: width != null && width!.isFinite ? width!.toInt() : null,
        maxHeightDiskCache: height != null && height!.isFinite
            ? (height! * 2).toInt()
            : null,
        maxWidthDiskCache: width != null && width!.isFinite
            ? (width! * 2).toInt()
            : null,
      ),
    );
  }
}
