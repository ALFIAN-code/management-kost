import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  /// Main factory to convert Dio errors into AppException
  factory AppException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return AppException("Connection timeout. Please try again.", code: 408);

      case DioExceptionType.receiveTimeout:
        return AppException(
          "Receive timeout. Server took too long to respond.",
          code: 408,
        );

      case DioExceptionType.sendTimeout:
        return AppException(
          "Send timeout. Please check your connection.",
          code: 408,
        );

      case DioExceptionType.badResponse:
        final response = error.response;
        final statusCode = response?.statusCode;
        final data = response?.data;
        final msg = _parseServerMessage(data, statusCode);
        return AppException(msg, code: statusCode, details: data);

      case DioExceptionType.connectionError:
        return AppException(
          "Unable to connect to the server. Please check your network or try again later.",
          code: 503,
        );

      case DioExceptionType.cancel:
        return AppException("Request cancelled by user.");

      default:
        return AppException("Unexpected error: ${error.message ?? 'Unknown'}");
    }
  }

  /// Additional factory for non-Dio errors (parsing, logic, etc.)
  factory AppException.other(dynamic error) {
    if (error is FormatException) {
      return AppException("Data format error: ${error.message}");
    } else if (error is TypeError) {
      return AppException("Type mismatch: ${error.toString()}");
    } else {
      return AppException(error.toString());
    }
  }

  static String _parseServerMessage(dynamic data, int? statusCode) {
    // If the response is JSON from the API, try to extract the error message
    if (data is Map<String, dynamic>) {
      // Handle format: {"status":"Error","message":"Validation Error","data":{"email":["..."]}}
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        final errorData = data['data'] as Map<String, dynamic>;

        // Get the first field that has an error
        if (errorData.isNotEmpty) {
          final firstKey = errorData.keys.first;
          final firstError = errorData[firstKey];

          if (firstError is List && firstError.isNotEmpty) {
            // Format: {"email": ["The email has already been taken."]}
            return firstError.first.toString();
          } else if (firstError is String) {
            return firstError;
          }
        }
      }

      if (data.containsKey('errors')) {
        // If the shape is {"errors": {"email": ["Already taken"]}}
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          return errors.values.first is List && (errors.values.first as List).isNotEmpty
              ? (errors.values.first as List).first.toString()
              : errors.values.first.toString();
        }
      }

      // Handle other standard formats
      if (data.containsKey('message')) return data['message'].toString();
      if (data.containsKey('error')) return data['error'].toString();
    }

    // Fallback based on common status codes
    switch (statusCode) {
      case 400:
        return "Bad request — please check your input.";
      case 401:
        return "Unauthorized — please login again.";
      case 403:
        return "Access denied — you don't have permission.";
      case 404:
        return "Resource not found.";
      case 409:
        return "Conflict — resource already exists.";
      case 422:
        return "Validation error — please check your data.";
      case 500:
        return "Server error — please try again later.";
      case 503:
        return "Service unavailable — please try again later.";
      default:
        return "Unexpected server response (${statusCode ?? 'unknown'}).";
    }
  }

  @override
  String toString() => "AppException($code): $message";
}
