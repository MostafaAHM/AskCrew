import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/app_config/app_urls.dart';
import 'package:aflam/core/app_config/font_styles.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/helpers/shared_pref_local_storage.dart';
import 'package:aflam/core/helpers/user_helper.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/jops/response/jop_item_model.dart';
import '../cubit/jops/cubit/get_all_jops_cubit.dart';
import '../widgets/applied_talent_item.dart';

class JobDetailsScreen extends StatefulWidget {
  final JobItemModel job;
  final VoidCallback onBack;
  final bool isMine;

  const JobDetailsScreen({
    super.key,
    required this.job,
    required this.onBack,
    this.isMine = false,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final Map<int, int> _ratings = {};
  final Map<int, bool> _hasRated = {};
  int? _currentRatingUserId;
  bool _isApplicationAccepted = false;
  bool _hasApplied = false;
  String? _applicationStatus;

  String _getRatingKey(int userId) {
    return 'job_rating_${widget.job.id}_$userId';
  }

  void _checkRatingStatus(int userId) {
    final ratingKey = _getRatingKey(userId);
    final hasRated = SharedPref.sharedPreferences.getBool(ratingKey) ?? false;
    if (hasRated) {
      _hasRated[userId] = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _hasApplied = widget.job.applied;
    if (_hasApplied) {
      _applicationStatus = 'pending';
    }

    if (widget.isMine) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<GetAllJopsCubit>().getJobApplications(
          jobId: widget.job.id,
        );
      });
    } else {
      if (_hasApplied) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<GetAllJopsCubit>().getJobApplications(
            jobId: widget.job.id,
          );
        });
      }
      final ownerId = widget.job.author;
      if (ownerId > 0) {
        _checkRatingStatus(ownerId);
      }
    }
  }

  TalentStatus? _getTalentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TalentStatus.pending;
      case 'accepted':
        return TalentStatus.accepted;
      case 'rejected':
        return TalentStatus.rejected;
      default:
        return TalentStatus.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = UserHelper.userNotifier.value;
    final isOwner = currentUser != null && widget.job.author == currentUser.id;

    return BlocListener<GetAllJopsCubit, GetAllJopsState>(
      listener: (context, state) {
        if (state is AcceptJobApplicationSuccess) {
          AppMessages.showSuccess(context, 'job_accepted_successfully'.tr());

          context.read<GetAllJopsCubit>().getJobApplications(
            jobId: widget.job.id,
          );
        } else if (state is AcceptJobApplicationFailure) {
          AppMessages.showError(context, state.exception.message);
        } else if (state is RejectJobApplicationSuccess) {
          AppMessages.showSuccess(context, 'job_rejected_successfully'.tr());

          context.read<GetAllJopsCubit>().getJobApplications(
            jobId: widget.job.id,
          );
        } else if (state is RejectJobApplicationFailure) {
          AppMessages.showError(context, state.exception.message);
        } else if (state is ApplyToJobSuccess) {
          AppMessages.showSuccess(context, 'job_applied_successfully'.tr());
          setState(() {
            _hasApplied = true;
            _applicationStatus = 'pending';
          });
          if (!isOwner) {
            context.read<GetAllJopsCubit>().getJobApplications(
              jobId: widget.job.id,
            );
          }
        } else if (state is ApplyToJobFailure) {
          AppMessages.showError(context, state.exception.message);
        } else if (state is GetJobApplicationsSuccess) {
          if (!isOwner && currentUser != null) {
            final userApplications = state.applicationsResponse.results
                .where((app) => app.applicant == currentUser.id)
                .toList();

            final hasApplied = userApplications.isNotEmpty;

            if (hasApplied) {
              final latestApplication = userApplications.first;
              final status = latestApplication.status.toLowerCase();

              setState(() {
                _hasApplied = true;
                _applicationStatus = status;

                final acceptedApplication = userApplications
                    .where((app) => app.status.toLowerCase() == 'accepted')
                    .firstOrNull;

                _isApplicationAccepted = acceptedApplication != null;
              });
            }
          }
        } else if (state is RateUserSuccess) {
          AppMessages.hideLoading(context);
          AppMessages.showSuccess(context, state.message);
          if (_currentRatingUserId != null) {
            final ratingKey = _getRatingKey(_currentRatingUserId!);
            SharedPref.sharedPreferences.setBool(ratingKey, true);
            setState(() {
              _hasRated[_currentRatingUserId!] = true;
              _ratings[_currentRatingUserId!] = 0;
              _currentRatingUserId = null;
              _isApplicationAccepted = false;
            });
          }
        } else if (state is RateUserFailure) {
          AppMessages.hideLoading(context);
          AppMessages.showError(context, state.exception.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightBGColor,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child:
                              widget.job.image != null &&
                                  widget.job.image!.isNotEmpty
                              ? CustomCachedNetworkImage(
                                  url: widget.job.image!,
                                  width: 60.w,
                                  height: 60.w,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 60.w,
                                  height: 60.w,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: const Icon(
                                    Icons.business,
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        12.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.job.companyName,
                                style: FontStyles.body14W700.copyWith(
                                  fontSize: 23.sp,
                                  color: Colors.black87,
                                ),
                              ),
                              4.verticalSpace,
                              Text(
                                'jobs_company_studio_label'.tr(),
                                style: FontStyles.body12W400.copyWith(
                                  fontSize: 19.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    16.verticalSpace,

                    // Job Title
                    Text(
                      '${'jobs_job_title_label'.tr()} : ${widget.job.jobTitle}',
                      style: FontStyles.body14W700.copyWith(
                        fontSize: 23.sp,
                        color: Colors.black87,
                      ),
                    ),

                    // Job Description
                    Container(
                      width: double.infinity,
                      // padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F7F2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        widget.job.about,
                        style: FontStyles.body14W500.copyWith(
                          fontSize: 15.sp,
                          color: const Color(0xFF727272),
                          height: 1.5,
                        ),
                      ),
                    ),

                    if (widget.isMine) ...[
                      16.verticalSpace,
                      Text(
                        'Applied Talents', // TODO: Add translation key
                        style: FontStyles.body14W700.copyWith(
                          fontSize: 21.sp,
                          color: Colors.black87,
                        ),
                      ),
                      12.verticalSpace,
                      BlocBuilder<GetAllJopsCubit, GetAllJopsState>(
                        builder: (context, state) {
                          if (state is GetJobApplicationsLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is GetJobApplicationsSuccess) {
                            final applications =
                                state.applicationsResponse.results;

                            if (applications.isEmpty) {
                              return Center(
                                child: Text(
                                  'No applications yet',
                                  style: FontStyles.headline16.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: applications.map((application) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: AppliedTalentItem(
                                    applicationId: application.id,
                                    applicantId: application.applicant,
                                    name: application.applicantName,
                                    role: application.jobTitle,
                                    imageUrl: application.applicantImage ?? '',
                                    initialStatus: _getTalentStatus(
                                      application.status,
                                    ),
                                    onAccept: () {
                                      context
                                          .read<GetAllJopsCubit>()
                                          .acceptJobApplication(
                                            applicationId: application.id,
                                          );
                                    },
                                    onReject: () {
                                      context
                                          .read<GetAllJopsCubit>()
                                          .rejectJobApplication(
                                            applicationId: application.id,
                                          );
                                    },
                                  ),
                                );
                              }).toList(),
                            );
                          } else if (state is GetJobApplicationsFailure) {
                            return Center(
                              child: Text(
                                state.exception.message,
                                style: FontStyles.headline16.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                      40.verticalSpace,
                    ],

                    if (!widget.isMine &&
                        _hasApplied &&
                        _isApplicationAccepted) ...[
                      16.verticalSpace,
                      _buildRatingSection(),
                      16.verticalSpace,
                    ],

                    // Apply button inside scrollable content
                    if (!widget.isMine &&
                        _applicationStatus != 'accepted' &&
                        _applicationStatus != 'rejected') ...[
                      16.verticalSpace,
                      BlocBuilder<GetAllJopsCubit, GetAllJopsState>(
                        builder: (context, state) {
                          final isLoading = state is ApplyToJobLoading;
                          final isPending =
                              _applicationStatus == 'pending' || _hasApplied;

                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 0.w,
                              vertical: 16.h,
                            ),
                            child: CustomButton(
                              text: isPending ? 'pending'.tr() : 'apply'.tr(),
                              onTap: (isLoading || isPending)
                                  ? null
                                  : () {
                                      context
                                          .read<GetAllJopsCubit>()
                                          .applyToJob(jobId: widget.job.id);
                                    },
                              isBackgroundGradient: !isPending,
                              backgroundColor: isPending ? Colors.grey : null,
                              widget: isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                      100.verticalSpace, // Extra space at bottom to ensure button is visible above navigation bar
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    final ownerId = widget.job.author;
    if (ownerId == 0) {
      return const SizedBox.shrink();
    }

    _checkRatingStatus(ownerId);
    final canRateOwner = !(_hasRated[ownerId] ?? false);

    if (!canRateOwner) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: _buildRatingCard(
        userId: ownerId,
        userName: widget.job.authorName,
        userPhoto: null,
        onRatingSubmitted: (rating) {
          setState(() {
            _currentRatingUserId = ownerId;
          });
          AppMessages.showLoading(context);
          context.read<GetAllJopsCubit>().rateUser(
            toUserId: ownerId,
            rating: rating,
          );
        },
      ),
    );
  }

  Widget _buildRatingCard({
    required int userId,
    required String userName,
    String? userPhoto,
    required Function(int) onRatingSubmitted,
  }) {
    int selectedRating = _ratings[userId] ?? 0;
    final double averageRating = 4.2;
    final int reviewsCount = 20;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: userPhoto != null && userPhoto.isNotEmpty
                    ? CachedNetworkImageProvider(
                        userPhoto.startsWith('http')
                            ? userPhoto
                            : AppUrls.imageLink(userPhoto),
                      )
                    : null,
                child: userPhoto == null || userPhoto.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 30.sp,
                        color: Colors.grey.shade400,
                      )
                    : null,
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff1A0A00),
                      ),
                    ),
                    4.verticalSpace,
                    Text(
                      widget.job.authorSpecification.isNotEmpty
                          ? widget.job.authorSpecification
                          : 'Actor',
                      style: TextStyle(
                        fontSize: 19.sp,
                        color: const Color(0xff7A7A7A),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final rating = index + 1;
                      if (rating <= averageRating.floor()) {
                        return Icon(
                          Icons.star,
                          color: const Color(0xFFFF7A00),
                          size: 16.sp,
                        );
                      } else if (rating == averageRating.ceil() &&
                          averageRating % 1 != 0) {
                        return Icon(
                          Icons.star_half,
                          color: const Color(0xFFFF7A00),
                          size: 16.sp,
                        );
                      } else {
                        return Icon(
                          Icons.star_border,
                          color: Colors.grey.shade400,
                          size: 16.sp,
                        );
                      }
                    }),
                  ),
                  4.verticalSpace,
                  Text(
                    '($reviewsCount reviews)',
                    style: TextStyle(
                      fontSize: 17.sp,
                      color: const Color(0xff7A7A7A),
                    ),
                  ),
                ],
              ),
            ],
          ),
          16.verticalSpace,
          Text(
            'How would you rate $userName?',
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff1A0A00),
            ),
          ),
          12.verticalSpace,
          Row(
            children: List.generate(5, (index) {
              final rating = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _ratings[userId] = rating;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Icon(
                    rating <= selectedRating ? Icons.star : Icons.star_border,
                    color: rating <= selectedRating
                        ? const Color(0xFFFF7A00)
                        : Colors.grey.shade400,
                    size: 24.sp,
                  ),
                ),
              );
            }),
          ),
          6.verticalSpace,
          Text(
            'Tap a star to rate',
            style: TextStyle(fontSize: 16.sp, color: const Color(0xff7A7A7A)),
          ),
          if (selectedRating > 0) ...[
            // 16.verticalSpace,
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => onRatingSubmitted(selectedRating),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 9.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9B59B6),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(fontSize: 18.sp, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
