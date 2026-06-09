import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/widgets/svg_image/svg_image_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/app_config/app_icons.dart';
import '../../../../../core/enums/jobs_filter.dart';
import '../cubit/jops/cubit/get_all_jops_cubit.dart';
import '../widgets/community_job_card.dart';
import 'job_details_screen.dart';
import 'post_job_screen.dart';
import '../../data/model/jops/response/jop_item_model.dart';

class CommunityJobsTab extends StatefulWidget {
  final Color lightPill;
  final bool isAddingJob;
  final bool isStudent;
  final JobsFilter selectedFilter;
  final dynamic selectedJob;
  final ValueChanged<dynamic> onJobSelected;
  final ValueChanged<JobsFilter> onFilterChanged;
  final VoidCallback onJobCreated;
  final JobItemModel? jobToEdit;
  final ValueChanged<JobItemModel>? onEditJob;

  const CommunityJobsTab({
    super.key,
    required this.lightPill,
    required this.isAddingJob,
    required this.isStudent,
    required this.selectedFilter,
    required this.selectedJob,
    required this.onJobSelected,
    required this.onFilterChanged,
    required this.onJobCreated,
    this.jobToEdit,
    this.onEditJob,
  });

  @override
  State<CommunityJobsTab> createState() => _CommunityJobsTabState();
}

class _CommunityJobsTabState extends State<CommunityJobsTab> {
  List<dynamic> _jobs = [];

