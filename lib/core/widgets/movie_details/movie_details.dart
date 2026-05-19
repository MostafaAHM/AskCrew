import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/features/shared/payment/data/model/server/pay_for_content_options.dart';
import 'package:aflam/features/shared/payment/presentation/cubit/payment_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aflam/features/viewer/continue_watching/presentation/cubit/continue_watching_cubit.dart';
import 'package:aflam/features/viewer/continue_watching/data/models/continue_watching_request_model.dart';

import 'package:aflam/features/enter_prise/profile_enterprise/presentation/cubit/profile_cubit.dart';
import '../../../config/routes/routes.dart';
import '../../../features/viewer/home_viewer/data/model/movies_with_series_model.dart';
import '../../../features/viewer/home_viewer/data/repository/movies_with_series_repository.dart';
import 'package:aflam/core/helpers/shared_pref_local_storage.dart';
import 'package:aflam/core/helpers/user_helper.dart';
import 'package:aflam/features/shared/payment/presentation/widgets/promo_code_bottom_sheet.dart';
import 'widgets/content_details_section_widget.dart';
import 'widgets/content_header_widget.dart';
import 'widgets/content_title_section_widget.dart';
import 'widgets/payment_listener_widget.dart';

class MovieDetailsScreens extends StatefulWidget {
  final MovieOrSeriesItem item;

  const MovieDetailsScreens({super.key, required this.item});

  @override
  State<MovieDetailsScreens> createState() => _MovieDetailsScreensState();
}

class _MovieDetailsScreensState extends State<MovieDetailsScreens> {
  bool _isPaid = false;
  bool _isProcessingPayment = false;
  // Store refreshed item here
  MovieOrSeriesItem? _refreshedItem;

  MovieOrSeriesItem get _currentItem => _refreshedItem ?? widget.item;

  late final PaymentCubit _paymentCubit;
  bool _hasRated = false;

  @override
  void initState() {
    super.initState();
    print(
      '🔎 [MovieDetails] initState: item.id=${_currentItem.id}, item.isPaid=${_currentItem.isPaid}',
    );
    _paymentCubit = getIt<PaymentCubit>();
    _initRatingStatus();
    _updatePaymentStatus();
    // Fetch fresh details immediately on load
    _refreshContentDetails();
  }

  void _initRatingStatus() {
    // Check local cache first for immediate feedback (handles stale API data)
    final cacheKey = 'rated_${_currentItem.contentType}_${_currentItem.id}';
    final hasRatedLocally =
        SharedPref.sharedPreferences.getBool(cacheKey) ?? false;

    // Combine API status with local cache
    _hasRated = _currentItem.isRated || hasRatedLocally;
  }

  /// Refresh content details from server to get authoritative isPaid status
  Future<void> _refreshContentDetails({bool autoPlay = false}) async {
    print(
      '🔄 [MovieDetails] Refreshing content details for ID: ${_currentItem.id}',
    );

    final repo = getIt<MoviesWithSeriesRepository>();
    final result = await repo.getContentDetails(
      // The repository now handles specific types, so we pass the exact type from the item
      contentType: _currentItem.contentType,
      id: _currentItem.id,
    );

    if (!mounted) return;

    result.fold(
      (error) {
        print('❌ [MovieDetails] Refresh failed: ${error.message}');
        // Even if refresh fails, if we just paid, we might trust _isPaid logic
        // effectively handled by optimistic update in PaymentListener
      },
      (item) {
        print(
          '✅ [MovieDetails] Refresh success. isPaid: ${item.isPaid}, price: ${item.price}',
        );
        if (mounted) {
          setState(() {
            _refreshedItem = item;
            // Re-run payment status logic with new data
            _isPaid = item.isPaid ?? _isPaid;
            // Logic: item.isPaid is authoritative from server.
            // If null (unexpected), keep current optimistic state.

            // Update rating status too if needed
            if (item.isRated) {
              _hasRated = true;
              // Also update cache to stay in sync
              final cacheKey = 'rated_${item.contentType}_${item.id}';
              SharedPref.sharedPreferences.setBool(cacheKey, true);
            }
          });

          if (autoPlay && _isPaid) {
            print('▶️ [MovieDetails] Auto-playing after payment...');
            _handleVideoPlay();
          }
        }
      },
    );
  }

  /// Handle rating submission
  Future<void> _handleRating(int rating) async {
    if (!_isPaid) {
      AppMessages.showError(context, 'Pay to rate'.tr());
      return;
    }

    if (_hasRated) {
      AppMessages.showSuccess(
        context,
        'You have already rated this content'.tr(),
      );
      return;
    }

    AppMessages.showLoading(context);

    // Send actual content type
    final contentTypeToSend = _currentItem.contentType;

    final repo = getIt<MoviesWithSeriesRepository>();
    final result = await repo.rateContent(
      contentType: contentTypeToSend,
      objectId: _currentItem.id.toString(),
      rating: rating,
    );

    if (mounted) {
      AppMessages.hideLoading(context);

      result.fold((error) => AppMessages.showError(context, error.message), (
        success,
      ) {
        AppMessages.showSuccess(context, 'Rating submitted successfully'.tr());

        // Update local state and cache
        setState(() {
          _hasRated = true;
        });

        final cacheKey = 'rated_${_currentItem.contentType}_${_currentItem.id}';
        SharedPref.sharedPreferences.setBool(cacheKey, true);
      });
    }
  }

