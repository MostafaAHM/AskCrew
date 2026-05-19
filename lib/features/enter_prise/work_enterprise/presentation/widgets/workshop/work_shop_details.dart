import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/app_config/app_urls.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/helpers/shared_pref_local_storage.dart';
import 'package:aflam/core/helpers/user_helper.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/core/widgets/shimmer/custom_shimmer_widget.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/presentation/utils/user_model_helper.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/workshop_registration_model.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/workshop_response_model.dart';
import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:aflam/features/enter_prise/work_enterprise/presentation/cubit/workshop/workshop_cubit.dart';
import 'package:aflam/features/enter_prise/work_enterprise/presentation/cubit/workshop/workshop_state.dart';
import 'package:aflam/config/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

enum WorkShopDetailsMode { ownerManage, ownerRate, userApply }

class WorkShopDetails extends StatefulWidget {
  final int workshopId;
  final VoidCallback onBack;
  final WorkShopDetailsMode mode;
  final bool showAppBar;

  const WorkShopDetails({
    super.key,
    required this.workshopId,
    required this.onBack,
    this.mode = WorkShopDetailsMode.ownerManage,
    this.showAppBar = false,
  });

  @override
  State<WorkShopDetails> createState() => _WorkShopDetailsState();
}

class _WorkShopDetailsState extends State<WorkShopDetails> {
  final Map<int, int> _ratings = {};
  final Map<int, bool> _hasRated = {};
  int? _currentRatingUserId;

