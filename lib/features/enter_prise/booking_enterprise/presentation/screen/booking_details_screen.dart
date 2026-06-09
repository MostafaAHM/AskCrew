import 'package:aflam/core/widgets/animated_loading/animated_loading.dart';
import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/app_config/app_icons.dart';
import 'package:aflam/core/app_config/app_urls.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/core/widgets/shimmer/custom_shimmer_widget.dart';
import 'package:aflam/core/widgets/svg_image/svg_image_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/routes.dart';
import '../../data/models/response/booking_item_response_model.dart';
import '../../data/models/response/rent_request_response_model.dart';
import '../../presentation/cubit/booking_cubit.dart';
import '../../presentation/cubit/booking_state.dart';
import '../../../../chat/presentation/cubit/chat_cubit.dart';
import '../../../../chat/presentation/screens/chat_screen.dart';
import '../../../../../core/helpers/user_helper.dart';
import '../../../../../core/helpers/messages.dart';
import '../../../../../core/helpers/shared_pref_local_storage.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/presentation/utils/user_model_helper.dart';
import '../../../../../features/shared/payment/presentation/cubit/payment_cubit.dart';
import '../../../../../features/shared/payment/data/model/server/pay_for_booking_options.dart';
import 'package:aflam/features/shared/payment/presentation/widgets/promo_code_bottom_sheet.dart';

class BookingDetailsScreen extends StatefulWidget {
  final BookingItemResponseModel item;

