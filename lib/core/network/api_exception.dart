import 'package:dio/dio.dart';

/// Every failure the UI can see. `message` is always safe to show to the user.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.code, this.errors = const {}, this.retryAfter});

  final String message;
  final int? statusCode;

  /// Machine code from the backend, e.g. USER_EXISTS, INVALID_OTP, ACTIVE_LOAN_EXISTS.
  final String? code;

  /// Field-level validation messages (422), e.g. {'password': '...'}.
  final Map<String, String> errors;

  /// Seconds to wait before retrying (OTP resend cooldown).
  final int? retryAfter;

  bool get isUnauthorized => statusCode == 401;
  bool get isOffline => statusCode == null;
  bool hasCode(String c) => code == c;

  factory ApiException.from(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map && data['message'] is String) {
      final raw = data['errors'];
      return ApiException(
        data['message'] as String,
        statusCode: status,
        code: data['code'] as String?,
        errors: raw is Map ? raw.map((k, v) => MapEntry('$k', '$v')) : const {},
        retryAfter: data['retryAfter'] is num ? (data['retryAfter'] as num).toInt() : null,
      );
    }

    switch (e.type) {
      case DioExceptionType.connectionError:
        return ApiException('No internet connection. Please check your network.');
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('The server is taking too long to respond. Please try again.');
      default:
        return ApiException('Something went wrong. Please try again.', statusCode: status);
    }
  }

  @override
  String toString() => message;
}
