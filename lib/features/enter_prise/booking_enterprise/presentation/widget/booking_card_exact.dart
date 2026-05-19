import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/app_config/app_urls.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aflam/core/helpers/user_helper.dart';
import 'package:aflam/config/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/response/booking_item_response_model.dart';

class BookingCardExact extends StatelessWidget {
  final BookingItemResponseModel item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BookingCardExact({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = UserHelper.userNotifier.value;
    final isOwner =
        currentUser != null &&
        item.createdBy != null &&
        currentUser.id == item.createdBy;

    return InkWell(
      onTap: () {
        context.pushNamed(Routes.bookingDetails, extra: item);
      },
      child: Container(
        height: 86.h,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildImage(),
            10.width,
            Expanded(child: _buildContent()),
            8.width,
            if (isOwner) _buildOwnerActions() else _buildPrice(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: item.image.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: item.image.startsWith('http')
                  ? item.image
                  : AppUrls.imageLink(item.image),
              width: 90.w,
              height: 80.h,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 90.w,
                height: 80.h,
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                width: 90.w,
                height: 80.h,
                color: Colors.grey.shade200,
                child: const Icon(Icons.error),
              ),
            )
          : Container(
              width: 90.w,
              height: 80.h,
              color: Colors.grey.shade200,
              child: const Icon(Icons.image),
            ),
    );
  }

  Widget _buildContent() {
    final dateFormat = DateFormat('d MMM');
    final formattedDate = dateFormat.format(item.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          item.name,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xff1A0A00),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        4.height,
        Text(
          '${AppStrings.availability.tr()} : $formattedDate',
          style: TextStyle(fontSize: 12.sp, color: const Color(0xff7A7A7A)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildOwnerActions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: item.isActive
                ? const Color(0xff2ECC71)
                : const Color(0xffE74C3C),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8.sp, color: Colors.white),
              4.width,
              Text(
                item.isActive ? AppStrings.on.tr() : AppStrings.off.tr(),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onEdit,
              child: Container(
                width: 34.r,
                height: 34.r,
                decoration: const BoxDecoration(
                  color: Color(0xffFF7A00),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, color: Colors.white, size: 18.sp),
              ),
            ),
            8.width,
            InkWell(
              onTap: onDelete,
              child: Container(
                width: 34.r,
                height: 34.r,
                decoration: const BoxDecoration(
                  color: Color(0xffE74C3C),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete, color: Colors.white, size: 18.sp),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrice() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$${item.pricePerDay.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xffFF7A00),
          ),
        ),
      ],
    );
  }
}
