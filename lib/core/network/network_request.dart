import 'package:dio/dio.dart';

enum RequestMethod { get, post, put, delete, patch }

class NetworkRequest<GenericModel> {
  final String path;
  final RequestMethod method;
  final dynamic body;
  final FormData? formDataBody;
  final Map<String, dynamic>? queryParameters;
  final Map<String, String>? headers;
  final bool requestWithOutToken;
  bool isFormData;
  final ProgressCallback? onSendProgress;
  final ProgressCallback? onReceiveProgress;

  NetworkRequest(
    this.path, {
    required this.method,
    this.body,
    this.formDataBody,
    this.queryParameters,
    this.headers,
    this.requestWithOutToken = false,
    this.isFormData = false,
    this.onSendProgress,
    this.onReceiveProgress,
  });
  NetworkRequest copyWith({
    String? path,
    RequestMethod? method,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool? requestWithOutToken,
    bool? isFormData,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return NetworkRequest(
      path ?? this.path,
      method: method ?? this.method,
      body: body ?? this.body,
      queryParameters: queryParameters ?? this.queryParameters,
      headers: headers ?? this.headers,
      requestWithOutToken: requestWithOutToken ?? this.requestWithOutToken,
      isFormData: isFormData ?? this.isFormData,
      onSendProgress: onSendProgress ?? this.onSendProgress,
      onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    );
  }
}
