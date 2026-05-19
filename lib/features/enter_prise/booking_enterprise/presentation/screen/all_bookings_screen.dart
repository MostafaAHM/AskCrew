import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/app_config/app_urls.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/shared_pref_local_storage.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/core/widgets/shimmer/custom_shimmer_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/response/rent_request_response_model.dart';
import '../../data/models/response/booking_item_response_model.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';

class AllBookingsScreen extends StatefulWidget {
  final BookingItemResponseModel item;

  const AllBookingsScreen({super.key, required this.item});

  @override
  State<AllBookingsScreen> createState() => _AllBookingsScreenState();
}

class _AllBookingsScreenState extends State<AllBookingsScreen> {
  final Map<int, int> _ratings = {};
  final Map<int, bool> _hasRated = {};
  int? _currentRatingUserId;

  String _getRatingKey(int userId) {
    return 'booking_rating_${widget.item.id}_$userId';
  }

  void _loadRatingStatuses(List<RentRequestResponseModel> bookings) {
    for (final booking in bookings) {
      final ratingKey = _getRatingKey(booking.user);
      final hasRated = SharedPref.sharedPreferences.getBool(ratingKey) ?? false;
      if (hasRated) {
        _hasRated[booking.user] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = getIt<BookingCubit>();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          cubit.getBookings();
        });
        return cubit;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
        body: BlocListener<BookingCubit, BookingState>(
          listener: (context, state) {
            if (state is BookingSuccess) {
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
              } else if (state.message.contains('updated')) {
                context.read<BookingCubit>().getBookings();
              }
            }
          },
          child: BlocBuilder<BookingCubit, BookingState>(
            builder: (context, state) {
              if (state is BookingLoading) {
                return ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: 5,
                  separatorBuilder: (_, __) => 12.height,
                  itemBuilder: (context, index) {
                    return CustomShimmerWidget(
                      width: double.infinity,
                      height: 200.h,
                      borderRadius: BorderRadius.circular(16.r),
                    );
                  },
                );
              }

              if (state is BookingError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      16.height,
                      ElevatedButton(
                        onPressed: () {
                          context.read<BookingCubit>().getBookings();
                        },
                        child: Text('Retry'.tr()),
                      ),
                    ],
                  ),
                );
              }

              if (state is BookingsListLoaded) {
                final filteredBookings = state.bookings
                    .where((booking) => booking.item == widget.item.id)
                    .toList();

                // Load rating statuses for all bookings
                _loadRatingStatuses(filteredBookings);

                if (filteredBookings.isEmpty) {
                  return Center(child: Text(AppStrings.noBookingsFound.tr()));
                }

                return ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: filteredBookings.length,
                  separatorBuilder: (_, __) => 12.height,
                  itemBuilder: (context, index) {
                    final booking = filteredBookings[index];
                    return _buildBookingCard(booking, context);
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    RentRequestResponseModel booking,
    BuildContext context,
  ) {
    final isPending = booking.status == 'pending';
    final isApproved = booking.status == 'approved';

    // Use cached rating status (loaded in _loadRatingStatuses)
    final canRate = isApproved && !(_hasRated[booking.user] ?? false);

    // If pending, show request card with Accept/Reject buttons
    if (isPending) {
      return _buildRequestCard(booking, context);
    }

    // If approved and can rate, show rating card only
    if (isApproved && canRate) {
      return _buildRatingCard(
        userId: booking.user,
        userName: booking.userFullname ?? AppStrings.user.tr(),
        userPhoto: booking.userPhoto,
        onRatingSubmitted: (rating) {
          setState(() {
            _currentRatingUserId = booking.user;
          });
          context.read<BookingCubit>().rateUser(
            toUserId: booking.user,
            rating: rating,
          );
        },
      );
    }

    // If approved but already rated, show simple status card
    return _buildStatusCard(booking);
  }

  Widget _buildRequestCard(
    RentRequestResponseModel booking,
    BuildContext context,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User photo
          CircleAvatar(
            radius: 30.r,
            backgroundColor: Colors.grey.shade200,
            backgroundImage:
                booking.userPhoto != null && booking.userPhoto!.isNotEmpty
                ? CachedNetworkImageProvider(
                    booking.userPhoto!.startsWith('http')
                        ? booking.userPhoto!
                        : AppUrls.imageLink(booking.userPhoto!),
                  )
                : null,
            child: booking.userPhoto == null || booking.userPhoto!.isEmpty
                ? Icon(Icons.person, size: 30.sp, color: Colors.grey.shade400)
                : null,
          ),
          12.width,
          // Name and role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.userFullname ??
                      '${AppStrings.user.tr()} ${booking.user}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff1A0A00),
                  ),
                ),
                4.height,
                Text(
                  AppStrings.actor.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xff1A0A00),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Accept button (orange)
              InkWell(
                onTap: () => _updateBookingStatus(context, booking, 'approved'),
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A00),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    AppStrings.accept.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              8.width,
              // Reject button (purple)
              InkWell(
                onTap: () => _updateBookingStatus(context, booking, 'rejected'),
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9B59B6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    AppStrings.reject.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(RentRequestResponseModel booking) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: Colors.grey.shade200,
            backgroundImage:
                booking.userPhoto != null && booking.userPhoto!.isNotEmpty
                ? CachedNetworkImageProvider(
                    booking.userPhoto!.startsWith('http')
                        ? booking.userPhoto!
                        : AppUrls.imageLink(booking.userPhoto!),
                  )
                : null,
            child: booking.userPhoto == null || booking.userPhoto!.isEmpty
                ? Icon(Icons.person, size: 30.sp, color: Colors.grey.shade400)
                : null,
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.userFullname ??
                      '${AppStrings.user.tr()} ${booking.user}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff1A0A00),
                  ),
                ),
                4.height,
                Text(
                  AppStrings.actor.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xff1A0A00),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: booking.status == 'approved'
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              booking.status.toUpperCase(),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: booking.status == 'approved'
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateBookingStatus(
    BuildContext context,
    RentRequestResponseModel booking,
    String status,
  ) {
    context.read<BookingCubit>().updateBooking(
      id: booking.id,
      itemId: booking.item,
      status: status,
      startDate: booking.startDate,
      endDate: booking.endDate,
      quantity: booking.quantity,
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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              // User photo
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
              12.width,
              // User name and role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff1A0A00),
                      ),
                    ),
                    4.height,
                    Text(
                      AppStrings.actor.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xff7A7A7A),
                      ),
                    ),
                  ],
                ),
              ),
              // Average rating
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
                  4.height,
                  Text(
                    '($reviewsCount ${AppStrings.reviews.tr()})',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xff7A7A7A),
                    ),
                  ),
                ],
              ),
            ],
          ),
          24.height,
          // Rating question
          Text(
            '${AppStrings.howWouldYouRate.tr()} $userName?',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff1A0A00),
            ),
          ),
          16.height,
          // Interactive stars
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
                  padding: EdgeInsets.only(right: 12.w),
                  child: Icon(
                    rating <= selectedRating ? Icons.star : Icons.star_border,
                    color: rating <= selectedRating
                        ? const Color(0xFFFF7A00)
                        : Colors.grey.shade400,
                    size: 40.sp,
                  ),
                ),
              );
            }),
          ),
          8.height,
          Text(
            AppStrings.tapAStarToRate.tr(),
            style: TextStyle(fontSize: 12.sp, color: const Color(0xff7A7A7A)),
          ),
          if (selectedRating > 0) ...[
            20.height,
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
                    AppStrings.submit.tr(),
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
