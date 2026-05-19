import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/fields/custom_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/helpers/messages.dart';
import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../../../../../core/widgets/buttons/custom_button.dart';
import '../../data/model/payment_gateway/payment_model.dart';
import '../../data/model/server/save_payment_status_options.dart';
import '../../data/model/server/subscribe_to_package_options.dart';
import '../cubit/payment_cubit.dart';
import '../widgets/payment_options.dart';

enum PaymentMethod { card, wallet }

enum PaymentType {
  package(title: AppStrings.package),
  promotion(title: AppStrings.promoteAd);

  final String title;
  const PaymentType({required this.title});
}

class PaymentScreenArgs {
  final PaymentType paymentType;
  final String? id;
  final String? adId;
  final Function()? onSuccess;
  const PaymentScreenArgs({
    required this.paymentType,
    this.id,
    this.adId,
    this.onSuccess,
  });
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.args});
  final PaymentScreenArgs args;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  ValueNotifier<PaymentMethod?> paymentMethod = ValueNotifier(null);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<PaymentCubit>().subscribeToPackage(
        SubscribeToPackagePromotionOptions(
          id: widget.args.id ?? '',
          type: widget.args.paymentType,
          adId: widget.args.adId ?? '',
        ),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return BlocListener<PaymentCubit, PaymentState>(
          listener: (context, state) {
            if (state is PaymentLoading) {
              AppMessages.showLoading(context);
            } else if (state is PaymentInitializationSuccess) {
              AppMessages.hideLoading(context);
            } else if (state is PaymentTransactionSuccess) {
              AppMessages.hideLoading(context);
            } else if (state is PaymentSaveStatusSuccess) {
              AppMessages.hideLoading(context);
              AppMessages.showSuccess(context, 'payment_success'.tr());
              widget.args.onSuccess?.call();
            } else if (state is PaymentFailure) {
              AppMessages.hideLoading(context);
              AppMessages.showError(context, state.message);
            }
          },
          child: Scaffold(
            appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: 24.h,
                    bottom: 100.h, // Space for bottom button
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.chooseYourPaymentMethod.tr(),
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 24.sp,
                        ),
                      ),
                      8.height,
                      Text(
                        "Secure and easy payments select your preferred way to complete the subscription."
                            .tr(),
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 13.sp,
                        ),
                      ),
                      24.height,
                      CustomTextField(
                        label: "Discount code",
                        hint: "Enter discount code",
                      ),
                      16.height,
                      PaymentOptions(selectedOption: paymentMethod),
                      12.height,
                      // Add more payment options here if needed
                    ],
                  ),
                ),
                BlocBuilder<PaymentCubit, PaymentState>(
                  builder: (context, state) {
                    return ValueListenableBuilder(
                      valueListenable: paymentMethod,
                      builder: (context, value, child) => Positioned(
                        left: 16.w,
                        right: 16.w,
                        bottom: paymentMethod.value != null ? 20.h : -100.h,
                        child: AnimatedOpacity(
                          opacity: paymentMethod.value != null ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: CustomButton.filled(
                            height: 50.h,
                            width: double.infinity,
                            text: AppStrings.confirm.tr(),
                            isBackgroundGradient: true,
                            onTap: () {
                            if (paymentMethod.value == null) {
                              AppMessages.showError(
                                context,
                                AppStrings.selectPaymentMethod.tr(),
                              );
                              return;
                            }
                            context.read<PaymentCubit>().payWithCard(
                              CardPaymentRequestModel(
                                onPayment: (p0) async {
                                  await context
                                      .read<PaymentCubit>()
                                      .savePaymentResponse(
                                        SavePaymentStatusOptions(
                                          type: widget.args.paymentType,
                                          transactionId: p0.transactionID ?? '',
                                          orderId:
                                              context
                                                  .read<PaymentCubit>()
                                                  .subscriptionResponse
                                                  ?.orderId ??
                                              '',
                                        ),
                                      );
                                },
                                currency:
                                    context
                                        .read<PaymentCubit>()
                                        .subscriptionResponse
                                        ?.currency ??
                                    '',
                                amount: context
                                    .read<PaymentCubit>()
                                    .subscriptionResponse
                                    ?.amount,
                              ),
                            );
                          },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
