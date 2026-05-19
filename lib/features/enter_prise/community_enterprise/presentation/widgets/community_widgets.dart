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
  final Color orange;
  final BorderRadius borderRadius;

  const AskQuestionFab({
    super.key,
    required this.orange,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 120.h, right: 12.w),
      child: Material(
        color: orange,
        elevation: 5,
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
  final Color orange;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  const PostJobFab({
    super.key,
    required this.orange,
    required this.borderRadius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 120.h, right: 12.w),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Image.asset(AppIcons.addCommunity, width: 60.w, height: 60.h),
      ),
    );
  }
}

class CommunityQuestionCard extends StatelessWidget {
  final QuestionItemData data;
  final Color orange;
  final int? currentUserId;
  final int questionAuthorId;
  final ValueChanged<int>? onTapReplies;
  final ValueChanged<int>? onEdit;
  final ValueChanged<int>? onDelete;

  const CommunityQuestionCard({
    super.key,
    required this.data,
    required this.orange,
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
        color: const Color(0xFFF9F7F2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE8E5DE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: Image.network(
                    data.avatarUrl,
                    width: 30.w,
                    height: 30.w,
                    fit: BoxFit.cover,
                  ),
                ),
                8.horizontalSpace,
                Text(
                  data.userName,
                  style: FontStyles.body14W700.copyWith(
                    fontSize: 13.sp,
                    color: const Color(0xFF3A3A3A),
                  ),
                ),

                const Spacer(),

                /// ============ NEW! Edit / Delete Menu ============
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
                    icon: const Icon(
                      Icons.more_vert,
                      size: 20,
                      color: Color(0xFF8C8C8C),
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
                                color: const Color(0xFFFFF5F0),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: Color(0xFFFF7A3C),
                              ),
                            ),
                            12.horizontalSpace,
                            Text(
                              'Edit'.tr(),
                              style: FontStyles.body14W500.copyWith(
                                color: const Color(0xFF3A3A3A),
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
                                color: const Color(0xFFFFF0F0),
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
                                color: const Color(0xFF3A3A3A),
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                /// ===================== Replies Button =====================
                InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  onTap: () => onTapReplies?.call(data.id),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 4.h,
                    ),
                    child: Row(
                      children: [
                        SvgImageWidget(
                          image: AppIcons.commentMessage,
                          width: 18.w,
                          height: 18.h,
                        ),
                        4.horizontalSpace,
                        Text(
                          data.repliesCount.toString(),
                          style: FontStyles.body12W400.copyWith(
                            fontSize: 13.sp,
                            color: const Color(0xFF8C8C8C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            8.verticalSpace,

            const Divider(height: 1, thickness: 0.8, color: Color(0xFFEAEAEA)),

            8.verticalSpace,

            Text(
              data.text,
              style: FontStyles.body14W500.copyWith(
                fontSize: 13.sp,
                color: const Color(0xFF727272),
                height: 1.4,
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
