import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class JobItemData {
  final String id;
  final String title;
  final String company;
  final String date;
  final String imageUrl;

  const JobItemData({
    required this.id,
    required this.title,
    required this.company,
    required this.date,
    required this.imageUrl,
  });
}

class CommunityJobCard extends StatelessWidget {
  final JobItemData data;
  final Color orange;
  final Color pillColor;
  final bool isMine;
  final bool applied;
  final bool isLoading;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onApply;

  const CommunityJobCard({
    super.key,
    required this.data,
    required this.orange,
    required this.pillColor,
    required this.isMine,
    this.applied = false,
    this.isLoading = false,
    this.onDelete,
    this.onEdit,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: _buildImage(),
          ),
          12.horizontalSpace,
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      4.verticalSpace,
                      Text(
                        data.company,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                8.horizontalSpace,
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      data.date,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    6.verticalSpace,
                    isMine
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 32.w,
                                height: 32.w,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  iconSize: 18.sp,
                                  onPressed: onEdit,
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: orange,
                                  ),
                                ),
                              ),
                              8.horizontalSpace,
                              Container(
                                width: 32.w,
                                height: 32.w,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  iconSize: 18.sp,
                                  onPressed: onDelete,
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : applied
                        ? Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: Colors.green.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14.sp,
                                  color: Colors.green.shade700,
                                ),
                                4.horizontalSpace,
                                Text(
                                  'Applied',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 90.w),
                            child: InkWell(
                              onTap: isLoading ? null : onApply,
                              borderRadius: BorderRadius.circular(16.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: pillColor,
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        width: 50.w,
                                        height: 14.h,
                                        child: Center(
                                          child: SizedBox(
                                            width: 12.w,
                                            height: 12.w,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    orange,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'apply'.tr(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.w600,
                                          color: orange,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (data.imageUrl.isEmpty) {
      return Container(width: 54.w, height: 54.w, color: Colors.grey.shade300);
    }

    return Image.network(
      data.imageUrl,
      width: 54.w,
      height: 54.w,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 54.w,
          height: 54.w,
          color: Colors.grey.shade300,
          child: const Icon(Icons.broken_image, size: 20, color: Colors.grey),
        );
      },
    );
  }
}

class CommunityJobCardShimmer extends StatelessWidget {
  final Color pillColor;

  const CommunityJobCardShimmer({super.key, required this.pillColor});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 54.w,
              height: 54.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.grey.shade300,
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 12.h,
                          width: 120.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            color: Colors.grey.shade300,
                          ),
                        ),
                        6.verticalSpace,
                        Container(
                          height: 10.h,
                          width: 80.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  8.horizontalSpace,
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 10.h,
                          width: 70.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            color: Colors.grey.shade300,
                          ),
                        ),
                        6.verticalSpace,
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: pillColor,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: SizedBox(height: 10.h, width: 40.w),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
