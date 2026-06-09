import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/widgets/cached_network_image/custom_cached_network_image.dart';
import '../../../../../../core/helpers/authorization_helper.dart';
import '../../../../../../core/helpers/user_helper.dart';

class ArtworkCard extends StatelessWidget {
  final String title;
  final double rating;
  final int subscribers;
  final String date;
  final String views;
  final String imageUrl;
  final String? price;
  final bool? isReady;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final bool isOwner;

  const ArtworkCard({
    super.key,
    required this.title,
    required this.rating,
    required this.subscribers,
    required this.date,
    required this.views,
    required this.imageUrl,
    this.isOwner = false,
    this.price,
    this.isReady,
    this.onDelete,
    this.onEdit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final purple = const Color(0xFF5F3DC4);
    final textBlack = Colors.black87;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: REdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: imageUrl,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CustomCachedNetworkImage(
                    url: imageUrl,
                    width: 90.w,
                    height: 90.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              10.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    6.height,
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 16.sp, color: AppColors.primaryColor),
                        4.width,
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: textBlack,
                          ),
                        ),
                      ],
                    ),
                    4.height,
                    Row(
                      children: [
                        Icon(Icons.group, size: 14.sp, color: AppColors.primaryColor),
                        4.width,
                        Flexible(
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$subscribers ',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: textBlack,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                TextSpan(
                                  text: 'subscribers'.tr(),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryColor,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if ((price != null && double.tryParse(price!) != 0) ||
                        isReady != null)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Row(
                          children: [
                            if (price != null && double.tryParse(price!) != 0)
                              Flexible(
                                child: Text(
                                  '$price KWD',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            if (price != null && isReady != null) 6.width,
                            if (isReady != null)
                              Flexible(
                                child: Text(
                                  isReady! ? "Ready" : "Processing",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: isReady!
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ValueListenableBuilder(
                    valueListenable: UserHelper.userNotifier,
                    builder: (context, user, _) {
                      if (!AuthorizationHelper.isProducer() || !isOwner) {
                        return SizedBox(height: 24.h);
                      }
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: onDelete,
                            child: Container(
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red.withOpacity(0.1),
                              ),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 22.sp,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          8.width,
                          InkWell(
                            onTap: onEdit,
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 22.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const Spacer(),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: purple,
                    ),
                  ),
                  6.height,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 16.sp,
                        color: AppColors.primaryColor,
                      ),
                      4.width,
                      Text(
                        views,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
