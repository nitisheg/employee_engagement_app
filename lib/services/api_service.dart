import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../core/utils/app_logger.dart';

// ── Singleton API client ──────────────────────────────────────────────────────

class ApiClient {
  static const String baseUrl = 'https://emp-eng-api.stagingwebsite.uk';
  static const String _tokenKey = 'access_token';

  static ApiClient? _instance;
  static ApiClient get instance => _instance ??= ApiClient._();

  late final Dio dio;
  final _storage = const FlutterSecureStorage();
  final _cookieJar = CookieJar();

  static dynamic _unwrapResponse(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  ApiClient._() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(CookieManager(_cookieJar));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.network('ApiClient', '→ ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.network(
            'ApiClient',
            '← ${response.statusCode} ${response.requestOptions.path}',
          );
          response.data = _unwrapResponse(response.data);
          handler.next(response);
        },
        onError: (err, handler) {
          AppLogger.error(
            'ApiClient',
            '✗ ${err.requestOptions.method} ${err.requestOptions.path} — ${err.response?.statusCode} ${err.message}',
          );
          handler.next(err);
        },
      ),
    );
    dio.interceptors.add(_AuthInterceptor(dio, _storage, _cookieJar));
  }

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<String?> getToken() => _storage.read(key: _tokenKey);
}

// ── Auth interceptor – injects Bearer token & handles 401 refresh ─────────────

class _AuthInterceptor extends Interceptor {
  static const String _tokenKey = 'access_token';

  final Dio _dio;
  final FlutterSecureStorage _storage;
  final CookieJar _cookieJar;
  bool _isRefreshing = false;

  _AuthInterceptor(this._dio, this._storage, this._cookieJar);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      AppLogger.debug('AuthInterceptor', 'Token injected for ${options.path}');
    } else {
      AppLogger.debug('AuthInterceptor', 'No token for ${options.path}');
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      AppLogger.warning(
        'AuthInterceptor',
        '401 received — attempting token refresh',
      );
      _isRefreshing = true;
      try {
        final refreshDio = Dio(BaseOptions(baseUrl: ApiClient.baseUrl));
        refreshDio.interceptors.add(CookieManager(_cookieJar));
        final resp = await refreshDio.post('/api/auth/user/refresh');
        final newToken = resp.data['accessToken'] as String?;
        if (newToken != null) {
          await _storage.write(key: _tokenKey, value: newToken);
          AppLogger.success(
            'AuthInterceptor',
            'Token refreshed — retrying ${err.requestOptions.path}',
          );
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';
          final retried = await _dio.request<dynamic>(
            opts.path,
            options: Options(method: opts.method, headers: opts.headers),
            data: opts.data,
            queryParameters: opts.queryParameters,
          );
          handler.resolve(retried);
          return;
        }
      } catch (e) {
        AppLogger.error(
          'AuthInterceptor',
          'Token refresh failed — clearing token',
          e,
        );
        await _storage.delete(key: _tokenKey);
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }
}

// ── Auth API ──────────────────────────────────────────────────────────────────

class AuthApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    AppLogger.info('AuthApiService', 'Login → $email');
    final resp = await _dio.post<Map<String, dynamic>>(
      '/api/auth/user/login',
      data: {'email': email, 'password': password},
    );
    final accessToken = resp.data!['accessToken'] as String;
    await ApiClient.instance.saveToken(accessToken);
    AppLogger.success('AuthApiService', 'Login successful — token saved');
    return resp.data!;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String employeeId,
    required String department,
  }) async {
    AppLogger.info('AuthApiService', 'Register → $email ($employeeId)');
    final resp = await _dio.post<Map<String, dynamic>>(
      '/api/auth/user/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'employeeId': employeeId,
        'department': department,
      },
    );
    // Register returns {success, message, user} — no accessToken.
    // The user must log in separately after registration.
    AppLogger.success('AuthApiService', 'Registration successful');
    return resp.data!;
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
    AppLogger.info('AuthApiService', 'Forgot password → $email');
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

// ── Profile API ───────────────────────────────────────────────────────────────

class ProfileApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> getProfile() async {
    AppLogger.info('ProfileApiService', 'Fetching profile');
    final resp = await _dio.get<Map<String, dynamic>>('/api/user/me');
    AppLogger.success('ProfileApiService', 'Profile fetched');
    return resp.data!;
  }

  Future<Map<String, dynamic>> getDashboard() async {
    AppLogger.info('ProfileApiService', 'Fetching dashboard');
    final resp = await _dio.get<Map<String, dynamic>>('/api/user/dashboard');
    AppLogger.success('ProfileApiService', 'Dashboard fetched');
    return resp.data!;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    AppLogger.info(
      'ProfileApiService',
      'Updating profile → ${data.keys.join(', ')}',
    );
    final resp = await _dio.put<Map<String, dynamic>>(
      '/api/user/me',
      data: data,
    );
    AppLogger.success('ProfileApiService', 'Profile updated');
    return resp.data!;
  }

  Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    AppLogger.info(
      'ProfileApiService',
      'Uploading avatar → ${filePath.split('/').last}',
    );
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });
    final resp = await _dio.put<Map<String, dynamic>>(
      '/api/user/avatar',
      data: formData,
    );
    AppLogger.success('ProfileApiService', 'Avatar uploaded');
    return resp.data!;
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

// ── Quiz API ──────────────────────────────────────────────────────────────────

class QuizApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> getActiveQuizzes({
    String filter = 'all',
    int page = 1,
    int limit = 20,
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/api/quizzes/active',
      queryParameters: {'filter': filter, 'page': page, 'limit': limit},
    );
    return resp.data!;
  }

  Future<Map<String, dynamic>> getQuizAttempt(
    String quizId, {
    int page = 1,
    int limit = 10,
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/api/quizzes/$quizId/take',
      queryParameters: {'page': page, 'limit': limit},
    );

    if (resp.data == null) {
      throw Exception('Quiz attempt response body is null');
    }

    final raw = resp.data!;

    // Support payloads like {data: {...}, pagination: {...}}
    if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
      final dataPayload = Map<String, dynamic>.from(
        raw['data'] as Map<String, dynamic>,
      );

      final rootPagination = raw['pagination'] as Map<String, dynamic>?;
      if (rootPagination != null && !dataPayload.containsKey('pagination')) {
        dataPayload['pagination'] = rootPagination;
      }

      return dataPayload;
    }

    // Support payload like the example you provided:
    // {success, alreadySubmitted, quiz, pagination}
    if (raw.containsKey('quiz') && raw['quiz'] is Map<String, dynamic>) {
      final quizPayload = raw['quiz'] as Map<String, dynamic>;
      final pagination = raw['pagination'] as Map<String, dynamic>? ?? {};

      return {
        'quizId': quizPayload['_id'] ?? quizPayload['id'] ?? quizId,
        'title': quizPayload['title'] ?? '',
        'questions': quizPayload['questions'] ?? [],
        'page': pagination['page'] ?? page,
        'totalPages': pagination['totalPages'] ?? 1,
      };
    }

    return raw;
  }

  Future<Map<String, dynamic>> submitQuiz(
    String quizId,
    List<Map<String, dynamic>> answers,
  ) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/api/quizzes/$quizId/submit',
      data: {'answers': answers},
    );
    return resp.data!;
  }

  Future<Map<String, dynamic>> getMyResults({
    int page = 1,
    int limit = 20,
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/api/quizzes/my-results',
      queryParameters: {'page': page, 'limit': limit},
    );
    return resp.data!;
  }
}

// ── Notification API ──────────────────────────────────────────────────────────

class NotificationApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/api/notifications',
      queryParameters: {'page': page, 'limit': limit},
    );
    return resp.data!;
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
    final resp = await _dio.get<Map<String, dynamic>>(
      '/api/user/privacy-settings',
    );
    return resp.data!;
  }

  Future<Map<String, dynamic>> updatePrivacySettings(
    Map<String, dynamic> settings,
  ) async {
    final resp = await _dio.put<Map<String, dynamic>>(
      '/api/user/privacy-settings',
      data: settings,
    );
    return resp.data!;
  }
}

// ── ApiException ──────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';

  /// Extracts a user-friendly message from a DioException.
  static String fromDioException(DioException e) {
    final data = e.response?.data;
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
