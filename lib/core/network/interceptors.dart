import 'dart:developer';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/app_router.dart';
import '../../config/routes/routes.dart';
import '../app_config/app_urls.dart';
import '../app_config/prefs_keys.dart';
import '../helpers/secure_local_storage.dart';

class CustomInterceptor extends Interceptor {
  final Dio dio;
  final CookieJar cookieJar;
  bool isRefreshing = false;
  final List<Map<String, dynamic>> _failedRequests = [];

  CustomInterceptor({required this.dio, required this.cookieJar});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll({
      HttpHeaders.acceptHeader: ContentType.json,
      'Accept-Language':
          AppRouter.appNavigatorKey.currentContext!.locale.languageCode,
      'time-zone': DateTime.now().timeZoneName,
    });

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (_isAuthEndpoint(err.requestOptions.path)) {
        handler.next(err);
        return;
      }

      _failedRequests.add({'err': err, 'handler': handler});

      if (!isRefreshing) {
        isRefreshing = true;

        final ok = await _refreshToken();

        isRefreshing = false;

        if (ok) {
          final newToken = await SecureLocalStorage.read(PrefsKeys.token);
          await _retryFailedRequests(newToken ?? '');
        } else {
          // If refresh fails, pass the error through instead of just logging out
          // This allows the error handler to process it and show the error message
          for (final failed in _failedRequests) {
            failed['handler'].reject(failed['err']);
          }
          _failedRequests.clear();
          _logout();
        }
      }
    } else {
      handler.next(err);
    }
  }

  /// Check if the request path is an authentication endpoint
  /// Auth endpoints should not trigger token refresh - their errors should be shown to the user
  bool _isAuthEndpoint(String path) {
    final authEndpoints = [
      AppUrls.login,
      AppUrls.viewerSignup,
      AppUrls.enterpriseSignup,
      AppUrls.studentSignup,
      AppUrls.resetPassword,
      AppUrls.resendSms,
      AppUrls.activate,
    ];

    return authEndpoints.any(
      (endpoint) => path.contains(endpoint) || endpoint.contains(path),
    );
  }

  Future<bool> _refreshToken() async {
    return await refreshToken();
  }

  /// Public method to refresh token - can be called from outside the interceptor
  Future<bool> refreshToken() async {
    try {
      final uri = Uri.parse(AppUrls.refreshToken);
      final cookies = await cookieJar.loadForRequest(uri);
      log('DEBUG: Cookies for $uri: $cookies');

      if (cookies.isEmpty) {
        log(
          'DEBUG: No cookies found! User might need to re-login to save the refresh token cookie.',
        );
        return false;
      }

      final response = await dio.post(AppUrls.refreshToken);

      if (response.statusCode == 200) {
        final data = response.data;
        String? access;

        if (data['tokens'] != null && data['tokens']['access'] != null) {
          access = data['tokens']['access'];
        } else if (data['token'] != null && data['token']['access'] != null) {
          access = data['token']['access'];
        } else if (data['accessToken'] != null) {
          access = data['accessToken'];
        }

        if (access != null) {
          await SecureLocalStorage.write(PrefsKeys.token, access);
          return true;
        }
      }
      return false;
    } catch (e) {
      log('Refresh token failed: $e');
      return false;
    }
  }

  Future<void> _retryFailedRequests(String token) async {
    for (final failed in _failedRequests) {
      final RequestOptions req = failed['err'].requestOptions;

      req.headers['Authorization'] = 'Bearer $token';

      try {
        final response = await dio.fetch(req);
        failed['handler'].resolve(response);
      } catch (e) {
        failed['handler'].reject(e);
      }
    }

    _failedRequests.clear();
  }

  Future<void> _logout() async {
    await SecureLocalStorage.delete(PrefsKeys.token);
    // await SecureLocalStorage.delete(PrefsKeys.refreshToken); // No longer used

    await cookieJar.deleteAll();

    dio.options.headers.remove('Authorization');

    GoRouter.of(
      AppRouter.appNavigatorKey.currentContext!,
    ).pushReplacementNamed(Routes.login);
  }
}
