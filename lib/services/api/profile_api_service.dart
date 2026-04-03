import 'package:dio/dio.dart';
import '../../core/utils/app_logger.dart';
import '../core/api_client.dart';

class ProfileApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> getProfile() async {
    AppLogger.info('ProfileApiService', 'Fetching profile');
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>('/api/user/me');
    AppLogger.success('ProfileApiService', 'Profile fetched');
    return response.data!;
  }

  Future<Map<String, dynamic>> getDashboard() async {
    AppLogger.info('ProfileApiService', 'Fetching dashboard');
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>('/api/user/dashboard');
    AppLogger.success('ProfileApiService', 'Dashboard fetched');
    return response.data!;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    AppLogger.info(
      'ProfileApiService',
      'Updating profile -> ${data.keys.join(', ')}',
    );
    final Response<Map<String, dynamic>> response =
        await _dio.put<Map<String, dynamic>>('/api/user/me', data: data);
    AppLogger.success('ProfileApiService', 'Profile updated');
    return response.data!;
  }

  Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    AppLogger.info(
      'ProfileApiService',
      'Uploading avatar -> ${filePath.split('/').last}',
    );

    final FormData formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });

    final Response<Map<String, dynamic>> response =
        await _dio.put<Map<String, dynamic>>('/api/user/avatar', data: formData);
    AppLogger.success('ProfileApiService', 'Avatar uploaded');
    return response.data!;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    AppLogger.info('ProfileApiService', 'Changing password');
    await _dio.put<dynamic>(
      '/api/user/change-password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
    AppLogger.success('ProfileApiService', 'Password changed');
  }
}
