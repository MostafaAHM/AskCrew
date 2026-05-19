import 'package:aflam/features/shared/payment/data/repository/payment_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_paymob/flutter_paymob.dart';

import '../../../../../config/routes/app_router.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/models/base_response_model.dart';
import '../../../../../core/network/network_request.dart';
import '../model/payment_gateway/initialize_payment.dart';
import '../model/payment_gateway/payment_model.dart';
import '../model/payment_gateway/tap_payment_charge_response.dart';
import '../model/server/pay_for_content_options.dart';
import '../model/server/save_payment_status_options.dart';
import '../model/server/subscribe_to_package_options.dart';
import '../model/server/subscription_response_model.dart';
import '../model/server/wallet_add_options.dart';
import '../model/server/pay_for_booking_options.dart';

class PaymentRepositoryImpl extends PaymentRepository {
  @override
  Future<Either<CustomException, bool>> initializePayment(
    InitializePaymentModel options,
  ) async {
    final result = await exceptionHandler(() async {
      debugPrint('initializePayment');
      // debugPrint('initializePayment ${options.apiKey}');
      // debugPrint('initializePayment ${options.integrationId}');
      // debugPrint('initializePayment ${options.iFrameId}');
      bool response = await FlutterPaymob.instance.initialize(
        apiKey: '',
        integrationID: 45465,
        iFrameID: 5456,
        // apiKey: options.apiKey,
        // integrationID: options.integrationId,
        // walletIntegrationId: options.walletIntegrationId,
        // iFrameID: options.iFrameId,
      );
      return response;
    });
    return result;
  }

  @override
  Future<Either<CustomException, dynamic>> payWithCard(
    CardPaymentRequestModel options,
  ) async {
    final result = await exceptionHandler(() async {
      debugPrint('initializePayment');
      debugPrint('initializePayment ${options.currency}');
      debugPrint('initializePayment ${options.amount}');
      await FlutterPaymob.instance.payWithCard(
        context: AppRouter.appNavigatorKey.currentContext!,
        currency: options.currency,
        amount: ((options.amount ?? 0.0) * 100).ceilToDouble(),
        onPayment: options.onPayment,
      );
    });
    return result;
  }

  @override
  Future<Either<CustomException, dynamic>> payWithWallet(
    WalletPaymentRequestModel options,
  ) async {
    final result = await exceptionHandler(() async {
      await FlutterPaymob.instance.payWithWallet(
        number: options.walletNumber,
        context: AppRouter.appNavigatorKey.currentContext!,
        currency: options.currency,
        amount: ((options.amount ?? 0.0) * 100).floorToDouble(),
        onPayment: options.onPayment,
      );
    });
    return result;
  }

  @override
  Future<Either<CustomException, SubscriptionResponseModel>> subscribeToPackage(
    SubscribeToPackagePromotionOptions options,
  ) async {
    final result = await exceptionHandler(() async {
      SubscriptionResponseModel response = await dioService.callApi(
        NetworkRequest(
          options.url,
          method: RequestMethod.post,
          body: options.toJson(),
          requestWithOutToken: false,
        ),
        mapper: (json) => SubscriptionResponseModel.fromJson(json['response']),
      );

      return response;
    });
    return result;
  }

