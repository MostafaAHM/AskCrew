import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:aflam/core/widgets/shimmer/custom_shimmer_widget.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/presentation/cubit/profile_cubit.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/presentation/cubit/profile_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../config/routes/routes.dart';
import '../../../../../features/auth/login/data/model/response/user_model.dart';

class ViewerProfileDetailsScreen extends StatelessWidget {
  final UserModel? preloadedUser;

  const ViewerProfileDetailsScreen({super.key, this.preloadedUser});

  Widget _buildShimmerSkeleton() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header Shimmer
          Column(
            children: [
              CustomShimmerWidget(
                width: 120.r,
                height: 120.r,
                shape: BoxShape.circle,
              ),
              16.height,
              CustomShimmerWidget(
                width: 150.w,
                height: 24.h,
                borderRadius: BorderRadius.circular(8.r),
              ),
              8.height,
              CustomShimmerWidget(
                width: 200.w,
                height: 16.h,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ],
          ),
          24.height,
          // Wallet & Points Shimmer
          Row(
            children: [
              Expanded(
                child: CustomShimmerWidget(
                  width: double.infinity,
                  height: 100.h,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              12.width,
              Expanded(
                child: CustomShimmerWidget(
                  width: double.infinity,
                  height: 100.h,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ],
          ),
          20.height,
          // Account Details Shimmer
          CustomShimmerWidget(
            width: double.infinity,
            height: 200.h,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = getIt<ProfileCubit>();
        if (preloadedUser != null) {
          cubit.seedProfile(preloadedUser!, isOwner: true);
        } else {
          cubit.getMyProfile();
        }
        return cubit;
      },
      child: Scaffold(
        appBar: CustomAppBar.backAppBar(
          showLogoInBackAppBar: true,
          onBackPressed: () => context.pop(),
          actions: preloadedUser == null
              ? [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () async {
                      final result = await context.pushNamed(
                        Routes.editViewerProfile,
                      );
                      if (result == true && context.mounted) {
                        context.read<ProfileCubit>().getMyProfile();
                      }
                    },
                  ),
                ]
              : null,
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            // Show shimmer skeleton while loading (better UX)
            if (state is ProfileLoading) {
              return _buildShimmerSkeleton();
            }

            if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<ProfileCubit>().getMyProfile(),
                      child: Text(AppStrings.retry.tr()),
                    ),
                  ],
                ),
              );
            }

            if (state is ProfileLoaded) {
              final user = state.user;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Header Section
                    _ProfileHeader(user: user),
                    24.height,
                    // Wallet & Points Section
                    _WalletPointsSection(user: user),
                    20.height,
                    // Personal Information Section
                    if (user.personalInfo != null &&
                        user.personalInfo.toString().isNotEmpty)
                      _PersonalInfoSection(user: user),
                    if (user.personalInfo != null &&
                        user.personalInfo.toString().isNotEmpty)
                      20.height,
                    // Account Details Section
                    _AccountDetailsSection(user: user),
                    20.height,
                    // Favorite Categories Section
                    if (user.profile?.favoriteCategories != null &&
                        user.profile!.favoriteCategories.isNotEmpty)
                      _FavoriteCategoriesSection(user: user),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Profile Photo
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120.r,
                height: 120.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: user.profilePhoto != null
                    ? ClipOval(
                        child: CustomCachedNetworkImage(
                          url: user.profilePhoto,
                          fit: BoxFit.cover,
                          serverImage: true,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 60.sp,
                        color: Colors.grey.shade400,
                      ),
              ),
              // TODO: Change this condition to check payment/subscription status instead of isVerified
              // Verified badge should only show after payment, not activation
              // Example: if (user.profile?.paymentPlan != null && user.profile!.paymentPlan!.isNotEmpty)
              // Or check if user has an active subscription/plan
              if (user.waterMark)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.verified,
                      color: AppColors.primaryColor,
                      size: 24.sp,
                    ),
                  ),
                ),
            ],
          ),
        ),
        16.height,
        // Name
        Text(
          user.fullname,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        8.height,
        // Email
        Text(
          user.email,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
        ),
        8.height,
        // Mobile Phone
        if (user.mobilePhone.isNotEmpty)
          Text(
            user.mobilePhone,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
          ),
      ],
    );
  }
}

class _WalletPointsSection extends StatelessWidget {
  final dynamic user;

  const _WalletPointsSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            title: AppStrings.wallet.tr(),
            value: '${user.wallet}',
            icon: Icons.account_balance_wallet,
            color: AppColors.primaryColor,
          ),
        ),
        12.width,
        Expanded(
          child: _InfoCard(
            title: AppStrings.points.tr(),
            value: '${user.points}',
            icon: Icons.stars,
            color: AppColors.secondaryColor,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32.sp),
          8.height,
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          4.height,
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoSection extends StatelessWidget {
  final dynamic user;

  const _PersonalInfoSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final personalInfo = user.personalInfo?.toString() ?? '';
    if (personalInfo.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.bio.tr(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          12.height,
          Text(
            personalInfo,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountDetailsSection extends StatelessWidget {
  final dynamic user;

  const _AccountDetailsSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final joinedDate = dateFormat.format(user.dateJoined);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.accountDetails.tr(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          16.height,
          _DetailRow(
            label: AppStrings.type.tr(),
            value: user.type.toUpperCase(),
          ),
          12.height,
          _DetailRow(label: AppStrings.dateJoined.tr(), value: joinedDate),
          12.height,
          _DetailRow(
            label: AppStrings.status.tr(),
            value: user.isActive
                ? AppStrings.active.tr()
                : AppStrings.inactive.tr(),
            valueColor: user.isActive ? Colors.green : Colors.grey,
          ),
          if (user.ratingMean != null && user.ratingMean! > 0) ...[
            12.height,
            _DetailRow(
              label: AppStrings.rating.tr(),
              value:
                  '${user.ratingMean!.toStringAsFixed(1)} ${AppStrings.nReviews.tr(namedArgs: {'count': (user.ratingCount ?? 0).toString()})}',
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: valueColor ?? Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _FavoriteCategoriesSection extends StatelessWidget {
  final dynamic user;

  const _FavoriteCategoriesSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final categories = user.profile?.favoriteCategories ?? [];
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.favoriteCategories.tr(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          12.height,
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: categories.map<Widget>((category) {
              final categoryName = category is Map
                  ? (category['name'] ?? category.toString())
                  : category.toString();
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
