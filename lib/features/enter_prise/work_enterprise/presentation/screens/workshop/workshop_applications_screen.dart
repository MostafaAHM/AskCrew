import 'package:aflam/config/routes/routes.dart';
import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/helpers/shared_pref_local_storage.dart';
import 'package:aflam/core/widgets/shimmer/custom_shimmer_widget.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/presentation/utils/user_model_helper.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/workshop_registration_model.dart';
import 'package:aflam/features/enter_prise/work_enterprise/presentation/cubit/workshop/workshop_cubit.dart';
import 'package:aflam/features/enter_prise/work_enterprise/presentation/cubit/workshop/workshop_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/widgets/appbar/logo_skip_appbar.dart';

class WorkshopApplicationsScreen extends StatefulWidget {
  final int workshopId;

  const WorkshopApplicationsScreen({
    super.key,
    required this.workshopId,
  });

  @override
  State<WorkshopApplicationsScreen> createState() =>
      _WorkshopApplicationsScreenState();
}

class _WorkshopApplicationsScreenState
    extends State<WorkshopApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WorkshopCubit>().getWorkshopRegistrations(widget.workshopId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.backAppBar(
        showLogoInBackAppBar: true,
        title: 'All Applications'.tr(),
      ),
      body: BlocListener<WorkshopCubit, WorkshopState>(
      listener: (context, state) {
        if (state is WorkshopRegistrationActionSuccess) {
          context
              .read<WorkshopCubit>()
              .getWorkshopRegistrations(widget.workshopId);
          AppMessages.showSuccess(context, state.message);
        } else if (state is WorkshopError) {
          AppMessages.showError(context, state.message);
        } else if (state is WorkshopSuccess && state.message.contains('Rating')) {
          AppMessages.hideLoading(context);
          AppMessages.showSuccess(context, state.message);
        }
      },
        child: BlocBuilder<WorkshopCubit, WorkshopState>(
          builder: (context, state) {
            if (state is WorkshopLoading && state is! WorkshopRegistrationsLoaded) {
              return ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: 5,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _buildRatingCardShimmer(),
                ),
              );
            }

            if (state is WorkshopError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.red,
                      ),
                    ),
                    16.height,
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<WorkshopCubit>()
                            .getWorkshopRegistrations(widget.workshopId);
                      },
                      child: Text('Retry'.tr()),
                    ),
                  ],
                ),
              );
            }

            final registrations = state is WorkshopRegistrationsLoaded
                ? state.registrations
                : <WorkshopRegistrationModel>[];

            // Show shimmer if loading or if state is not WorkshopRegistrationsLoaded yet
            if (state is! WorkshopRegistrationsLoaded || registrations.isEmpty) {
              if (state is WorkshopRegistrationsLoaded && registrations.isEmpty) {
                // Actually empty - show message
                return Center(
                  child: Text(
                    'No applications yet'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              }
              // Still loading - show shimmer
              return ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: 5,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _buildRatingCardShimmer(),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: registrations.length,
              itemBuilder: (context, index) {
                final registration = registrations[index];
                return _AppliedTalentRowWidget(
                  registration: registration,
                  workshopId: widget.workshopId,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRatingCardShimmer() {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomShimmerWidget(
                width: 48.w,
                height: 48.w,
                borderRadius: BorderRadius.circular(24.r),
                shape: BoxShape.circle,
              ),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomShimmerWidget(
                      width: 120.w,
                      height: 16.h,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    8.height,
                    CustomShimmerWidget(
                      width: 80.w,
                      height: 14.h,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      CustomShimmerWidget(
                        width: 70.w,
                        height: 14.h,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      4.width,
                      CustomShimmerWidget(
                        width: 20.w,
                        height: 14.h,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ],
                  ),
                  8.height,
                  CustomShimmerWidget(
                    width: 60.w,
                    height: 12.h,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ],
              ),
            ],
          ),
          16.height,
          CustomShimmerWidget(
            width: 150.w,
            height: 14.h,
            borderRadius: BorderRadius.circular(8.r),
          ),
          10.height,
          Row(
            children: List.generate(
              5,
              (index) => Padding(
                padding: EdgeInsets.only(right: 6.w),
                child: CustomShimmerWidget(
                  width: 24.w,
                  height: 24.h,
                  borderRadius: BorderRadius.circular(12.r),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          6.height,
          Center(
            child: CustomShimmerWidget(
              width: 100.w,
              height: 12.h,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          14.height,
          Align(
            alignment: Alignment.centerRight,
            child: CustomShimmerWidget(
              width: 80.w,
              height: 32.h,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppliedTalentRowWidget extends StatefulWidget {
  final WorkshopRegistrationModel registration;
  final int workshopId;

  const _AppliedTalentRowWidget({
    required this.registration,
    required this.workshopId,
  });

  @override
  State<_AppliedTalentRowWidget> createState() => _AppliedTalentRowWidgetState();
}

class _AppliedTalentRowWidgetState extends State<_AppliedTalentRowWidget> {
  final _purple = AppColors.barColor;
  final _orange = AppColors.secondaryColor;
  int _userRating = 0;
  bool _isRatingSubmitted = false;

  bool get _isPending => widget.registration.status == 'pending';
  bool get _isApproved => widget.registration.status == 'approved';
  bool get _isRejected => widget.registration.status == 'rejected';

  String get _ratingKey => 'workshop_rating_${widget.workshopId}_${widget.registration.user}';

  @override
  void initState() {
    super.initState();
    _checkRatingStatus();
  }

  void _checkRatingStatus() {
    final ratingStatus = SharedPref.sharedPreferences.getBool(_ratingKey);
    if (ratingStatus == true) {
      setState(() {
        _isRatingSubmitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkshopCubit, WorkshopState>(
      listener: (context, state) {
        if (state is WorkshopSuccess && state.message.contains('Rating')) {
          AppMessages.hideLoading(context);
          AppMessages.showSuccess(context, state.message);
          _handleRatingSuccess();
        } else if (state is WorkshopError) {
          AppMessages.hideLoading(context);
          AppMessages.showError(context, state.message);
        }
      },
      child: _isApproved ? _buildRatingCard() : _buildPendingCard(),
    );
  }

  Widget _buildPendingCard() {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: _buildUserInfoRow(),
    );
  }

  Widget _buildRatingCard() {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(size: 48.w),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.registration.userFullname,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    2.height,
                    Text(
                      'Actor'.tr(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Row(
                        children: List.generate(
                          4,
                          (index) => Padding(
                            padding: EdgeInsets.only(right: 2.w),
                            child: Icon(
                              Icons.star,
                              size: 14.sp,
                              color: _orange,
                            ),
                          ),
                        )
                          ..add(
                            Icon(
                              Icons.star_border,
                              size: 14.sp,
                              color: _orange,
                            ),
                          ),
                      ),
                      4.width,
                      Text(
                        '4.2',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: _orange,
                        ),
                      ),
                    ],
                  ),
                  2.height,
                  Text(
                    '(20 reviews)'.tr(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!_isRatingSubmitted) ...[
            16.height,
            Text(
              'How would you rate ${widget.registration.userFullname.split(' ').first}?'.tr(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            10.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(
                5,
                (index) => Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: GestureDetector(
                    onTap: () => _handleStarTap(index + 1),
                    child: Icon(
                      index < _userRating ? Icons.star_border_rounded : Icons.star_border_rounded,
                      size: 24.sp,
                      color: index < _userRating ? _orange : Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),
            6.height,
            Center(
              child: Text(
                'Tap a star to rate'.tr(),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[500],
                ),
              ),
            ),
            14.height,
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 32.h,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    backgroundColor: _purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  onPressed: _userRating > 0 ? _submitRating : null,
                  child: Text(
                    'Submit'.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserInfoRow() {
    return Row(
      children: [
        _buildAvatar(),
        10.width,
        Expanded(child: _buildUserDetails()),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildAvatar({double? size}) {
    final avatarSize = size ?? 40.w;
    return GestureDetector(
      onTap: () {
        final userModel = UserModelHelper.createFromPartialData(
          id: widget.registration.user,
          fullname: widget.registration.userFullname,
          email: widget.registration.userEmail,
          profilePhoto: null,
          specification: 'Actor',
        );
        context.pushNamed(
          Routes.userProfile,
          extra: userModel,
        );
      },
      child: Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=200',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.person,
              size: avatarSize * 0.5,
              color: Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.registration.userFullname,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        2.height,
        Text(
          widget.registration.userEmail,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_isPending) {
      return Row(
        children: [
          _buildActionButton(
            label: 'accept'.tr(),
            color: _orange,
            onTap: () {
              context.read<WorkshopCubit>().approveWorkshopRegistration(widget.registration.id);
            },
          ),
          6.width,
          _buildActionButton(
            label: 'reject'.tr(),
            color: _purple,
            onTap: () {
              context.read<WorkshopCubit>().rejectWorkshopRegistration(widget.registration.id);
            },
          ),
        ],
      );
    } else if (_isRejected) {
      return _buildStatusBadge('Rejected'.tr(), Colors.red);
    } else if (_isApproved && !_isRatingSubmitted) {
      return _buildStatusBadge('Approved'.tr(), Colors.green);
    }
    return const SizedBox.shrink();
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 4.h,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  void _handleStarTap(int rating) {
    setState(() {
      _userRating = rating;
    });
  }

  void _submitRating() {
    if (_userRating > 0) {
      AppMessages.showLoading(context);
      context.read<WorkshopCubit>().rateUser(
        toUserId: widget.registration.user,
        rating: _userRating,
      );
    }
  }

  void _handleRatingSuccess() {
    // Save rating status to local storage only on success
    SharedPref.sharedPreferences.setBool(_ratingKey, true);
    setState(() {
      _isRatingSubmitted = true;
    });
  }
}

