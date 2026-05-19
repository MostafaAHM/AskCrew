import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/app_config/app_icons.dart';
import 'package:aflam/core/app_config/app_urls.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/svg_image/svg_image_widget.dart';
import 'package:aflam/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:aflam/features/chat/presentation/screens/chat_screen.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/presentation/utils/user_model_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/routes.dart';
import '../../data/models/response/booking_item_response_model.dart';
import '../../data/models/response/rent_request_response_model.dart';

class RentedPersonItem extends StatelessWidget {
  final RentRequestResponseModel booking;
  final BookingItemResponseModel item;

  const RentedPersonItem({
    super.key,
    required this.booking,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfilePicture(context),
          16.width,
          Expanded(child: _buildUserInfo()),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(BuildContext context) {
    return GestureDetector(
      onTap: () => _viewProfile(context),
      child: CircleAvatar(
        radius: 30.r,
        backgroundColor: Colors.grey[200],
        backgroundImage: booking.userPhoto != null
            ? CachedNetworkImageProvider(AppUrls.imageLink(booking.userPhoto!))
            : null,
        child: booking.userPhoto == null
            ? Icon(Icons.person, size: 30.sp, color: Colors.grey[400])
            : null,
      ),
    );
  }

  Widget _buildUserInfo() {
    final rating = booking.userRatingMean ?? 0.0;
    final ratingCount = booking.userRatingCount ?? 0;
    final dateRange = _getDateRange();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserName(),
        8.height,
        _buildRating(rating),
        4.height,
        _buildReviewsCount(ratingCount),
        12.height,
        _buildDateRange(dateRange),
        4.height,
        _buildPrice(),
      ],
    );
  }

  Widget _buildUserName() {
    return Text(
      booking.userFullname ?? AppStrings.user.tr(),
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildRating(double rating) {
    final filledStars = rating.floor();
    final hasHalfStar = rating - filledStars >= 0.5;

    return Row(
      children: [
        ...List.generate(5, (index) {
          if (index < filledStars) {
            return Icon(
              Icons.star,
              size: 20.sp,
              color: const Color(0xFFFF7A3C),
            );
          } else if (index == filledStars && hasHalfStar) {
            return Icon(
              Icons.star_half,
              size: 20.sp,
              color: const Color(0xFFFF7A3C),
            );
          } else {
            return Icon(
              Icons.star_border,
              size: 20.sp,
              color: const Color(0xFFFF7A3C),
            );
          }
        }),
        4.width,
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFF7A3C),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsCount(int count) {
    return Text(
      '($count ${AppStrings.reviews.tr()})',
      style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
    );
  }

  Widget _buildDateRange(String dateRange) {
    return Text(
      dateRange,
      style: TextStyle(fontSize: 17.sp, color: Colors.grey[700]),
    );
  }

  Widget _buildPrice() {
    return Text(
      '\$${item.pricePerDay.toStringAsFixed(0)}',
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFFF7A3C),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildViewProfileLink(context),
        8.height,
        _buildChatButton(context),
      ],
    );
  }

  Widget _buildViewProfileLink(BuildContext context) {
    return GestureDetector(
      onTap: () => _viewProfile(context),
      child: Text(
        AppStrings.viewProfile.tr(),
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFFF7A3C),
        ),
      ),
    );
  }

  Widget _buildChatButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _openChat(context),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFF7A3C).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: SvgImageWidget(image: AppIcons.chat, width: 20.w, height: 20.h),
      ),
    );
  }

  String _getDateRange() {
    final dateFormat = DateFormat('d MMM');
    final startDate = dateFormat.format(booking.createdAt);
    final endDate = booking.updatedAt != null
        ? dateFormat.format(booking.updatedAt!)
        : startDate;
    return '$startDate - $endDate';
  }

  void _openChat(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();
    chatCubit.getOrCreateChatRoom(booking.user).then((_) {
      final chatState = chatCubit.state;
      if (chatState.selectedRoom != null && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: chatCubit,
              child: ChatScreen(
                roomId: chatState.selectedRoom!.id,
                roomName: booking.userFullname ?? AppStrings.user.tr(),
                otherUserImage: booking.userPhoto != null
                    ? AppUrls.imageLink(booking.userPhoto!)
                    : null,
                specification: null,
              ),
            ),
          ),
        );
      }
    });
  }

  void _viewProfile(BuildContext context) {
    final user = UserModelHelper.createFromPartialData(
      id: booking.user,
      fullname: booking.userFullname ?? AppStrings.user.tr(),
      profilePhoto: booking.userPhoto,
      specification: null,
    );
    context.pushNamed(Routes.userProfile, extra: user);
  }
}