  String _getRatingKey(int userId) {
    return 'workshop_rating_${widget.workshopId}_$userId';
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
    context.read<WorkshopCubit>().getWorkshopById(widget.workshopId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkshopCubit, WorkshopState>(
      listener: (context, state) {
        if (state is WorkshopDeleteSuccess) {
          AppMessages.showSuccess(context, state.message);
          widget.onBack();
        } else if (state is WorkshopApplySuccess) {
          AppMessages.showSuccess(context, state.message);
        } else if (state is WorkshopRegistrationActionSuccess) {
          AppMessages.showSuccess(context, state.message);
          final workshop = state.workshop;
          final currentUser = UserHelper.userNotifier.value;
          final isOwner =
              currentUser != null &&
              workshop.createdBy != null &&
              currentUser.id == workshop.createdBy;
          if (isOwner) {
            context.read<WorkshopCubit>().getWorkshopRegistrations(
              widget.workshopId,
            );
          }
        } else if (state is WorkshopDetailsLoaded) {
          final workshop = state.workshop;
          final currentUser = UserHelper.userNotifier.value;
          final isOwner =
              currentUser != null &&
              workshop.createdBy != null &&
              currentUser.id == workshop.createdBy;
          if (isOwner && workshop.applicationsCount > 0) {
            context.read<WorkshopCubit>().getWorkshopRegistrations(
              widget.workshopId,
            );
          }
          if (!isOwner &&
              workshop.createdBy != null &&
              workshop.myRegistration?.status == 'approved') {
            _checkRatingStatus(workshop.createdBy!);
          }
        } else if (state is WorkshopSuccess) {
          AppMessages.hideLoading(context);
          AppMessages.showSuccess(context, state.message);
          if (state.message.contains('Rating')) {
            if (_currentRatingUserId != null) {
              final ratingKey = _getRatingKey(_currentRatingUserId!);
              SharedPref.sharedPreferences.setBool(ratingKey, true);
              setState(() {
                _hasRated[_currentRatingUserId!] = true;
                _ratings[_currentRatingUserId!] = 0;
                _currentRatingUserId = null;
              });
            }
          }
        } else if (state is WorkshopError) {
          AppMessages.hideLoading(context);
          AppMessages.showError(context, state.message);
        }
      },
      child: widget.showAppBar
          ? Scaffold(
              backgroundColor: Colors.white,
              appBar: CustomAppBar.backAppBar(
                showLogoInBackAppBar: true,
                onBackPressed: widget.onBack,
              ),
              body: SafeArea(child: _buildBody()),
            )
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<WorkshopCubit, WorkshopState>(
      builder: (context, state) {
        if (state is WorkshopLoading) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomShimmerWidget(
                  width: double.infinity,
                  height: 150.h,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                10.height,
                CustomShimmerWidget(
                  width: double.infinity,
                  height: 30.h,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                4.height,
                CustomShimmerWidget(
                  width: 200.w,
                  height: 24.h,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                8.height,
                CustomShimmerWidget(
                  width: double.infinity,
                  height: 100.h,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                16.height,
                CustomShimmerWidget(
                  width: double.infinity,
                  height: 120.h,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ],
            ),
          );
        }

        final workshop = state is WorkshopDetailsLoaded
            ? state.workshop
            : state is WorkshopRegistrationsLoaded
            ? state.workshop
            : state is WorkshopApplySuccess
            ? state.workshop
            : state is WorkshopRegistrationActionSuccess
            ? state.workshop
            : state is WorkshopError
            ? state.workshop
            : state is WorkshopSuccess
            ? state.workshop
            : null;

        if (workshop == null) {
          return Center(child: Text('workshopNotFound'.tr()));
        }

        final currentUser = UserHelper.userNotifier.value;
        final isOwner =
            currentUser != null &&
            workshop.createdBy != null &&
            currentUser.id == workshop.createdBy;

        final actualMode = isOwner
            ? (widget.mode == WorkShopDetailsMode.ownerRate
                  ? WorkShopDetailsMode.ownerRate
                  : WorkShopDetailsMode.ownerManage)
            : WorkShopDetailsMode.userApply;

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: 150.h, // Extra padding for navigation bar and button
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(context, workshop, actualMode),
                16.height,
                if (actualMode == WorkShopDetailsMode.ownerManage ||
                    actualMode == WorkShopDetailsMode.ownerRate)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Applied Talents'.tr(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (workshop.applicationsCount > 0)
                        InkWell(
                          onTap: () {
                            context.push(
                              Routes.workshopApplications,
                              extra: workshop.id,
                            );
                          },
                          child: Text(
                            'showAll'.tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.barColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                if (actualMode == WorkShopDetailsMode.ownerManage) ...[
                  8.height,
                  BlocBuilder<WorkshopCubit, WorkshopState>(
                    buildWhen: (previous, current) =>
                        current is WorkshopRegistrationsLoaded ||
                        current is WorkshopDetailsLoaded ||
                        current is WorkshopRegistrationActionSuccess,
                    builder: (context, state) {
                      List<WorkshopRegistrationModel> registrations = [];

                      if (state is WorkshopRegistrationsLoaded) {
                        registrations = state.registrations;
                      } else if (state is WorkshopDetailsLoaded) {
                        // Show empty state while loading
                        registrations = [];
                      }

                      if (registrations.isEmpty &&
                          workshop.applicationsCount == 0) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.h),
                            child: Text(
                              'workshop_no_applications_yet'.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        );
                      }

                      if (registrations.isEmpty &&
                          workshop.applicationsCount > 0) {
                        // Loading state - show shimmer
                        return Column(
                          children: List.generate(
                            workshop.applicationsCount > 5
                                ? 5
                                : workshop.applicationsCount,
                            (index) => Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: CustomShimmerWidget(
                                width: double.infinity,
                                height: 60.h,
                                borderRadius: BorderRadius.circular(100.r),
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          ...registrations
                              .take(3)
                              .map(
                                (registration) => Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: _buildAppliedTalentRow(
                                    context,
                                    registration: registration,
                                  ),
                                ),
                              ),
                        ],
                      );
                    },
                  ),
                ],
                if (actualMode == WorkShopDetailsMode.ownerRate) ...[
                  8.height,
                  _buildRateTalentBlock(workshop),
                ],
                if (actualMode == WorkShopDetailsMode.userApply) ...[
                  if (workshop.myRegistration?.status == 'approved' &&
                      workshop.createdBy != null) ...[
                    24.height,
                    _buildRatingSection(workshop),
                  ],
                  24.height,
                  if (workshop.myRegistration == null ||
                      workshop.myRegistration!.status != 'pending')
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: CustomButton(
                        text: workshop.myRegistration != null
                            ? (workshop.myRegistration!.status == 'approved'
                                  ? 'workshop_application_approved'.tr()
                                  : 'workshop_application_rejected'.tr())
                            : "apply".tr(),
                        onTap: workshop.myRegistration != null
                            ? null
                            : () {
                                context.read<WorkshopCubit>().applyToWorkshop(
                                  workshop.id,
                                );
                              },
                        isBackgroundGradient: true,
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    WorkshopResponseModel workshop,
    WorkShopDetailsMode actualMode,
  ) {
    final purple = AppColors.barColor;
    final orange = AppColors.secondaryColor;

    String formatDate(DateTime date) {
      return DateFormat('dd MMM yyyy').format(date);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCachedNetworkImage(
          url: workshop.coverImage ?? '',
          height: 150.h,
          width: double.infinity,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(12.r),
        ),
        10.height,
        Row(
          children: [
            Expanded(
              child: Text(
                workshop.name,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Text(
              formatDate(workshop.startDate),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        4.height,
        Text(
          workshop.specialization,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: purple,
          ),
        ),
        8.height,
        Text(
          workshop.description,
          style: TextStyle(
            fontSize: 17.sp,
            height: 1.4,
            color: Colors.grey[800],
          ),
        ),
        20.height,
        // Additional info with better styling
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 24.sp, color: orange),
                  12.width,
                  Expanded(
                    child: Text(
                      workshop.location,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              16.height,
              Row(
                children: [
                  Icon(Icons.people_outline, size: 24.sp, color: purple),
                  12.width,
                  Expanded(
                    child: Text(
                      '${workshop.numberOfParticipants} ${'participants'.tr()}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              16.height,
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 24.sp,
                    color: orange,
                  ),
                  12.width,
                  Expanded(
                    child: Text(
                      '${formatDate(workshop.startDate)} - ${formatDate(workshop.endDate)}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              if (workshop.applicationsCount > 0) ...[
                16.height,
                Row(
                  children: [
                    Icon(Icons.how_to_reg_outlined, size: 24.sp, color: purple),
                    12.width,
                    Expanded(
                      child: Text(
                        '${workshop.applicationsCount} ${'applications'.tr()}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        24.height,
        // Show registration status if user has already applied
        if (actualMode == WorkShopDetailsMode.userApply &&
            workshop.myRegistration != null) ...[
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: workshop.myRegistration!.status == 'approved'
                  ? Colors.green.shade50
                  : workshop.myRegistration!.status == 'rejected'
                  ? Colors.red.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: workshop.myRegistration!.status == 'approved'
                    ? Colors.green.shade200
                    : workshop.myRegistration!.status == 'rejected'
                    ? Colors.red.shade200
                    : Colors.orange.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  workshop.myRegistration!.status == 'approved'
                      ? Icons.check_circle_outline
                      : workshop.myRegistration!.status == 'rejected'
                      ? Icons.cancel_outlined
                      : Icons.pending_outlined,
                  color: workshop.myRegistration!.status == 'approved'
                      ? Colors.green
                      : workshop.myRegistration!.status == 'rejected'
                      ? Colors.red
                      : Colors.orange,
                  size: 24.sp,
                ),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'workshop_application_status'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      4.height,
                      Text(
                        workshop.myRegistration!.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: workshop.myRegistration!.status == 'approved'
                              ? Colors.green.shade700
                              : workshop.myRegistration!.status == 'rejected'
                              ? Colors.red.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          16.height,
        ],
      ],
    );
  }

  Widget _buildAppliedTalentRow(
    BuildContext context, {
    required WorkshopRegistrationModel registration,
  }) {
    return _AppliedTalentRowWidget(
      registration: registration,
      workshopId: widget.workshopId,
    );
  }

  Widget _buildRatingSection(WorkshopResponseModel workshop) {
    final ownerId = workshop.createdBy;
    if (ownerId == null || ownerId == 0) {
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
        userName: workshop.createdByFullname ?? 'Workshop Owner',
        userPhoto: workshop.createdByPhoto,
        workshop: workshop,
        onRatingSubmitted: (rating) {
          setState(() {
            _currentRatingUserId = ownerId;
          });
          AppMessages.showLoading(context);
          context.read<WorkshopCubit>().rateUser(
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
    WorkshopResponseModel? workshop,
    required Function(int) onRatingSubmitted,
  }) {
    int selectedRating = _ratings[userId] ?? 0;
    // Use actual rating data from API
    final double averageRating = workshop?.createdByRatingMean ?? 0.0;
    final int reviewsCount = workshop?.createdByRatingCount ?? 0;

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
              GestureDetector(
                onTap: () {
                  final userModel = UserModelHelper.createFromPartialData(
                    id: userId,
                    fullname: userName,
                    email: null,
                    profilePhoto: userPhoto,
                    specification: 'Workshop Owner',
                  );
                  context.pushNamed(Routes.userProfile, extra: userModel);
                },
                child: CircleAvatar(
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
                      'workshop_owner'.tr(),
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
                  if (reviewsCount > 0)
                    Text(
                      '($reviewsCount ${'common_reviews'.tr()})',
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
            '${'workshop_how_would_you_rate'.tr()} $userName?',
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
            "'Tap a star to rate'".tr(),
            style: TextStyle(fontSize: 16.sp, color: const Color(0xff7A7A7A)),
          ),
          if (selectedRating > 0) ...[
            16.verticalSpace,
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
                    'Submit'.tr(),
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

  Widget _buildRateTalentBlock(WorkshopResponseModel workshop) {
    final purple = AppColors.barColor;
    final orange = AppColors.secondaryColor;

    // Get the first approved registration for rating
    final registration = workshop.myRegistration;
    if (registration == null) {
      return const SizedBox.shrink();
    }

    final averageRating = registration.userRatingMean ?? 0.0;
    final reviewsCount = registration.userRatingCount ?? 0;

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
              GestureDetector(
                onTap: () {
                  final userModel = UserModelHelper.createFromPartialData(
                    id: registration.user,
                    fullname: registration.userFullname,
                    email: registration.userEmail,
                    profilePhoto: registration.userPhoto,
                    specification: null,
                  );
                  context.pushNamed(Routes.userProfile, extra: userModel);
                },
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child:
                      registration.userPhoto != null &&
                          registration.userPhoto!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            registration.userPhoto!.startsWith('http')
                                ? registration.userPhoto!
                                : AppUrls.imageLink(registration.userPhoto!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              size: 20.w,
                              color: Colors.grey[400],
                            ),
                          ),
                        )
                      : Icon(Icons.person, size: 20.w, color: Colors.grey[400]),
                ),
              ),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      registration.userFullname,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
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
                        children: List.generate(5, (index) {
                          final rating = index + 1;
                          if (rating <= averageRating.floor()) {
                            return Padding(
                              padding: EdgeInsets.only(right: 2.w),
                              child: Icon(
                                Icons.star,
                                size: 14.sp,
                                color: orange,
                              ),
                            );
                          } else if (rating == averageRating.ceil() &&
                              averageRating % 1 != 0) {
                            return Padding(
                              padding: EdgeInsets.only(right: 2.w),
                              child: Icon(
                                Icons.star_half,
                                size: 14.sp,
                                color: orange,
                              ),
                            );
                          } else {
                            return Padding(
                              padding: EdgeInsets.only(right: 2.w),
                              child: Icon(
                                Icons.star_border,
                                size: 14.sp,
                                color: orange,
                              ),
                            );
                          }
                        }),
                      ),
                      4.width,
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: orange,
                        ),
                      ),
                    ],
                  ),
                  2.height,
                  if (reviewsCount > 0)
                    Text(
                      '($reviewsCount reviews)'.tr(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ],
          ),
          16.height,
          Text(
            'How would you rate ${registration.userFullname}?'.tr(),
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
                child: Icon(
                  Icons.star_border_rounded,
                  size: 24.sp,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
          6.height,
          Center(
            child: Text(
              'Tap a star to rate'.tr(),
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
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
                  backgroundColor: purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                onPressed: () {},
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
  State<_AppliedTalentRowWidget> createState() =>
      _AppliedTalentRowWidgetState();
}

class _AppliedTalentRowWidgetState extends State<_AppliedTalentRowWidget> {
  final _purple = AppColors.barColor;
  final _orange = AppColors.secondaryColor;
  int _userRating = 0;
  bool _isRatingSubmitted = false;

  bool get _isPending => widget.registration.status == 'pending';
  bool get _isApproved => widget.registration.status == 'approved';
  bool get _isRejected => widget.registration.status == 'rejected';

  String get _ratingKey =>
      'workshop_rating_${widget.workshopId}_${widget.registration.user}';

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
          // Rating submitted successfully
          AppMessages.showSuccess(context, state.message);
          _handleRatingSuccess();
        } else if (state is WorkshopError) {
          // Show error message for rating
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
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          final rating = index + 1;
                          final averageRating =
                              widget.registration.userRatingMean ?? 0.0;
                          if (rating <= averageRating.floor()) {
                            return Padding(
                              padding: EdgeInsets.only(right: 2.w),
                              child: Icon(
                                Icons.star,
                                size: 14.sp,
                                color: _orange,
                              ),
                            );
                          } else if (rating == averageRating.ceil() &&
                              averageRating % 1 != 0) {
                            return Padding(
                              padding: EdgeInsets.only(right: 2.w),
                              child: Icon(
                                Icons.star_half,
                                size: 14.sp,
                                color: _orange,
                              ),
                            );
                          } else {
                            return Padding(
                              padding: EdgeInsets.only(right: 2.w),
                              child: Icon(
                                Icons.star_border,
                                size: 14.sp,
                                color: _orange,
                              ),
                            );
                          }
                        }),
                      ),
                      4.width,
                      Text(
                        widget.registration.userRatingMean != null
                            ? widget.registration.userRatingMean!
                                  .toStringAsFixed(1)
                            : '0.0',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: _orange,
                        ),
                      ),
                    ],
                  ),
                  2.height,
                  if (widget.registration.userRatingCount != null &&
                      widget.registration.userRatingCount! > 0)
                    Text(
                      '(${widget.registration.userRatingCount} reviews)'.tr(),
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
              'How would you rate ${widget.registration.userFullname.split(' ').first}?'
                  .tr(),
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
                      index < _userRating
                          ? Icons.star_border_rounded
                          : Icons.star_border_rounded,
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
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
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
          profilePhoto: widget.registration.userPhoto,
          specification: null,
        );
        context.pushNamed(Routes.userProfile, extra: userModel);
      },
      child: Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child:
            widget.registration.userPhoto != null &&
                widget.registration.userPhoto!.isNotEmpty
            ? ClipOval(
                child: Image.network(
                  widget.registration.userPhoto!.startsWith('http')
                      ? widget.registration.userPhoto!
                      : AppUrls.imageLink(widget.registration.userPhoto!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    size: avatarSize * 0.5,
                    color: Colors.grey[400],
                  ),
                ),
              )
            : Icon(
                Icons.person,
                size: avatarSize * 0.5,
                color: Colors.grey[400],
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
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
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
              context.read<WorkshopCubit>().approveWorkshopRegistration(
                widget.registration.id,
              );
            },
          ),
          6.width,
          _buildActionButton(
            label: 'reject'.tr(),
            color: _purple,
            onTap: () {
              context.read<WorkshopCubit>().rejectWorkshopRegistration(
                widget.registration.id,
              );
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
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
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
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
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
