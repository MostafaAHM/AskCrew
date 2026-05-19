import 'package:aflam/core/network/extensions.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:alice/alice.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../config/routes/app_router.dart';
import '../../config/routes/routes.dart';
import '../app_config/app_urls.dart';
import '../app_config/constants.dart';
import '../app_config/prefs_keys.dart';
import '../error/errors_exceptions_handler.dart';
import '../helpers/secure_local_storage.dart';
import '../helpers/user_helper.dart';
import 'interceptors.dart';
import 'network_request.dart';
import 'network_service.dart';

class DioService implements NetworkService {
  late Dio _dio;
  final CookieJar cookieJar;
  late CustomInterceptor _customInterceptor;

  static final Alice alice = Alice(
    configuration: AliceConfiguration(
      showShareButton: true,
      navigatorKey: AppRouter.appNavigatorKey,
      showInspectorOnShake: kDebugMode,
      showNotification: false,
    ),
  );

  DioService({required this.cookieJar}) {
    _initDio();
  }

  void _initDio() {
    _dio = Dio()
      ..options.baseUrl = AppUrls.baseApi
      ..options.connectTimeout = const Duration(seconds: 30)
      ..options.receiveTimeout = const Duration(seconds: 30)
      ..options.followRedirects = true
      ..options.maxRedirects = 5
      ..options.validateStatus = (status) {
        if (status == 401 || status == 500) return false;
        return status! < 400;
      }
      ..options.responseType = ResponseType.json;

    _dio.interceptors.add(CookieManager(cookieJar));

    if (kDebugMode) {
      final aliceDioAdapter = AliceDioAdapter();
      alice.addAdapter(aliceDioAdapter);
      _dio.interceptors.add(aliceDioAdapter);
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
        ),
      );
    }

    _customInterceptor = CustomInterceptor(dio: _dio, cookieJar: cookieJar);
    _dio.interceptors.add(_customInterceptor);
  }

  Future<bool> refreshToken() async {
    return await _customInterceptor.refreshToken();
  }

  Future<void> logout() async {
    await SecureLocalStorage.delete(PrefsKeys.token);
    await SecureLocalStorage.delete(PrefsKeys.user);
    await cookieJar.deleteAll();
    UserHelper.clear();
    _dio.options.headers.clear();
    GoRouter.of(
      AppRouter.appNavigatorKey.currentContext!,
    ).pushReplacementNamed(Routes.login);
  }

  void clearHeaders() {
    _dio.options.headers.clear();
  }

  Future<void> clearCookies() async {
    await cookieJar.deleteAll();
  }

  Future<Map<String, dynamic>> _getDefaultHeaders(bool isWithoutToken) async {
    final Map<String, dynamic> headers = {};
    if (isWithoutToken != true) {
      final token = await SecureLocalStorage.read(PrefsKeys.token);
      if (token?.isNotEmpty == true) {
        headers[AppConstants.authorization] = '${AppConstants.bearer} $token';
      }
    }
    return headers;
  }

  @override
  Future<Model> callApi<Model>(
    NetworkRequest networkRequest, {
    Model Function(dynamic json)? mapper,
  }) async {
    try {
      await networkRequest.prepareRequestData();
      final response = await _dio.request(
        networkRequest.path,
        data: networkRequest.hasBodyAndProgress()
            ? networkRequest.isFormData
                  ? networkRequest.formDataBody
                  : networkRequest.body
            : networkRequest.body,
        queryParameters: networkRequest.queryParameters,
        onSendProgress: networkRequest.hasBodyAndProgress()
            ? networkRequest.onSendProgress
            : null,
        onReceiveProgress: networkRequest.hasBodyAndProgress()
            ? networkRequest.onReceiveProgress
            : null,
        options: Options(
          method: networkRequest.asString(),
          headers:
              networkRequest.headers ??
              await _getDefaultHeaders(networkRequest.requestWithOutToken),
        ),
      );

      if (mapper != null &&
          (response.statusCode == 200 ||
              response.statusCode == 201 ||
              response.statusCode == 204)) {
        return mapper(response.data);
      }

      return response.data;
    } on DioException catch (e) {
      return ErrorsExceptionsHandler.handleError(e);
    }
  }
}