  const BookingDetailsScreen({super.key, required this.item});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final int _currentImageIndex = 0;
  RentRequestResponseModel? _rentRequest;
  List<RentRequestResponseModel> _bookings = [];
  final Map<int, int> _ratings = {}; // Map of userId to rating
  final Map<int, bool> _hasRated =
      {}; // Map of userId to whether they've been rated
  int? _currentRatingUserId; // Track which user is being rated
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  int _selectedQuantity = 1;
  final TextEditingController _nameController = TextEditingController();

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
  void initState() {
    super.initState();
    // Check if there's an existing rent request
    final currentUser = UserHelper.userNotifier.value;
    final isOwner =
        currentUser != null &&
        widget.item.createdBy != null &&
        currentUser.id == widget.item.createdBy;

    // Load rating status for owner if renter
    if (!isOwner) {
      final ownerId = widget.item.createdBy;
      if (ownerId != null) {
        final ratingKey = _getRatingKey(ownerId);
        final hasRated =
            SharedPref.sharedPreferences.getBool(ratingKey) ?? false;
        if (hasRated) {
          _hasRated[ownerId] = true;
        }
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<BookingCubit>().getRentRequest(widget.item.id);
      });
    } else {
      // Owner: Get all bookings for this item
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isOwner) {
          context.read<BookingCubit>().getItemBookings(widget.item.id);
        } else {
          context.read<BookingCubit>().getBookings();
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = UserHelper.userNotifier.value;
    final isOwner =
        currentUser != null &&
        widget.item.createdBy != null &&
        currentUser.id == widget.item.createdBy;

    final dateFormat = DateFormat('d MMM yyyy');
    final createdDate = dateFormat.format(widget.item.createdAt);
    final updatedDate = dateFormat.format(widget.item.updatedAt);

    return MultiBlocListener(
      listeners: [
        BlocListener<BookingCubit, BookingState>(
          listener: (context, state) {
            if (state is RentRequestSuccess) {
              AppMessages.hideLoading(context);
              AppMessages.showSuccess(context, state.message);
              setState(() {
                _rentRequest = state.rentRequest;
              });
              // Refresh bookings list if owner
              if (isOwner) {
                context.read<BookingCubit>().getBookings();
              }
            } else if (state is RentRequestLoaded) {
              debugPrint(
                'RentRequestLoaded: ${state.rentRequest.status}, item: ${state.rentRequest.item}',
              );
              setState(() {
                _rentRequest = state.rentRequest;
              });
              // Load rating status for owner if request is approved
              if (_rentRequest != null && _rentRequest!.isApproved) {
                final ownerId = widget.item.createdBy;
                if (ownerId != null) {
                  final ratingKey = _getRatingKey(ownerId);
                  final hasRated =
                      SharedPref.sharedPreferences.getBool(ratingKey) ?? false;
                  if (hasRated) {
                    _hasRated[ownerId] = true;
                  }
                }
                debugPrint('Rent request is approved: ${_rentRequest!.status}');
              } else if (_rentRequest != null) {
                debugPrint('Rent request status: ${_rentRequest!.status}');
              }
            } else if (state is BookingSuccess) {
              AppMessages.hideLoading(context);
              if (state.message.contains('Rating')) {
                AppMessages.showSuccess(context, state.message);
                // Update hasRated after successful rating and save to SharedPreferences
                if (_currentRatingUserId != null) {
                  final ratingKey = _getRatingKey(_currentRatingUserId!);
                  SharedPref.sharedPreferences.setBool(ratingKey, true);
                  setState(() {
                    _hasRated[_currentRatingUserId!] = true;
                    _ratings[_currentRatingUserId!] =
                        0; // Reset rating selection
                    _currentRatingUserId = null;
                  });
                }
              } else if (state.message.contains('updated')) {
                AppMessages.showSuccess(context, state.message);
                // Refresh bookings list if owner
                if (isOwner) {
                  context.read<BookingCubit>().getBookings();
                } else {
                  // If renter, refresh rent request to see updated status
                  context.read<BookingCubit>().getRentRequest(widget.item.id);
                  // Reload rating status for owner after update
                  final ownerId = widget.item.createdBy;
                  if (ownerId != null) {
                    final ratingKey = _getRatingKey(ownerId);
                    final hasRated =
                        SharedPref.sharedPreferences.getBool(ratingKey) ??
                        false;
                    if (hasRated) {
                      setState(() {
                        _hasRated[ownerId] = true;
                      });
                    }
                  }
                }
              }
            } else if (state is BookingDeleteSuccess) {
              AppMessages.hideLoading(context);
              AppMessages.showSuccess(context, state.message);
              // Refresh bookings list
              if (isOwner) {
                context.read<BookingCubit>().getItemBookings(widget.item.id);
              }
            } else if (state is BookingsListLoaded) {
              _loadRatingStatuses(state.bookings);
              setState(() {
                _bookings = state.bookings;
              });
            } else if (state is BookingError) {
              AppMessages.hideLoading(context);
              AppMessages.showError(context, state.message);
            }
          },
        ),
        BlocListener<PaymentCubit, PaymentState>(
          listener: (context, state) async {
            if (state is PaymentLoading) {
              AppMessages.showLoading(context);
            } else if (state is PaymentFailure) {
              AppMessages.hideLoading(context);
              AppMessages.showError(context, state.message);
            } else if (state is PaymentContentSuccess) {
              AppMessages.hideLoading(context);
              String? paymentUrl;
              if (state.response.transaction?.url != null) {
                paymentUrl = state.response.transaction!.url;
              } else if (state.response.checkoutUrl != null) {
                paymentUrl = state.response.checkoutUrl;
              }

              if (paymentUrl != null) {
                context.push(
                  Routes.paymentWebView,
                  extra: {
                    'paymentUrl': paymentUrl,
                    'onPaymentSuccess': () {
                      if (mounted) {
                        if (isOwner) {
                          context.read<BookingCubit>().getItemBookings(
                            widget.item.id,
                          );
                        } else {
                          context.read<BookingCubit>().getBookings();
                        }
                        AppMessages.showSuccess(
                          context,
                          AppStrings.paymentProcessCompletedSuccess.tr(),
                        );
                      }
                    },
                    'onPaymentCancel': () {
                      AppMessages.showError(
                        context,
                        AppStrings.paymentCancelledError.tr(),
                      );
                    },
                  },
                );
              }
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: CustomAppBar.backAppBar(
          showLogoInBackAppBar: true,
          actions: [
            InkWell(
              onTap: _openChat,
              child: Padding(
                padding: REdgeInsets.symmetric(horizontal: 16.w),
                child: SvgImageWidget(
                  image: AppIcons.chat,
                  width: 28.w,
                  height: 28.h,
                ),
              ),
            ),

            // Notification Icon
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              _buildImageSection(),

              // Product Details Section
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.name,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff1A0A00),
                            ),
                          ),
                        ),
                        Text(
                          '\$${widget.item.pricePerDay.toStringAsFixed(0)}/${AppStrings.day.tr()}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xffFF7A00),
                          ),
                        ),
                      ],
                    ),
                    16.height,

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18.sp,
                          color: const Color(0xff7A7A7A),
                        ),
                        4.width,
                        Expanded(
                          child: Text(
                            widget.item.location,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xff7A7A7A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    12.height,

                    // Start Time and End Time
                    if (widget.item.startTime != null ||
                        widget.item.endTime != null) ...[
                      if (widget.item.startTime != null)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 18.sp,
                              color: const Color(0xff7A7A7A),
                            ),
                            4.width,
                            Expanded(
                              child: Text(
                                '${AppStrings.startBookingTime.tr()}: ${DateFormat('yyyy-MM-dd HH:mm').format(widget.item.startTime!)}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xff7A7A7A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (widget.item.startTime != null &&
                          widget.item.endTime != null)
                        8.height,
                      if (widget.item.endTime != null)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 18.sp,
                              color: const Color(0xff7A7A7A),
                            ),
                            4.width,
                            Expanded(
                              child: Text(
                                '${AppStrings.endBookingTime.tr()}: ${DateFormat('yyyy-MM-dd HH:mm').format(widget.item.endTime!)}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xff7A7A7A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      12.height,
                    ],
                    // Availability
                    Text(
                      '${AppStrings.availability.tr()} : $createdDate - $updatedDate',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xff7A7A7A),
                      ),
                    ),
                    12.height,

                    // Number of items
                    Text(
                      '${AppStrings.noOfThisItem.tr()} : ${widget.item.quantity}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xff7A7A7A),
                      ),
                    ),
                    16.height,

