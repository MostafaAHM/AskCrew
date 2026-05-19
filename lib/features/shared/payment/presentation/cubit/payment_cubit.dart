import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../data/model/payment_gateway/initialize_payment.dart';
import '../../data/model/payment_gateway/payment_model.dart';
import '../../data/model/payment_gateway/tap_payment_charge_response.dart';
import '../../data/model/server/pay_for_content_options.dart';
import '../../data/model/server/save_payment_status_options.dart';
import '../../data/model/server/subscribe_to_package_options.dart';
import '../../data/model/server/subscription_response_model.dart';
import '../../data/model/server/wallet_add_options.dart';
import '../../data/model/server/pay_for_booking_options.dart';
import '../../data/repository/payment_repository.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository repository;

  PaymentCubit(this.repository) : super(PaymentInitial());
  SubscriptionResponseModel? subscriptionResponse;

  subscribeToPackage(SubscribeToPackagePromotionOptions options) async {
    emit(PaymentLoading());
    final result = await repository.subscribeToPackage(options);
    result.fold((failure) => emit(PaymentFailure(failure.message)), (success) {
      subscriptionResponse = success;
      initializePayment(options.id);
    });
  }

  // Initialization
  Future<void> initializePayment(String id) async {
    emit(PaymentLoading());
    final result = await repository.initializePayment(
      InitializePaymentModel(packageId: id),
    );
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (success) => emit(PaymentInitializationSuccess(success)),
    );
  }

  // Pay with card
  Future<void> payWithCard(CardPaymentRequestModel model) async {
    emit(PaymentLoading());
    final result = await repository.payWithCard(model);
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (response) => emit(PaymentTransactionSuccess(response)),
    );
  }

  // Pay with wallet
  Future<void> payWithWallet(WalletPaymentRequestModel model) async {
    emit(PaymentLoading());
    final result = await repository.payWithWallet(model);
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (response) => emit(PaymentTransactionSuccess(response)),
    );
  }

  // Save payment result to server
  Future<void> savePaymentResponse(SavePaymentStatusOptions options) async {
    emit(PaymentLoading());
    final result = await repository.savePaymentResponse(options);
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (response) => emit(PaymentSaveStatusSuccess()),
    );
  }

  // Pay for content
  Future<void> payForContent(PayForContentOptions options) async {
    print('🟠 [PAYMENT CUBIT] ========== payForContent called ==========');
    print('🟠 [PAYMENT CUBIT] Content ID: ${options.contentId}');
    print('🟠 [PAYMENT CUBIT] Content Type: ${options.contentType.value}');
    print('🟠 [PAYMENT CUBIT] With Wallet: ${options.withWallet}');

    print('🟠 [PAYMENT CUBIT] Emitting PaymentLoading state...');
    emit(PaymentLoading());

    print('🟠 [PAYMENT CUBIT] Calling repository.payForContent...');
    final result = await repository.payForContent(options);

    print('🟠 [PAYMENT CUBIT] Repository response received');
    result.fold(
      (failure) {
        print('🟠 [PAYMENT CUBIT] ❌ Payment failed');
        print('🟠 [PAYMENT CUBIT] Error message: ${failure.message}');
        print('🟠 [PAYMENT CUBIT] Emitting PaymentFailure state...');
        emit(PaymentFailure(failure.message));
      },
      (response) {
        print('🟠 [PAYMENT CUBIT] ✅ Payment successful');
        print('🟠 [PAYMENT CUBIT] Response ID: ${response.id}');
        print('🟠 [PAYMENT CUBIT] Response Status: ${response.status}');
        print('🟠 [PAYMENT CUBIT] Response Amount: ${response.amount}');
        print('🟠 [PAYMENT CUBIT] Response Currency: ${response.currency}');
        print('🟠 [PAYMENT CUBIT] Checkout URL: ${response.checkoutUrl}');
        print(
          '🟠 [PAYMENT CUBIT] Transaction URL: ${response.transaction?.url}',
        );
        print('🟠 [PAYMENT CUBIT] Redirect URL: ${response.redirect?.url}');
        print('🟠 [PAYMENT CUBIT] Emitting PaymentContentSuccess state...');
        emit(PaymentContentSuccess(response));
      },
    );

    print('🟠 [PAYMENT CUBIT] payForContent completed');
  }

  // Wallet Add (Top-up)
  Future<void> walletAdd(WalletAddOptions options) async {
    print('💰 [WALLET ADD CUBIT] ========== walletAdd called ==========');
    print('💰 [WALLET ADD CUBIT] Amount: ${options.amount}');
    print('💰 [WALLET ADD CUBIT] Name: ${options.name}');

    emit(PaymentLoading());

    final result = await repository.walletAdd(options);

    result.fold(
      (failure) {
        print('💰 [WALLET ADD CUBIT] ❌ Failed: ${failure.message}');
        emit(PaymentFailure(failure.message));
      },
      (response) {
        print('💰 [WALLET ADD CUBIT] ✅ Success');
        print('💰 [WALLET ADD CUBIT] Checkout URL: ${response.checkoutUrl}');
        emit(PaymentContentSuccess(response));
      },
    );
  }

  // Pay for booking
  Future<void> payForBooking(PayForBookingOptions options) async {
    print('📅 [PAYMENT CUBIT] ========== payForBooking called ==========');
    print('📅 [PAYMENT CUBIT] Booking ID: ${options.bookingId}');

    emit(PaymentLoading());

    final result = await repository.payForBooking(options);

    result.fold(
      (failure) {
        print('📅 [PAYMENT CUBIT] ❌ Payment failed');
        print('📅 [PAYMENT CUBIT] Error message: ${failure.message}');
        emit(PaymentFailure(failure.message));
      },
      (response) {
        print('📅 [PAYMENT CUBIT] ✅ Payment successful');
        print('📅 [PAYMENT CUBIT] Checkout URL: ${response.checkoutUrl}');
        emit(PaymentContentSuccess(response));
      },
    );
  }
}
