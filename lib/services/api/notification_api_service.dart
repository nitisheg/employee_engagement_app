import 'package:dio/dio.dart';
import '../core/api_client.dart';

class NotificationApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(
      '/api/notifications',
      queryParameters: {'page': page, 'limit': limit},
    );
    return response.data!;
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _dio.put<dynamic>('/api/notifications/$notificationId/read');
  }

  Future<void> markAllNotificationsAsRead() async {
    await _dio.put<dynamic>('/api/notifications/read-all');
  }

  Future<void> deleteNotification(String notificationId) async {
    await _dio.delete<dynamic>('/api/notifications/$notificationId');
  }

  Future<Map<String, dynamic>> getPrivacySettings() async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>('/api/user/privacy-settings');
    return response.data!;
  }

  Future<Map<String, dynamic>> updatePrivacySettings(
    Map<String, dynamic> settings,
  ) async {
    final Response<Map<String, dynamic>> response =
        await _dio.put<Map<String, dynamic>>(
      '/api/user/privacy-settings',
      data: settings,
    );
    return response.data!;
  }
}
