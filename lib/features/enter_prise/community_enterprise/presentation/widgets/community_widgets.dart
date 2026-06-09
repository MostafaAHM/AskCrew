import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/app_config/app_icons.dart';
import 'package:aflam/core/app_config/font_styles.dart';
import 'package:aflam/core/widgets/svg_image/svg_image_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../cubit/questions/cubit/questions_cubit.dart';
import 'ask_question_bottom_sheet.dart';

class QuestionItemData {
  final int id;
  final String userName;
  final String avatarUrl;
  final int repliesCount;
  final String text;

  QuestionItemData({
    required this.id,
    required this.userName,
    required this.avatarUrl,
    required this.repliesCount,
    required this.text,
  });
}

class AskQuestionFab extends StatelessWidget {
  final BorderRadius borderRadius;

  const AskQuestionFab({super.key, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () {
            final cubit = context.read<QuestionsCubit>();
            showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (sheetContext) {
                return BlocProvider.value(
                  value: cubit,
                  child: const AskQuestionBottomSheet(),
                );
              },
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            child: Text(
              'ask_new_question'.tr(),
              style: FontStyles.headline16.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class PostJobFab extends StatelessWidget {
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  const PostJobFab({
    super.key,
    required this.borderRadius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            child: Text(
              'add_job'.tr(),
              style: FontStyles.headline16.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class CommunityQuestionCard extends StatelessWidget {
  final QuestionItemData data;
  final int? currentUserId;
  final int questionAuthorId;
  final ValueChanged<int>? onTapReplies;
  final ValueChanged<int>? onEdit;
  final ValueChanged<int>? onDelete;

  const CommunityQuestionCard({
    super.key,
    required this.data,
    this.currentUserId,
    required this.questionAuthorId,
    this.onTapReplies,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.network(
                      data.avatarUrl,
                      width: 40.w,
                      height: 40.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                10.horizontalSpace,
                Expanded(
                  child: Text(
                    data.userName,
                    style: FontStyles.body14W700.copyWith(
                      fontSize: 15.sp,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                if (currentUserId != null && currentUserId == questionAuthorId)
                  PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit?.call(data.id);
                      } else if (value == 'delete') {
                        onDelete?.call(data.id);
                      }
                    },
                    icon: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppColors.lightBGColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        size: 18.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 28.w,
                              height: 28.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            12.horizontalSpace,
                            Text(
                              'Edit'.tr(),
                              style: FontStyles.body14W500.copyWith(
                                color: const Color(0xFF2D2D2D),
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 28.w,
                              height: 28.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: Colors.redAccent,
                              ),
                            ),
                            12.horizontalSpace,
                            Text(
                              'Delete'.tr(),
                              style: FontStyles.body14W500.copyWith(
                                color: const Color(0xFF2D2D2D),
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                InkWell(
                  borderRadius: BorderRadius.circular(16.r),
                  onTap: () => onTapReplies?.call(data.id),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        SvgImageWidget(
                          image: AppIcons.commentMessage,
                          width: 16.w,
                          height: 16.h,
                          // color: AppColors.primaryColor,
                        ),
                        4.horizontalSpace,
                        Text(
                          data.repliesCount.toString(),
                          style: FontStyles.body12W400.copyWith(
                            fontSize: 13.sp,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            12.verticalSpace,
            Text(
              data.text,
              style: FontStyles.body14W500.copyWith(
                fontSize: 14.sp,
                color: const Color(0xFF616161),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityQuestionCardShimmer extends StatelessWidget {
  const CommunityQuestionCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightBGColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  8.horizontalSpace,
                  Container(
                    height: 10.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 10.h,
                    width: 16.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
              10.verticalSpace,
              Container(
                height: 10.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Colors.grey.shade300,
                ),
              ),
              6.verticalSpace,
              Container(
                height: 10.h,
                width: MediaQuery.of(context).size.width * 0.6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