  @override
  void didUpdateWidget(CommunityJobsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedFilter != oldWidget.selectedFilter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onJobSelected(null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<GetAllJopsCubit>()
            ..getAllJops(filter: jobsFilterApiValue(widget.selectedFilter)),
      child: BlocConsumer<GetAllJopsCubit, GetAllJopsState>(
        listener: (context, state) {
          if (state is GetAllJopsSuccess) {
            _jobs = List.from(state.jobsResponseModel.results);
            setState(() {});
          } else if (state is ApplyToJobSuccess) {
            AppMessages.showSuccess(context, 'job_applied_successfully'.tr());
            // Refresh jobs list after successful application
            context.read<GetAllJopsCubit>().getAllJops(
              filter: jobsFilterApiValue(widget.selectedFilter),
            );
          } else if (state is ApplyToJobFailure) {
            AppMessages.showError(context, 'job_application_failed'.tr());
          } else if (state is DeleteJobSuccess) {
            AppMessages.showSuccess(context, 'job_deleted_successfully'.tr());
          } else if (state is DeleteJobFailure) {
            AppMessages.showError(context, 'job_deletion_failed'.tr());
          }
        },
        builder: (context, state) {
          if (widget.isAddingJob) {
            return PostJobScreen(
              key: const ValueKey('post_job_screen'),
              jobToEdit: widget.jobToEdit,
              onBack: widget.onJobCreated,
              onJobCreated: () {
                widget.onJobCreated();
                context.read<GetAllJopsCubit>().getAllJops(
                  filter: jobsFilterApiValue(widget.selectedFilter),
                );
              },
            );
          }

          Widget content = Column(
            children: [
              if (widget.selectedJob == null && !widget.isStudent)
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h, left: 4.w, right: 4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        jobsFilterLabel(widget.selectedFilter),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      InkWell(
                        onTap: () => _openJobsFilterBottomSheet(context),
                        borderRadius: BorderRadius.circular(16.r),
                        child: Padding(
                          padding: EdgeInsets.all(4.r),
                          child: SvgImageWidget(
                            image: AppIcons.filter,
                            width: 26.w,
                            height: 26.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: widget.selectedJob != null
                    ? JobDetailsScreen(
                        job: widget.selectedJob!,
                        isMine:
                            !widget.isStudent &&
                            widget.selectedFilter == JobsFilter.yourOwn,
                        onBack: () {
                          widget.onJobSelected(null);
                        },
                      )
                    : _buildJobsBody(context, state),
              ),
            ],
          );

          // Add PopScope for students to handle back button
          if (widget.isStudent && widget.selectedJob != null) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) {
                  widget.onJobSelected(null);
                  // Refresh jobs list
                  context.read<GetAllJopsCubit>().getAllJops(
                    filter: jobsFilterApiValue(widget.selectedFilter),
                  );
                }
              },
              child: content,
            );
          }

          return content;
        },
      ),
    );
  }

  Widget _buildJobsBody(BuildContext context, GetAllJopsState state) {
    if (state is GetAllJopsLoading && _jobs.isEmpty) {
      return ListView.separated(
        padding: EdgeInsets.only(bottom: 90.h),
        itemBuilder: (_, __) =>
            CommunityJobCardShimmer(pillColor: widget.lightPill),
        separatorBuilder: (_, __) => 12.verticalSpace,
        itemCount: 6,
      );
    }

    if (state is GetAllJopsFailure && _jobs.isEmpty) {
      return Center(child: Text(state.exception.message));
    }

    if (_jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 70,
              color: Colors.grey.shade300,
            ),
            10.verticalSpace,
            Text(
              'jobs_empty'.tr(),
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: 90.h),
      itemCount: _jobs.length,
      separatorBuilder: (_, __) => 12.verticalSpace,
      itemBuilder: (context, index) {
        final job = _jobs[index];
        final dateString = DateFormat('d MMM yyyy').format(job.createdAt);

        return InkWell(
          onTap: () {
            widget.onJobSelected(job);
          },
          borderRadius: BorderRadius.circular(18.r),
          child: BlocBuilder<GetAllJopsCubit, GetAllJopsState>(
            builder: (cardContext, cardState) {
              final isApplying = cardState is ApplyToJobLoading;

              return CommunityJobCard(
                data: JobItemData(
                  id: job.id.toString(),
                  title: job.jobTitle,
                  company: job.companyName,
                  date: dateString,
                  imageUrl: job.image ?? '',
                ),
                pillColor: widget.lightPill,
                isMine: widget.selectedFilter == JobsFilter.yourOwn,
                applied: job.applied,
                isLoading: isApplying,
                onDelete: widget.selectedFilter == JobsFilter.yourOwn
                    ? () {
                        final jobId = job.id;
                        setState(() {
                          _jobs.removeAt(index);
                        });
                        context.read<GetAllJopsCubit>().deleteJob(jobId: jobId);
                      }
                    : null,
                onEdit: widget.selectedFilter == JobsFilter.yourOwn
                    ? () {
                        widget.onEditJob?.call(job);
                      }
                    : null,
                onApply:
                    widget.isStudent ||
                        widget.selectedFilter == JobsFilter.suggested
                    ? () {
                        cardContext.read<GetAllJopsCubit>().applyToJob(
                          jobId: job.id,
                        );
                      }
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  void _openJobsFilterBottomSheet(BuildContext blocContext) {
    showModalBottomSheet<JobsFilter>(
      context: blocContext,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: _JobsFilterBottomSheet(
            selected: widget.selectedFilter,
            onSelected: (value) {
              Navigator.of(sheetContext).pop();
              widget.onFilterChanged(value);
              blocContext.read<GetAllJopsCubit>().getAllJops(
                filter: jobsFilterApiValue(value),
              );
            },
          ),
        );
      },
    );
  }
}

class _JobsFilterBottomSheet extends StatelessWidget {
  final JobsFilter selected;
  final ValueChanged<JobsFilter> onSelected;

  const _JobsFilterBottomSheet({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          4.verticalSpace,
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          16.verticalSpace,
          Text(
            'jobs_filter_title'.tr(),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          16.verticalSpace,
          ListTile(
            leading: Radio<JobsFilter>(
              value: JobsFilter.yourOwn,
              groupValue: selected,
              activeColor: Colors.deepOrange,
              onChanged: (v) {
                if (v != null) onSelected(v);
              },
            ),
            title: Text(
              'jobs_filter_your_own'.tr(),
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
            ),
            onTap: () => onSelected(JobsFilter.yourOwn),
          ),
          ListTile(
            leading: Radio<JobsFilter>(
              value: JobsFilter.suggested,
              groupValue: selected,
              activeColor: Colors.deepOrange,
              onChanged: (v) {
                if (v != null) onSelected(v);
              },
            ),
            title: Text(
              'jobs_filter_suggested'.tr(),
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
            ),
            onTap: () => onSelected(JobsFilter.suggested),
          ),
          8.verticalSpace,
        ],
      ),
    );
  }
}
