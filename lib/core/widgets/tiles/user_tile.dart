import 'package:aflam/core/extensions/numbers_extension.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/app_strings.dart';
import '../cached_network_image/custom_cached_network_image.dart';

class UserTile extends StatelessWidget {
  final String name;
  final String id;
  final String? email, image;
  final int? numberOfAds, totalRates;
  final num? rate;
  final Widget? trailing;
  final bool? fromAccountProfile;
  final Function()? onReturn;

  const UserTile({
    super.key,
    required this.name,
    required this.id,
    this.image,
    this.fromAccountProfile,
    this.email,
    this.numberOfAds,
    this.totalRates,
    this.rate,
    this.trailing,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomCachedNetworkImage(
            serverImage: true,
            url: image ?? '',
            radius: 32.r,
            width: 50.w,
            height: 50.h,
          ),
          8.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    6.width,
                    if (totalRates != null || rate != null) ...[
                      Icon(
                        Icons.star_rounded,
                        size: 14.sp,
                        color: AppColors.yellowColor,
                      ),
                      3.width,
                      Text(
                        rate?.toArabic ?? '0',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(fontSize: 14.sp),
                      ),
                      6.width,
                      Text(
                        '(${AppStrings.rating.tr()} ${totalRates?.toArabic ?? '0'})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
                if (email != null || numberOfAds != null)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      email ??
                          "${AppStrings.numberOfPublishedAds.tr()} (${numberOfAds?.toArabic})",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 10.sp),
                    ),
                  ),
              ],
            ),
          ),
          8.width,
          trailing ?? Icon(Icons.arrow_forward_ios, size: 16.sp),
        ],
      ),
    );
  }
}
