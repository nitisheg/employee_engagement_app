import 'package:dio/dio.dart';
import '../core/api_client.dart';

class NotificationApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          '/api/notifications',
          queryParameters: {'page': page, 'limit': limit},
        );
    return _requireMap(
      response.data,
      fallbackMessage: 'Invalid notifications response.',
    );
  }

  Future<Map<String, dynamic>> markNotificationAsRead(
    String notificationId,
  ) async {
    final attempts = <Future<Response<Map<String, dynamic>>> Function()>[
      () => _dio.put<Map<String, dynamic>>(
        '/api/notifications/$notificationId/read',
      ),
      () => _dio.patch<Map<String, dynamic>>(
        '/api/notifications/$notificationId/read',
      ),
      () => _dio.put<Map<String, dynamic>>(
        '/api/notifications/$notificationId',
        data: {'isRead': true},
      ),
      () => _dio.patch<Map<String, dynamic>>(
        '/api/notifications/$notificationId',
        data: {'isRead': true},
      ),
      () => _dio.post<Map<String, dynamic>>(
        '/api/notifications/$notificationId/read',
      ),
      () => _dio.post<Map<String, dynamic>>(
        '/api/notifications/$notificationId/mark-read',
      ),
    ];

    DioException? lastDioError;
    for (final attempt in attempts) {
      try {
        final response = await attempt();
        return _requireMap(
          response.data,
          fallbackMessage: 'Invalid mark-as-read response.',
        );
      } on DioException catch (e) {
        if (!_shouldTryAnotherEndpoint(e)) {
          rethrow;
        }
        lastDioError = e;
      }
    }

    if (lastDioError != null) {
      throw lastDioError;
    }

    throw const FormatException('Invalid mark-as-read response.');
  }

  Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    final attempts = <Future<Response<Map<String, dynamic>>> Function()>[
      () => _dio.put<Map<String, dynamic>>('/api/notifications/read-all'),
      () => _dio.patch<Map<String, dynamic>>('/api/notifications/read-all'),
      () => _dio.post<Map<String, dynamic>>('/api/notifications/read-all'),
      () => _dio.put<Map<String, dynamic>>('/api/notifications/mark-all-read'),
      () =>
          _dio.patch<Map<String, dynamic>>('/api/notifications/mark-all-read'),
      () => _dio.post<Map<String, dynamic>>('/api/notifications/mark-all-read'),
      () => _dio.put<Map<String, dynamic>>(
        '/api/notifications',
        data: {'isRead': true, 'all': true},
      ),
      () => _dio.patch<Map<String, dynamic>>(
        '/api/notifications',
        data: {'isRead': true, 'all': true},
      ),
    ];

    DioException? lastDioError;
    for (final attempt in attempts) {
      try {
        final response = await attempt();
        return _requireMap(
          response.data,
          fallbackMessage: 'Invalid mark-all-read response.',
        );
      } on DioException catch (e) {
        if (!_shouldTryAnotherEndpoint(e)) {
          rethrow;
        }
        lastDioError = e;
      }
    }

    if (lastDioError != null) {
      throw lastDioError;
    }

    throw const FormatException('Invalid mark-all-read response.');
  }

  Future<void> deleteNotification(String notificationId) async {
    await _dio.delete<dynamic>('/api/notifications/$notificationId');
  }

  Future<Map<String, dynamic>> getPrivacySettings() async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>('/api/user/privacy-settings');
    return _requireMap(
      response.data,
      fallbackMessage: 'Invalid privacy settings response.',
    );
  }

  Future<Map<String, dynamic>> updatePrivacySettings(
    Map<String, dynamic> settings,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio
        .put<Map<String, dynamic>>(
          '/api/user/privacy-settings',
          data: settings,
        );
    return _requireMap(
      response.data,
      fallbackMessage: 'Invalid privacy settings update response.',
    );
  }

  Map<String, dynamic> _requireMap(
    Map<String, dynamic>? value, {
    required String fallbackMessage,
  }) {
    if (value == null) {
      throw FormatException(fallbackMessage);
    }
    return value;
  }

  bool _shouldTryAnotherEndpoint(DioException e) {
    final statusCode = e.response?.statusCode;
    return statusCode == 404 || statusCode == 405;
  }
}