  @override
  void didUpdateWidget(MovieDetailsScreens oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update payment status if item changed
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.isPaid != widget.item.isPaid ||
        oldWidget.item.price != widget.item.price) {
      _refreshedItem = null; // Reset refreshed item on widget change
      _updatePaymentStatus();
    }
  }

  /// Update payment status based on item price and isPaid flag
  void _updatePaymentStatus() {
    final price = double.tryParse(_currentItem.price) ?? 0.0;
    final apiIsPaid = _currentItem.isPaid ?? false;
    final newIsPaid = price <= 0.0 || apiIsPaid;

    print(
      '🔎 [MovieDetails] _updatePaymentStatus: price=$price, apiIsPaid=$apiIsPaid, newIsPaid=$newIsPaid, old_isPaid=$_isPaid',
    );

    if (_isPaid != newIsPaid) {
      setState(() {
        _isPaid = newIsPaid;
      });
    } else {
      _isPaid = newIsPaid;
    }

    print(
      '💰 [PAYMENT STATUS] Price: $price, API isPaid: ${_currentItem.isPaid}, Final _isPaid: $_isPaid',
    );
  }

  /// Handle payment button tap
  void _handlePayment() {
    if (_isProcessingPayment) return;

    final price = double.tryParse(_currentItem.price) ?? 0.0;
    if (price <= 0.0) {
      return; // Free content
    }

    PromoCodeBottomSheet.show(
      context,
      onApply: (code, withWallet, usePoints) {
        _executePayment(code, withWallet, usePoints);
      },
      onCancel: () {},
    );
  }

  void _executePayment(String? code, bool withWallet, bool usePoints) {
    AppMessages.showLoading(context);

    setState(() {
      _isProcessingPayment = true;
    });

    ContentType contentType;
    final typeStr = _currentItem.contentType.toLowerCase();
    if (typeStr == 'series') {
      contentType = ContentType.series;
    } else if (typeStr == 'season') {
      contentType = ContentType.season;
    } else if (typeStr == 'advertise') {
      contentType = ContentType.advertise;
    } else {
      contentType = ContentType.movie;
    }

    _paymentCubit.payForContent(
      PayForContentOptions(
        contentId: _currentItem.id,
        contentType: contentType,
        withWallet: withWallet,
        code: code,
        usePoints: usePoints,
      ),
    );
  }

  Future<void> _handleVideoPlay() async {
    final price = double.tryParse(_currentItem.price) ?? 0.0;
    final isFree = price <= 0.0;

    // Check login status
    final user = UserHelper.userNotifier.value;
    final isLoggedIn = user != null;

    // Can play if: Logged In AND (Free OR Paid)
    final canPlay = isLoggedIn && (isFree || _isPaid);

    print(
      '🎬 [VIDEO PLAY] Price: $price, isFree: $isFree, isLoggedIn: $isLoggedIn, _isPaid: $_isPaid, canPlay: $canPlay',
    );

    if (!canPlay) {
      print(
        '🎬 [VIDEO PLAY] Access restricted (Guest or Unpaid) - playing trailer instead',
      );
      context.pushNamed(
        Routes.trailerPlayer,
        pathParameters: {
          'contentType': _currentItem.contentType,
          'contentId': _currentItem.id.toString(),
        },
      );
      return;
    }

    print('🎬 [VIDEO PLAY] Navigating to video player...');

    final cwCubit = context.read<ContinueWatchingCubit>();
    await cwCubit.loadContinueWatching();
    final type = _currentItem.contentType;
    final cwId = cwCubit.getContinueWatchingId(_currentItem.id, type);

    if (mounted) {
      context.pushNamed(
        Routes.videoPlayer,
        pathParameters: {
          'contentType': type,
          'contentId': _currentItem.id.toString(),
        },
        extra: {
          'onProgress': (int progress) {
            cwCubit.updateProgress(
              UpdateContinueWatchingRequest(
                contentId: _currentItem.id,
                artWorkType: type,
                progress: progress,
                continueWatchingId: cwId,
              ),
            );
          },
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Uses the getter which prefers _refreshedItem
    final item = _currentItem;
    final price = double.tryParse(item.price) ?? 0.0;
    final isFree = price <= 0.0;
    final isPaid = isFree || _isPaid;

    return BlocProvider.value(
      value: _paymentCubit,
      child: PaymentListenerWidget(
        onPaymentSuccess: () {
          print('💰 [PAYMENT LISTENER] Payment Success Called!');
          AppMessages.hideLoading(context);
          AppMessages.showSuccess(
            context,
            'Payment Successful'.tr(),
          ); // localize

          setState(() {
            _isPaid = true; // Optimistic update
            _isProcessingPayment = false;
          });

          // Trigger refresh and auto-play
          _refreshContentDetails(autoPlay: true);
          
          // Refresh profile to notify other screens (Home, etc.) via UserHelper
          getIt<ProfileCubit>().getMyProfile();
        },
        onPaymentCancel: () {
          setState(() {
            _isProcessingPayment = false;
          });
          AppMessages.hideLoading(context);
        },
        child: Scaffold(
          appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
          extendBodyBehindAppBar: true,
          body: SafeArea(
            child: Column(
              children: [
                ContentHeaderWidget(
                  imageUrl: item.displayCoverImage ?? '',
                  onPlayTap: _handleVideoPlay,
                ),
                ContentTitleSectionWidget(
                  title: item.displayName,
                  createdAt: item.createdAt,
                  contentType: item.contentType,
                  objectId: item.id,
                ),
                Expanded(
                  child: ContentDetailsSectionWidget(
                    item: item,
                    isPaid: isPaid,
                    price: price,
                    onPaymentTap: _handlePayment,
                    onRateTap: _handleRating,
                    onEpisodePlay: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
