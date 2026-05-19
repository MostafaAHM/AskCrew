import 'package:aflam/config/routes/routes.dart';
import 'package:aflam/core/app_config/font_styles.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/helpers/shared_pref_local_storage.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/presentation/utils/user_model_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../cubit/jops/cubit/get_all_jops_cubit.dart';

enum TalentStatus { pending, accepted, rejected }

class AppliedTalentItem extends StatefulWidget {
  final int applicationId;
  final int applicantId; // User ID of the applicant
  final String name;
  final String role;
  final String imageUrl;
  final double? rating;
  final int? reviewCount;
  final TalentStatus? initialStatus;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const AppliedTalentItem({
    super.key,
    required this.applicationId,
    required this.applicantId,
    required this.name,
    required this.role,
    required this.imageUrl,
    this.rating,
    this.reviewCount,
    this.initialStatus,
    this.onAccept,
    this.onReject,
  });

  @override
  State<AppliedTalentItem> createState() => _AppliedTalentItemState();
}

class _AppliedTalentItemState extends State<AppliedTalentItem> {
  late TalentStatus _status;
  int _userRating = 0;
  bool _isRatingSubmitted = false;
  String get _ratingKey =>
      'job_rating_${widget.applicationId}_${widget.applicantId}';

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? TalentStatus.pending;
    _checkRatingStatus();
  }

  @override
  void didUpdateWidget(AppliedTalentItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStatus != oldWidget.initialStatus) {
      _status = widget.initialStatus ?? TalentStatus.pending;
      _checkRatingStatus();
    }
  }

  void _checkRatingStatus() {
    final currentStatus = widget.initialStatus ?? _status;
    if (currentStatus == TalentStatus.accepted) {
      final ratingStatus = SharedPref.sharedPreferences.getBool(_ratingKey);
      if (ratingStatus == true) {
        setState(() {
          _isRatingSubmitted = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = widget.initialStatus ?? _status;

    return BlocListener<GetAllJopsCubit, GetAllJopsState>(
      listener: (context, state) {
        if (state is RateUserSuccess) {
          AppMessages.hideLoading(context);
          AppMessages.showSuccess(context, state.message);
          _handleRatingSuccess();
        } else if (state is RateUserFailure) {
          AppMessages.hideLoading(context);
          AppMessages.showError(context, state.exception.message);
        } else if (state is AcceptJobApplicationSuccess ||
            state is RejectJobApplicationSuccess) {
          setState(() {
            if (state is AcceptJobApplicationSuccess) {
              _status = TalentStatus.accepted;
            } else if (state is RejectJobApplicationSuccess) {
              _status = TalentStatus.rejected;
            }
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(10.w),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    final userModel = UserModelHelper.createFromPartialData(
                      id: widget.applicantId,
                      fullname: widget.name,
                      email: null,
                      profilePhoto: widget.imageUrl,
                      specification: widget.role,
                    );
                    context.pushNamed(Routes.userProfile, extra: userModel);
                  },
                  child: ClipOval(
                    child: Image.network(
                      widget.imageUrl,
                      width: 48.w,
                      height: 48.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 48.w,
                          height: 48.w,
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.person,
                            color: Colors.grey.shade500,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                12.horizontalSpace,

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.name,
                              style: FontStyles.headline16.copyWith(
                                fontSize: 21.sp,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (currentStatus == TalentStatus.accepted &&
                              widget.rating != null)
                            Padding(
                              padding: EdgeInsets.only(left: 8.w),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 21.sp,
                                  ),
                                  4.horizontalSpace,
                                  Text(
                                    widget.rating.toString(),
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      4.verticalSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.role,
                              style: FontStyles.body12W400.copyWith(
                                fontSize: 19.sp,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (currentStatus == TalentStatus.accepted &&
                              widget.reviewCount != null)
                            Padding(
                              padding: EdgeInsets.only(left: 8.w),
                              child: Text(
                                '(${widget.reviewCount} reviews)',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Colors.grey.shade500,
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

            if (currentStatus == TalentStatus.pending) ...[
              12.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    label: 'accept',
                    color: const Color(0xFFFF5A1F), // Orange
                    onTap: () {
                      widget.onAccept?.call();
                    },
                  ),
                  8.horizontalSpace,
                  _buildActionButton(
                    label: 'reject',
                    color: const Color(0xFF4A148C), // Purple
                    onTap: () {
                      widget.onReject?.call();
                    },
                  ),
                ],
              ),
            ] else if (currentStatus == TalentStatus.accepted &&
                !_isRatingSubmitted) ...[
              12.verticalSpace,
              Text(
                'How would you rate ${widget.name.split(' ').first}?',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              8.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _userRating = index + 1;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Icon(
                        index < _userRating ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                        size: 18.sp,
                      ),
                    ),
                  );
                }),
              ),
              if (_userRating > 0) ...[
                10.verticalSpace,
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomButton(
                    text: 'Submit',
                    onTap: _submitRating,
                    height: 40.h,
                    fontSize: 16.sp,
                    backgroundColor: const Color(0xFF9B59B6),
                    width: 120.w,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _submitRating() {
    if (_userRating > 0) {
      AppMessages.showLoading(context);
      context.read<GetAllJopsCubit>().rateUser(
        toUserId: widget.applicantId,
        rating: _userRating,
      );
    }
  }

  void _handleRatingSuccess() {
    SharedPref.sharedPreferences.setBool(_ratingKey, true);
    setState(() {
      _isRatingSubmitted = true;
      _userRating = 0;
    });
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
