import 'package:dio/dio.dart';

import 'exceptions.dart';

class ErrorsExceptionsHandler {
  static dynamic handleError(DioException error) {
    String? errorMessage;
    final responseData = error.response?.data;
    final statusCode = error.response?.statusCode;

    // Handle different error formats from backend
    if (responseData is Map<String, dynamic>) {
      // Try 'error' field first (common format: {"error": "Invalid credentials"})
      if (responseData.containsKey('error') && responseData['error'] != null) {
        errorMessage = _extractErrorMessage(responseData['error']);
      }
      // Try 'detail' field (common in FastAPI/Django REST)
      else if (responseData.containsKey('detail') &&
          responseData['detail'] != null) {
        errorMessage = _extractErrorMessage(responseData['detail']);
      }
      // Try 'message' field
      else if (responseData.containsKey('message') &&
          responseData['message'] != null) {
        errorMessage = _extractErrorMessage(responseData['message']);
      }
      // Try 'errors' field (validation errors)
      else if (responseData.containsKey('errors') &&
          responseData['errors'] != null) {
        errorMessage = _extractErrorMessage(responseData['errors']);
      }
      // Try 'non_field_errors' (Django REST framework)
      else if (responseData.containsKey('non_field_errors') &&
          responseData['non_field_errors'] != null) {
        errorMessage = _extractErrorMessage(responseData['non_field_errors']);
      }
      // Try 'error_message' field
      else if (responseData.containsKey('error_message') &&
          responseData['error_message'] != null) {
        errorMessage = _extractErrorMessage(responseData['error_message']);
      }
      // Try to extract from nested structure
      else {
        errorMessage = _extractFromNestedStructure(responseData);
      }
    } else if (responseData is String) {
      // Sometimes error is just a string
      errorMessage = responseData.trim();
    } else if (responseData != null) {
      // Fallback: convert to string
      errorMessage = responseData.toString().trim();
    }

    // For server errors (5xx), provide user-friendly messages if no message found
    if (errorMessage == null && statusCode != null && statusCode >= 500) {
      switch (statusCode) {
        case 500:
          errorMessage = 'Internal Server Error. Please try again later.';
          break;
        case 502:
          errorMessage =
              'Service temporarily unavailable. Please try again later.';
          break;
        case 503:
          errorMessage = 'Service unavailable. Please try again later.';
          break;
        default:
          errorMessage = 'Server error. Please try again later.';
      }
    }

    // Default error message if none found
    final finalErrorMessage =
        errorMessage ?? _getDefaultErrorMessage(error.type, statusCode);

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        throw CustomException(finalErrorMessage);
      case DioExceptionType.sendTimeout:
        throw CustomException(finalErrorMessage);
      case DioExceptionType.receiveTimeout:
        throw CustomException(finalErrorMessage);
      case DioExceptionType.badResponse:
        switch (error.response!.statusCode) {
          case 400:
            throw BadRequestException(finalErrorMessage);
          case 403:
            throw CustomException(finalErrorMessage, code: 403);
          case 401:
            throw UnauthorizedException(finalErrorMessage);
          case 404:
            throw NotFoundException(finalErrorMessage);
          case 409:
            throw ConflictException(finalErrorMessage);
          case 422:
            throw CustomException(finalErrorMessage, code: 422);
          case 500:
            throw InternalServerErrorException(finalErrorMessage);
          case 501:
            throw InternalServerErrorException(finalErrorMessage);
          case 502:
            throw InternalServerErrorException(finalErrorMessage);
          case 503:
            throw InternalServerErrorException(finalErrorMessage);
          default:
            throw CustomException(finalErrorMessage);
        }
      case DioExceptionType.cancel:
        throw const CustomException('Request cancelled');
      case DioExceptionType.unknown:
        // Check if it's a network error
        if (error.error?.toString().contains('SocketException') == true ||
            error.error?.toString().contains('Network') == true) {
          throw CustomException(
            'No internet connection. Please check your network.',
          );
        }
        throw CustomException(finalErrorMessage);
      default:
        throw CustomException(finalErrorMessage);
    }
  }

  /// Get default error message based on error type and status code
  static String _getDefaultErrorMessage(
    DioExceptionType? type,
    int? statusCode,
  ) {
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Unauthorized. Please login again.';
        case 403:
          return 'Access denied. You don\'t have permission.';
        case 404:
          return 'Resource not found.';
        case 409:
          return 'Conflict occurred. Please try again.';
        case 422:
          return 'Validation error. Please check your input.';
        case 500:
          return 'Internal server error. Please try again later.';
        case 502:
          return 'Service temporarily unavailable. Please try again later.';
        case 503:
          return 'Service unavailable. Please try again later.';
      }
    }

    switch (type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout. Please try again.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.unknown:
        return 'Network error. Please check your internet connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Extract error message from various formats
  /// Handles: String, List, Map, and other types
  static String? _extractErrorMessage(dynamic error) {
    if (error == null) return null;

    // Handle String directly (most common case: "Invalid credentials")
    if (error is String) {
      final trimmed = error.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    // Handle List of errors
    else if (error is List) {
      if (error.isEmpty) return null;

      // Get first error message
      final firstError = error[0];
      if (firstError == null) return null;

      if (firstError is String) {
        return firstError.trim();
      } else if (firstError is Map) {
        // Try to extract message from map
        if (firstError.containsKey('message')) {
          return _extractErrorMessage(firstError['message']);
        } else if (firstError.containsKey('error')) {
          return _extractErrorMessage(firstError['error']);
        } else if (firstError.containsKey('detail')) {
          return _extractErrorMessage(firstError['detail']);
        }
        // If map has only one key-value, return the value
        if (firstError.length == 1) {
          final value = firstError.values.first;
          return value?.toString().trim();
        }
        return firstError.toString().trim();
      }
      return firstError.toString().trim();
    }
    // Handle Map of errors
    else if (error is Map) {
      // Try common error message keys
      if (error.containsKey('message') && error['message'] != null) {
        return _extractErrorMessage(error['message']);
      } else if (error.containsKey('error') && error['error'] != null) {
        return _extractErrorMessage(error['error']);
      } else if (error.containsKey('detail') && error['detail'] != null) {
        return _extractErrorMessage(error['detail']);
      } else if (error.containsKey('error_message') &&
          error['error_message'] != null) {
        return _extractErrorMessage(error['error_message']);
      }

      // If map has only one key-value, return the value
      if (error.length == 1) {
        final value = error.values.first;
        if (value != null) {
          return _extractErrorMessage(value);
        }
      }

      // Last resort: convert map to string
      return error.toString().trim();
    }

    // Fallback: convert to string and trim
    final errorStr = error.toString().trim();
    return errorStr.isEmpty ? null : errorStr;
  }

  /// Extract error from nested structure (for validation errors)
  static String? _extractFromNestedStructure(Map<String, dynamic> data) {
    // Look for common error patterns
    for (var key in data.keys) {
      final value = data[key];
      if (value is String && value.isNotEmpty) {
        return value;
      } else if (value is List && value.isNotEmpty) {
        final firstItem = value[0];
        if (firstItem is String) {
          return '$key: $firstItem';
        } else if (firstItem is Map) {
          return _extractErrorMessage(firstItem);
        }
      } else if (value is Map) {
        final nestedError = _extractFromNestedStructure(
          value as Map<String, dynamic>,
        );
        if (nestedError != null) {
          return nestedError;
        }
      }
    }
    return null;
  }
}
