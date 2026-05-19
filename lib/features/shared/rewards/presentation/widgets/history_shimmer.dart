import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aflam/core/widgets/shimmer/custom_shimmer_widget.dart';
import 'package:aflam/core/extensions/space_extension.dart';

class HistoryItemShimmer extends StatelessWidget {
  const HistoryItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomShimmerWidget(
                height: 20.h,
                width: 150.w,
                radius: 4.r,
              ),
            ),
            8.horizontalSpace,
            CustomShimmerWidget(height: 14.h, width: 80.w, radius: 4.r),
          ],
        ),
        4.height,
        CustomShimmerWidget(height: 16.h, width: double.infinity, radius: 4.r),
        8.height,
        Container(
          height: 0.8,
          width: double.infinity,
          color: const Color(0xffe5e5e5),
        ),
        12.height,
      ],
    );
  }
}

class HistoryListShimmer extends StatelessWidget {
  const HistoryListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, __) => 8.height,
      itemBuilder: (context, index) => const HistoryItemShimmer(),
    );
  }
}
