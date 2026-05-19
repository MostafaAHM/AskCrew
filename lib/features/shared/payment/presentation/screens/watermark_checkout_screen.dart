import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/service_locator.dart';
import '../../data/repository/watermark_payment_repository.dart';
import '../cubit/watermark_payment_cubit.dart';
import 'payment_webview_screen.dart';

class WatermarkCheckoutScreen extends StatelessWidget {
  final String transactionUrl;

  const WatermarkCheckoutScreen({super.key, required this.transactionUrl});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          WatermarkPaymentCubit(getIt<WatermarkPaymentRepository>()),
      child: BlocListener<WatermarkPaymentCubit, WatermarkPaymentState>(
        listener: (context, state) {
          if (state is WatermarkPaymentVerified) {
            context.pop(true);
          }
        },
        child: PaymentWebViewScreen(
          paymentUrl: transactionUrl,
          onPaymentSuccess: () {
            // Logic handled by caller or we can pop here
          },
        ),
      ),
    );
  }
}
