import 'package:dio/dio.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';

  static String fromDioException(DioException e) {
    final dynamic data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? 'Something went wrong.';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection.';
    }

    return 'Something went wrong.';
  }
}
