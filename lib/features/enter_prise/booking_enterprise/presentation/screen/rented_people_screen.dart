import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/core/widgets/shimmer/custom_shimmer_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/response/booking_item_response_model.dart';
import '../../presentation/cubit/booking_cubit.dart';
import '../../presentation/cubit/booking_state.dart';
import '../widgets/rented_person_item.dart';

class RentedPeopleScreen extends StatelessWidget {
  final BookingItemResponseModel item;

  const RentedPeopleScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = context.read<BookingCubit>();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          cubit.getItemBookings(item.id);
        });
        return cubit;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
        body: SafeArea(
          child: Column(
            children: [
              _buildTitle(),
              Expanded(child: _buildContent(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Text(
        AppStrings.rentedPeople.tr(),
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return _buildLoadingState();
        }

        if (state is BookingError) {
          return _buildErrorState(context, state);
        }

        if (state is BookingsListLoaded) {
          return _buildBookingsList(context, state.bookings);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: 5,
      separatorBuilder: (_, __) => 16.height,
      itemBuilder: (context, index) {
        return CustomShimmerWidget(
          width: double.infinity,
          height: 120.h,
          borderRadius: BorderRadius.circular(12.r),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, BookingError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            state.message,
            style: TextStyle(fontSize: 14.sp, color: Colors.red),
          ),
          16.height,
          ElevatedButton(
            onPressed: () {
              context.read<BookingCubit>().getItemBookings(item.id);
            },
            child: Text(AppStrings.retry.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(BuildContext context, List<dynamic> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(
          AppStrings.noBookingsFound.tr(),
          style: TextStyle(fontSize: 16.sp, color: AppColors.greyText),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => 16.height,
      itemBuilder: (context, index) {
        return RentedPersonItem(booking: bookings[index], item: item);
      },
    );
  }
}
