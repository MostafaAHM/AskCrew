import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/profile_header/profile_header_widget.dart';
import 'package:aflam/core/widgets/shimmer/custom_shimmer_widget.dart';
import 'package:aflam/features/viewer/home_viewer/presentation/widgets/home_top_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/home_student_cubit.dart';
import '../cubit/home_student_state.dart';
import 'student_scrollable_content.dart';
import 'student_stats_section.dart';
import '../../../../../core/helpers/user_helper.dart';

class HomeStudentBody extends StatelessWidget {
  const HomeStudentBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeStudentCubit, HomeStudentState>(
      builder: (context, state) {
        // Don't show loading - load data in background for better UX
        // Show shimmer skeleton while loading
        if (state is HomeStudentLoading || state is HomeStudentInitial) {
          return _buildShimmerSkeleton(context);
        }

        if (state is HomeStudentError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                ElevatedButton(
                  onPressed: () =>
                      context.read<HomeStudentCubit>().refreshData(),
                  child: Text('common_retry'.tr()),
                ),
              ],
            ),
          );
        }

        if (state is HomeStudentLoaded) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Fixed Header Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      30.verticalSpace,
                      const HomeTopBar(showChat: true),
                      16.height,
                      Container(
                        padding: EdgeInsets.all(16.w),
                        child: ValueListenableBuilder(
                          valueListenable: UserHelper.userNotifier,
                          builder: (context, user, _) {
                            return ProfileHeaderWidget(
                              name: state.profile.name,
                              profession: state.profile.profession,
                              profileImage: state.profile.profileImage,
                              isVerified: state.profile.waterMark,
                              rating: state.profile.rating,
                              reviewsCount: state.profile.reviewsCount,
                              isAvailable:
                                  user?.profile?.isAvailable ??
                                  state.profile.isAvailable,
                              images: state.profile.images,
                            );
                          },
                        ),
                      ),
                      16.height,
                      StudentStatsSection(
                        views: state.profile.views,
                        jobApplicationsCount:
                            state.profile.jobApplicationsCount,
                        approvedJobApplicationsCount:
                            state.profile.approvedJobApplicationsCount,
                      ),
                      16.height,
                    ],
                  ),
                ),
                // Content Section
                const StudentScrollableContent(),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildShimmerSkeleton(BuildContext context) {
    return Column(
      children: [
        // Fixed Header Section with Shimmer
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              30.verticalSpace,
              const HomeTopBar(showChat: true),
              16.height,
              // Profile Header Shimmer
              Container(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Profile Image Shimmer
                        CustomShimmerWidget(
                          width: 60.r,
                          height: 60.r,
                          shape: BoxShape.circle,
                        ),
                        12.width,
                        // Name and Profession Shimmer
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomShimmerWidget(
                                width: double.infinity,
                                height: 20.h,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              8.height,
                              CustomShimmerWidget(
                                width: 150.w,
                                height: 16.h,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    16.height,
                    // Rating Shimmer
                    Row(
                      children: [
                        CustomShimmerWidget(
                          width: 100.w,
                          height: 20.h,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              16.height,
              // Stats Section Shimmer
              Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 8.w : 0),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          CustomShimmerWidget(
                            width: double.infinity,
                            height: 16.h,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          8.height,
                          CustomShimmerWidget(
                            width: 40.w,
                            height: 20.h,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              16.height,
            ],
          ),
        ),
        // Scrollable Content Shimmer
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Title Shimmer
                CustomShimmerWidget(
                  width: 120.w,
                  height: 20.h,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                12.height,
                // Horizontal List Shimmer
                SizedBox(
                  height: 150.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => 12.width,
                    itemBuilder: (_, __) => CustomShimmerWidget(
                      width: 105.w,
                      height: 150.h,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                24.height,
                // Another Section
                CustomShimmerWidget(
                  width: 120.w,
                  height: 20.h,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                12.height,
                SizedBox(
                  height: 150.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => 12.width,
                    itemBuilder: (_, __) => CustomShimmerWidget(
                      width: 105.w,
                      height: 150.h,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