                    // Description
                    if (widget.item.description != null &&
                        widget.item.description!.isNotEmpty) ...[
                      Text(
                        '${AppStrings.productDescription.tr()} :',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff1A0A00),
                        ),
                      ),
                      10.height,
                      Text(
                        widget.item.description!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xff7A7A7A),
                          height: 1.5,
                        ),
                      ),
                      30.height,
                    ],
                  ],
                ),
              ),

              if (!isOwner &&
                  _rentRequest != null &&
                  _rentRequest!.isApproved) ...[
                _buildRentCard(),
                24.height,
                _buildRatingSection(currentUser),
              ],

              if (!isOwner &&
                  (_rentRequest == null || !_rentRequest!.isApproved)) ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 54.w,
                    vertical: 24.h,
                  ),
                  child: BlocBuilder<BookingCubit, BookingState>(
                    builder: (context, state) {
                      final isLoading = state is RentRequestLoading;
                      return CustomButton(
                        text: isLoading
                            ? AppStrings.sendingRequest.tr()
                            : AppStrings.rentNow.tr(),
                        onTap: isLoading
                            ? null
                            : () => _showBookingBottomSheet(context),
                        height: 50.h,
                        fontSize: 16.sp,
                        isBackgroundGradient: true,
                        enabled: !isLoading,
                      );
                    },
                  ),
                ),
              ],

              // Pending Request Message
              if (!isOwner &&
                  _rentRequest != null &&
                  _rentRequest!.isPending) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.orange.shade700,
                          size: 24.sp,
                        ),
                        12.width,
                        Expanded(
                          child: Text(
                            AppStrings.rentRequestPendingApproval.tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                24.height,
              ],

              // Owner: Show bookings list
              if (isOwner) ...[
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.bookingRequests.tr(),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff1A0A00),
                            ),
                          ),
                          if (_bookings
                                  .where((b) => b.item == widget.item.id)
                                  .length >
                              2)
                            InkWell(
                              onTap: () {
                                context.pushNamed(
                                  Routes.allBookings,
                                  extra: widget.item,
                                );
                              },
                              child: Text(
                                'seeAll'.tr(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFF7A00),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                        ],
                      ),
                      16.height,
                      BlocBuilder<BookingCubit, BookingState>(
                        builder: (context, state) {
                          if (state is BookingLoading && _bookings.isEmpty) {
                            return Column(
                              children: List.generate(2, (index) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 12.h),
                                  child: CustomShimmerWidget(
                                    width: double.infinity,
                                    height: 200.h,
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                );
                              }),
                            );
                          }
                          final filteredBookings = _bookings
                              .where(
                                (booking) => booking.item == widget.item.id,
                              )
                              .toList();

                          if (filteredBookings.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.w),
                                child: Text(
                                  AppStrings.noBookingRequestsYet.tr(),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xff7A7A7A),
                                  ),
                                ),
                              ),
                            );
                          }

                          // Show only first 2 bookings
                          final displayBookings = filteredBookings
                              .take(2)
                              .toList();

                          return Column(
                            children: displayBookings
                                .map(
                                  (booking) => Padding(
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: _buildBookingCard(
                                      booking,
                                      currentUser,
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Main Image
        SizedBox(
          width: double.infinity,
          height: 300.h,
          child: widget.item.image.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: widget.item.image.startsWith('http')
                      ? widget.item.image
                      : AppUrls.imageLink(widget.item.image),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: AnimatedLoading()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.error),
                  ),
                )
              : Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, size: 64),
                ),
        ),

        // Dots Indicator
        Positioned(
          bottom: 16.h,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentImageIndex
                      ? const Color(0xffFF7A00)
                      : Colors.white,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  void _openChat() {
    final currentUser = UserHelper.userNotifier.value;
    final isOwner =
        currentUser != null &&
        widget.item.createdBy != null &&
        currentUser.id == widget.item.createdBy;

    // If owner, show rented people screen
    if (isOwner) {
      context.pushNamed(Routes.rentedPeople, extra: widget.item);
      return;
    }

    // If not owner, open chat directly
    if (widget.item.createdBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.userInformationNotAvailable.tr())),
      );
      return;
    }

    final chatCubit = context.read<ChatCubit>();
    chatCubit.getOrCreateChatRoom(widget.item.createdBy!).then((_) {
      final state = chatCubit.state;
      if (state.selectedRoom != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: chatCubit,
              child: ChatScreen(
                roomId: state.selectedRoom!.id,
                roomName: widget.item.createdByFullname ?? AppStrings.user.tr(),
                otherUserImage: null,
              ),
            ),
          ),
        );
      }
    });
  }

  void _sendRentRequest(BuildContext context) {
    if (_selectedStartDate == null || _selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseSelectStartEndDates.tr())),
      );
      return;
    }

    if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.endDateMustBeAfterStart.tr())),
      );
      return;
    }

    AppMessages.showLoading(context);
    context.read<BookingCubit>().createRentRequest(
      widget.item.id,
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : null,
      startDate: _selectedStartDate!,
      endDate: _selectedEndDate!,
      quantity: _selectedQuantity,
    );
  }

  Widget _buildRentCard() {
    if (_rentRequest == null) return const SizedBox.shrink();

    final needsPayment =
        _rentRequest!.isPaid != true &&
        _rentRequest!.paymentAmount != null &&
        _rentRequest!.paymentAmount! > 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffFF7A00), Color(0xff9B59B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.rentRequestApproved.tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    4.height,
                    Text(
                      needsPayment
                          ? AppStrings.pleaseCompletePayment.tr()
                          : AppStrings.yourRequestHasBeenApproved.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          16.height,
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.itemType.tr(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    4.height,
                    Text(
                      widget.item.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppStrings.pricePerDay.tr(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    4.height,
                    Text(
                      '\$${widget.item.pricePerDay.toStringAsFixed(0)}/${AppStrings.day.tr()}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (needsPayment) ...[
            16.height,
            Container(
              width: double.infinity,
              height: 45.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    PromoCodeBottomSheet.show(
                      context,
                      onApply: (code, withWallet, usePoints) {
                        context.read<PaymentCubit>().payForBooking(
                          PayForBookingOptions(
                            bookingId: _rentRequest!.id,
                            amount: _rentRequest!.paymentAmount,
                            code: code,
                            usePoints: usePoints,
                          ),
                        );
                      },
                      onCancel: () {},
                      showWalletOption: false,
                    );
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Center(
                    child: Text(
                      '${AppStrings.payNow.tr()} (\$${_rentRequest!.paymentAmount})',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xffFF7A00),
                      ),
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

  Widget _buildBookingCard(
    RentRequestResponseModel booking,
    dynamic currentUser,
  ) {
    final isPending = booking.status == 'pending';
    final isApproved = booking.status == 'approved';

    // Use cached rating status (loaded in _loadRatingStatuses)
    final canRate = isApproved && !(_hasRated[booking.user] ?? false);

    // If pending, show request card with Accept/Reject buttons
    if (isPending) {
      return _buildRequestCard(booking);
    }

    // If approved and can rate, show rating card only
    if (isApproved && canRate) {
      return _buildRatingCard(
        userId: booking.user,
        userName: booking.userFullname ?? 'User',
        userPhoto: booking.userPhoto,
        booking: booking,
        onRatingSubmitted: (rating) {
          _submitRating(booking.user, rating);
        },
      );
    }

    // If approved but already rated, show simple status card
    return _buildStatusCard(booking);
  }

  Widget _buildRequestCard(RentRequestResponseModel booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
          GestureDetector(
            onTap: () {
              final userModel = UserModelHelper.createFromPartialData(
                id: booking.user,
                fullname: booking.userFullname,
                email: booking.userEmail,
                profilePhoto: booking.userPhoto,
                specification: 'Actor',
              );
              context.pushNamed(Routes.userProfile, extra: userModel);
            },
            child: CircleAvatar(
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
          ),
          12.width,
          // Name and role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.userFullname ?? 'User ${booking.user}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff1A0A00),
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
                onTap: () => _updateBookingStatus(booking, 'approved'),
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
                onTap: () => _updateBookingStatus(booking, 'rejected'),
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
      margin: EdgeInsets.only(bottom: 12.h),
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
          GestureDetector(
            onTap: () {
              final userModel = UserModelHelper.createFromPartialData(
                id: booking.user,
                fullname: booking.userFullname,
                email: booking.userEmail,
                profilePhoto: booking.userPhoto,
                specification: 'Actor',
              );
              context.pushNamed(Routes.userProfile, extra: userModel);
            },
            child: CircleAvatar(
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
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.userFullname ?? 'User ${booking.user}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff1A0A00),
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

  Widget _buildRatingSection(dynamic currentUser) {
    if (_rentRequest == null || !_rentRequest!.isApproved) {
      return const SizedBox.shrink();
    }

    final ownerId = widget.item.createdBy;
    // Use cached rating status (should be loaded already)
    final canRateOwner = ownerId != null && !(_hasRated[ownerId] ?? false);

    if (!canRateOwner) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: _buildRatingCard(
        userId: ownerId,
        userName: widget.item.createdByFullname ?? 'Owner',
        userPhoto: null, // Owner photo not available in item model
        booking: _rentRequest,
        onRatingSubmitted: (rating) {
          _submitRating(ownerId, rating);
        },
      ),
    );
  }

  Widget _buildRatingCard({
    required int userId,
    required String userName,
    String? userPhoto,
    RentRequestResponseModel? booking,
    required Function(int) onRatingSubmitted,
  }) {
    int selectedRating = _ratings[userId] ?? 0;
    // Use actual rating data from API
    final double averageRating = booking?.userRatingMean ?? 0.0;
    final int reviewsCount = booking?.userRatingCount ?? 0;

    return Container(
      padding: EdgeInsets.all(20.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              // User photo
              GestureDetector(
                onTap: () {
                  final userModel = UserModelHelper.createFromPartialData(
                    id: userId,
                    fullname: userName,
                    email: null,
                    profilePhoto: userPhoto,
                    specification: 'Actor',
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
                  if (reviewsCount > 0)
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
          // Booking details (start_date, end_date, quantity)
          if (booking != null &&
              (booking.startDate != null ||
                  booking.endDate != null ||
                  booking.quantity != null)) ...[
            24.height,
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (booking.startDate != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16.sp,
                          color: const Color(0xff7A7A7A),
                        ),
                        8.width,
                        Text(
                          '${AppStrings.startDate.tr()}: ${DateFormat('yyyy-MM-dd').format(booking.startDate!)}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xff7A7A7A),
                          ),
                        ),
                      ],
                    ),
                    if (booking.endDate != null || booking.quantity != null)
                      8.height,
                  ],
                  if (booking.endDate != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16.sp,
                          color: const Color(0xff7A7A7A),
                        ),
                        8.width,
                        Text(
                          '${AppStrings.endDate.tr()}: ${DateFormat('yyyy-MM-dd').format(booking.endDate!)}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xff7A7A7A),
                          ),
                        ),
                      ],
                    ),
                    if (booking.quantity != null) 8.height,
                  ],
                  if (booking.quantity != null)
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2,
                          size: 16.sp,
                          color: const Color(0xff7A7A7A),
                        ),
                        8.width,
                        Text(
                          '${AppStrings.quantity.tr()}: ${booking.quantity}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xff7A7A7A),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
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

  void _updateBookingStatus(RentRequestResponseModel booking, String status) {
    AppMessages.showLoading(context);
    context.read<BookingCubit>().updateBooking(
      id: booking.id,
      itemId: booking.item,
      status: status,
      startDate: booking.startDate,
      endDate: booking.endDate,
      quantity: booking.quantity,
    );
  }

  void _submitRating(int toUserId, int rating) {
    setState(() {
      _currentRatingUserId = toUserId;
    });
    AppMessages.showLoading(context);
    context.read<BookingCubit>().rateUser(toUserId: toUserId, rating: rating);
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        8.height,
        InkWell(
          onTap: onTap,
          child: Container(
            height: 52.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: const Color(0xFFD0D5DD), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null
                        ? DateFormat('yyyy-MM-dd').format(date)
                        : '${AppStrings.select.tr()} $label',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: date != null
                          ? const Color(0xFF101828)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20.w,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectStartDate(
    BuildContext context, [
    Function(DateTime)? onPicked,
  ]) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedStartDate = pickedDate;
        // If end date is before start date, reset it
        if (_selectedEndDate != null &&
            _selectedEndDate!.isBefore(_selectedStartDate!)) {
          _selectedEndDate = null;
        }
      });
      if (onPicked != null) onPicked(pickedDate);
    }
  }

  Future<void> _selectEndDate(
    BuildContext context, [
    Function(DateTime)? onPicked,
  ]) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? (_selectedStartDate ?? DateTime.now()),
      firstDate: _selectedStartDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedEndDate = pickedDate;
      });
      if (onPicked != null) onPicked(pickedDate);
    }
  }

  void _showBookingBottomSheet(BuildContext context) {
    final bookingCubit = context.read<BookingCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return BlocProvider.value(
          value: bookingCubit,
          child: StatefulBuilder(
            builder: (statefulContext, setModalState) {
              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(statefulContext).viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle
                        Center(
                          child: Container(
                            width: 40.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ),
                        24.height,
                        Text(
                          AppStrings.completeBooking.tr(),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff1A0A00),
                          ),
                        ),
                        8.height,
                        Text(
                          AppStrings.selectDatesAndQuantity.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xff7A7A7A),
                          ),
                        ),
                        24.height,
                        Text(
                          AppStrings.bookingName.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        8.height,
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: AppStrings.enterBookingName.tr(),
                            hintStyle: TextStyle(
                              fontSize: 15.sp,
                              color: const Color(0xFF9CA3AF),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.r),
                              borderSide: const BorderSide(
                                color: Color(0xFFD0D5DD),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.r),
                              borderSide: const BorderSide(
                                color: Color(0xFFD0D5DD),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.r),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF7A00),
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                          ),
                        ),
                        16.height,

                        // Start Date
                        _buildDateField(
                          label: AppStrings.startDate.tr(),
                          date: _selectedStartDate,
                          onTap: () => _selectStartDate(
                            statefulContext,
                            (date) => setModalState(() {}),
                          ),
                        ),
                        16.height,

                        // End Date
                        _buildDateField(
                          label: AppStrings.endDate.tr(),
                          date: _selectedEndDate,
                          onTap: () => _selectEndDate(
                            statefulContext,
                            (date) => setModalState(() {}),
                          ),
                        ),
                        16.height,

                        // Quantity
                        Text(
                          AppStrings.quantity.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        8.height,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: const Color(0xFFD0D5DD)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.noOfThisItem.tr(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xff7A7A7A),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _selectedQuantity > 1
                                        ? () {
                                            setState(() => _selectedQuantity--);
                                            setModalState(() {});
                                          }
                                        : null,
                                    icon: Icon(Icons.remove_circle_outline),
                                    color: _selectedQuantity > 1
                                        ? const Color(0xFFFF7A00)
                                        : Colors.grey,
                                  ),
                                  Container(
                                    width: 40.w,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$_selectedQuantity',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() => _selectedQuantity++);
                                      setModalState(() {});
                                    },
                                    icon: Icon(Icons.add_circle_outline),
                                    color: const Color(0xFFFF7A00),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        32.height,

                        // Confirm Button
                        // Confirm Button
                        CustomButton(
                          text: AppStrings.confirmBooking.tr(),
                          onTap:
                              (_selectedStartDate != null &&
                                  _selectedEndDate != null)
                              ? () {
                                  Navigator.pop(statefulContext);
                                  _sendRentRequest(context);
                                }
                              : null,
                          height: 54.h,
                          fontSize: 16.sp,
                          isBackgroundGradient: true,
                          enabled:
                              _selectedStartDate != null &&
                              _selectedEndDate != null,
                        ),
                        16.height,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