  @override
  Future<Either<CustomException, BaseResponseModel>> savePaymentResponse(
    SavePaymentStatusOptions options,
  ) async {
    final result = await exceptionHandler(() async {
      BaseResponseModel response = await dioService.callApi(
        NetworkRequest(
          options.url,
          method: RequestMethod.post,
          body: options.toJson(),
          requestWithOutToken: false,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );

      return response;
    });
    return result;
  }

  @override
  Future<Either<CustomException, TapPaymentChargeResponse>> payForContent(
    PayForContentOptions options,
  ) async {
    print('🔴 [PAYMENT REPO] ========== payForContent Repository ==========');
    print('🔴 [PAYMENT REPO] Content ID: ${options.contentId}');
    print('🔴 [PAYMENT REPO] Content Type: ${options.contentType.value}');
    print('🔴 [PAYMENT REPO] With Wallet: ${options.withWallet}');
    print('🔴 [PAYMENT REPO] Options JSON: ${options.toJson()}');

    final result = await exceptionHandler(() async {
      print('🔴 [PAYMENT REPO] Creating FormData from options...');
      final formData = FormData.fromMap(options.toJson());
      print('🔴 [PAYMENT REPO] FormData created successfully');

      print('🔴 [PAYMENT REPO] Calling API: ${AppUrls.payForContent}');
      print('🔴 [PAYMENT REPO] Method: POST');
      print('🔴 [PAYMENT REPO] Is FormData: true');
      print('🔴 [PAYMENT REPO] Request with token: true');

      TapPaymentChargeResponse response = await dioService.callApi(
        NetworkRequest(
          AppUrls.payForContent,
          method: RequestMethod.post,
          formDataBody: formData,
          isFormData: true,
          requestWithOutToken: false,
        ),
        mapper: (json) {
          print('🔴 [PAYMENT REPO] ========== Response Received ==========');
          print('🔴 [PAYMENT REPO] Response type: ${json.runtimeType}');
          print(
            '🔴 [PAYMENT REPO] Parsing response to TapPaymentChargeResponse...',
          );

          final parsed = TapPaymentChargeResponse.fromJson(
            json is Map<String, dynamic> ? json : json as Map<String, dynamic>,
          );

          print('🔴 [PAYMENT REPO] Response parsed successfully');
          print('🔴 [PAYMENT REPO] Response ID: ${parsed.id}');
          print('🔴 [PAYMENT REPO] Response Status: ${parsed.status}');
          print('🔴 [PAYMENT REPO] Response Amount: ${parsed.amount}');
          print('🔴 [PAYMENT REPO] Response Currency: ${parsed.currency}');
          print('🔴 [PAYMENT REPO] Checkout URL: ${parsed.checkoutUrl}');
          print(
            '🔴 [PAYMENT REPO] Transaction URL: ${parsed.transaction?.url}',
          );
          print('🔴 [PAYMENT REPO] Redirect URL: ${parsed.redirect?.url}');
          print(
            '🔴 [PAYMENT REPO] Redirect Status: ${parsed.redirect?.status}',
          );

          return parsed;
        },
      );

      print('🔴 [PAYMENT REPO] ✅ API call completed successfully');
      return response;
    });

    result.fold(
      (failure) {
        print('🔴 [PAYMENT REPO] ❌ Exception occurred');
        print('🔴 [PAYMENT REPO] Error message: ${failure.message}');
      },
      (success) {
        print('🔴 [PAYMENT REPO] ✅ Success response');
      },
    );

    return result;
  }

  @override
  Future<Either<CustomException, TapPaymentChargeResponse>> walletAdd(
    WalletAddOptions options,
  ) async {
    print('💰 [WALLET ADD] ========== walletAdd Repository ==========');
    print('💰 [WALLET ADD] Amount: ${options.amount}');
    print('💰 [WALLET ADD] Name: ${options.name}');

    final result = await exceptionHandler(() async {
      print('💰 [WALLET ADD] Creating FormData from options...');
      final formData = options.toFormData();
      print('💰 [WALLET ADD] FormData created successfully');

      print('💰 [WALLET ADD] Calling API: ${AppUrls.walletAdd}');
      print('💰 [WALLET ADD] Method: POST');
      print('💰 [WALLET ADD] Is FormData: true');

      TapPaymentChargeResponse response = await dioService.callApi(
        NetworkRequest(
          AppUrls.walletAdd,
          method: RequestMethod.post,
          formDataBody: formData,
          isFormData: true,
          requestWithOutToken: false,
        ),
        mapper: (json) {
          print('💰 [WALLET ADD] ========== Response Received ==========');
          final parsed = TapPaymentChargeResponse.fromJson(
            json is Map<String, dynamic> ? json : json as Map<String, dynamic>,
          );

          print('💰 [WALLET ADD] Response parsed successfully');
          print('💰 [WALLET ADD] Response ID: ${parsed.id}');
          print('💰 [WALLET ADD] Response Status: ${parsed.status}');
          print('💰 [WALLET ADD] Checkout URL: ${parsed.checkoutUrl}');

          return parsed;
        },
      );

      print('💰 [WALLET ADD] ✅ API call completed successfully');
      return response;
    });

    return result;
  }

  @override
  Future<Either<CustomException, TapPaymentChargeResponse>> payForBooking(
    PayForBookingOptions options,
  ) async {
    print('📅 [PAYMENT REPO] ========== payForBooking Repository ==========');
    print('📅 [PAYMENT REPO] Booking ID: ${options.bookingId}');
    print('📅 [PAYMENT REPO] Options JSON: ${options.toJson()}');

    final result = await exceptionHandler(() async {
      print('📅 [PAYMENT REPO] Creating FormData from options...');
      final formData = FormData.fromMap(options.toJson());
      print('📅 [PAYMENT REPO] FormData created successfully');

      print('📅 [PAYMENT REPO] Calling API: ${AppUrls.payForBooking}');
      print('📅 [PAYMENT REPO] Method: POST');
      print('📅 [PAYMENT REPO] Is FormData: true');
      print('📅 [PAYMENT REPO] Request with token: true');

      TapPaymentChargeResponse response = await dioService.callApi(
        NetworkRequest(
          AppUrls.payForBooking,
          method: RequestMethod.post,
          formDataBody: formData,
          isFormData: true,
          requestWithOutToken: false,
        ),
        mapper: (json) {
          print('📅 [PAYMENT REPO] ========== Response Received ==========');
          print('📅 [PAYMENT REPO] Response type: ${json.runtimeType}');

          if (json is Map<String, dynamic> && json.containsKey('errors')) {
            print('📅 [PAYMENT REPO] ❌ Error found in response body');
            final errors = json['errors'] as List;
            if (errors.isNotEmpty) {
              final error = errors.first;
              print(
                '📅 [PAYMENT REPO] Error description: ${error['description']}',
              );
              throw CustomException(
                error['description']?.toString() ?? 'Payment failed',
              );
            }
          }

          print(
            '📅 [PAYMENT REPO] Parsing response to TapPaymentChargeResponse...',
          );

          final parsed = TapPaymentChargeResponse.fromJson(
            json is Map<String, dynamic> ? json : json as Map<String, dynamic>,
          );

          print('📅 [PAYMENT REPO] Response parsed successfully');
          print('📅 [PAYMENT REPO] Response ID: ${parsed.id}');
          print('📅 [PAYMENT REPO] Response Status: ${parsed.status}');
          print('📅 [PAYMENT REPO] Response Amount: ${parsed.amount}');
          print('📅 [PAYMENT REPO] Response Currency: ${parsed.currency}');
          print('📅 [PAYMENT REPO] Checkout URL: ${parsed.checkoutUrl}');
          print(
            '📅 [PAYMENT REPO] Transaction URL: ${parsed.transaction?.url}',
          );
          print('📅 [PAYMENT REPO] Redirect URL: ${parsed.redirect?.url}');
          print(
            '📅 [PAYMENT REPO] Redirect Status: ${parsed.redirect?.status}',
          );

          return parsed;
        },
      );

      print('📅 [PAYMENT REPO] ✅ API call completed successfully');
      return response;
    });

    result.fold(
      (failure) {
        print('📅 [PAYMENT REPO] ❌ Exception occurred');
        print('📅 [PAYMENT REPO] Error message: ${failure.message}');
      },
      (success) {
        print('📅 [PAYMENT REPO] ✅ Success response');
      },
    );

    return result;
  }
}
