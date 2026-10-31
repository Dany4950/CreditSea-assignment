import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;
  bool get isOffline => statusCode == null;

  factory ApiException.from(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return ApiException(data['message'] as String, statusCode: code);
    }
    switch (e.type) {
      case DioExceptionType.connectionError:
        return ApiException('No internet connection');
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Request timed out. Please try again.');
      default:
        return ApiException('Something went wrong', statusCode: code);
    }
  }

  @override
  String toString() => message;
}
