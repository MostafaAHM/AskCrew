import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/features/shared/payment/presentation/cubit/payment_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/routes.dart';

/// Widget to handle payment state changes
class PaymentListenerWidget extends StatelessWidget {
  final VoidCallback onPaymentSuccess;
  final VoidCallback onPaymentCancel;
  final Widget child;

  const PaymentListenerWidget({
    super.key,
    required this.onPaymentSuccess,
    required this.onPaymentCancel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) {
        print(
          '🎯 [MOVIE DETAILS] BlocListener received state: ${state.runtimeType}',
        );

        if (state is PaymentLoading) {
          print('🎯 [MOVIE DETAILS] PaymentLoading state received');
        } else if (state is PaymentContentSuccess) {
          _handlePaymentSuccess(context, state);
        } else if (state is PaymentFailure) {
          _handlePaymentFailure(context, state);
        }
      },
      child: child,
    );
  }

  void _handlePaymentSuccess(
    BuildContext context,
    PaymentContentSuccess state,
  ) {
    print(
      '🎯 [MOVIE DETAILS] PaymentContentSuccess received, navigating to WebView...',
    );
    AppMessages.hideLoading(context);
    final checkoutUrl = state.response.checkoutUrl;
    print('🎯 [MOVIE DETAILS] Checkout URL: $checkoutUrl');

    if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          print(
            '🎯 [MOVIE DETAILS] Navigating to paymentWebView with URL: $checkoutUrl',
          );
          context.pushNamed(
            Routes.paymentWebView,
            extra: {
              'paymentUrl': checkoutUrl,
              'onPaymentSuccess': () {
                print('🎯 [MOVIE DETAILS] Payment success callback called');
                if (context.mounted) {
                  onPaymentSuccess();
                  context.pop();
                  AppMessages.showSuccess(context, 'Payment successful'.tr());
                }
              },
              'onPaymentCancel': () {
                print('🎯 [MOVIE DETAILS] Payment cancel callback called');
                if (context.mounted) {
                  onPaymentCancel();
                }
              },
            },
          );
        } else {
          print('🎯 [MOVIE DETAILS] Widget not mounted, cannot navigate');
        }
      });
    } else {
      print('🎯 [MOVIE DETAILS] Checkout URL is null or empty');
      onPaymentCancel();
      AppMessages.showError(context, 'Payment URL not available'.tr());
    }
  }

  void _handlePaymentFailure(BuildContext context, PaymentFailure state) {
    print('🎯 [MOVIE DETAILS] PaymentFailure received: ${state.message}');
    AppMessages.hideLoading(context);
    onPaymentCancel();
    AppMessages.showError(context, state.message);
  }
}
