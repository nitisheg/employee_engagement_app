import 'package:dio/dio.dart';
import '../../core/utils/app_logger.dart';
import '../core/api_client.dart';

class AuthApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    AppLogger.info('AuthApiService', 'Login -> $email');
    final Response<Map<String, dynamic>> response =
        await _dio.post<Map<String, dynamic>>(
      '/api/auth/user/login',
      data: {'email': email, 'password': password},
    );

    final String accessToken = response.data!['accessToken'] as String;
    await ApiClient.instance.saveToken(accessToken);
    AppLogger.success('AuthApiService', 'Login successful - token saved');
    return response.data!;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String employeeId,
    required String department,
  }) async {
    AppLogger.info('AuthApiService', 'Register -> $email ($employeeId)');
    final Response<Map<String, dynamic>> response =
        await _dio.post<Map<String, dynamic>>(
      '/api/auth/user/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'employeeId': employeeId,
        'department': department,
      },
    );
    AppLogger.success('AuthApiService', 'Registration successful');
    return response.data!;
  }

  Future<void> logout() async {
    AppLogger.info('AuthApiService', 'Logout');
    try {
      await _dio.post<dynamic>('/api/auth/user/logout');
    } finally {
      await ApiClient.instance.clearToken();
      AppLogger.success('AuthApiService', 'Token cleared');
    }
  }

  Future<void> forgotPassword(String email) async {
    AppLogger.info('AuthApiService', 'Forgot password -> $email');
    await _dio.post<dynamic>(
      '/api/auth/user/forgot-password',
      data: {'email': email},
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    AppLogger.info('AuthApiService', 'Reset password');
    await _dio.post<dynamic>(
      '/api/auth/user/reset-password',
      data: {'token': token, 'newPassword': newPassword},
    );
  }
}
