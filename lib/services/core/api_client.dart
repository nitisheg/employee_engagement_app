import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/app_logger.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  static const String baseUrl = ApiConstants.baseUrl;

  static ApiClient? _instance;
  static ApiClient get instance => _instance ??= ApiClient._();

  late final Dio dio;
  final SecureStorageService _storage = SecureStorageService.instance;
  final CookieJar _cookieJar = CookieJar();

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
          AppLogger.network('ApiClient', '-> ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.network(
            'ApiClient',
            '<- ${response.statusCode} ${response.requestOptions.path}',
          );
          response.data = _unwrapResponse(response.data);
          handler.next(response);
        },
        onError: (err, handler) {
          AppLogger.error(
            'ApiClient',
            'x ${err.requestOptions.method} ${err.requestOptions.path} - ${err.response?.statusCode} ${err.message}',
          );
          handler.next(err);
        },
      ),
    );
    dio.interceptors.add(_AuthInterceptor(dio, _storage, _cookieJar));
    if (kDebugMode) {
      dio.interceptors.add(
       LogInterceptor(
        request: false,
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: false,
        responseHeader: false,
        logPrint: (object) => debugPrint(object.toString()),
      ),
      );
    }
  }

  Future<void> saveToken(String token) =>
      _storage.saveAccessToken(token);

    Future<void> clearToken() => _storage.clearAccessToken();

    Future<String?> getToken() => _storage.getAccessToken();

  static dynamic _unwrapResponse(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }
}

class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorageService _storage;
  final CookieJar _cookieJar;
  bool _isRefreshing = false;

  _AuthInterceptor(this._dio, this._storage, this._cookieJar);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? token = await _storage.getAccessToken();
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
        '401 received - attempting token refresh',
      );
      _isRefreshing = true;
      try {
        final Dio refreshDio = Dio(BaseOptions(baseUrl: ApiClient.baseUrl));
        refreshDio.interceptors.add(CookieManager(_cookieJar));

        final Response<dynamic> response =
          await refreshDio.post<dynamic>(ApiConstants.refreshEndpoint);
        final String? newToken =
            (response.data as Map<String, dynamic>?)?['accessToken'] as String?;

        if (newToken != null) {
          await _storage.saveAccessToken(newToken);
          AppLogger.success(
            'AuthInterceptor',
            'Token refreshed - retrying ${err.requestOptions.path}',
          );

          final RequestOptions options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';

          final Response<dynamic> retried = await _dio.request<dynamic>(
            options.path,
            options: Options(method: options.method, headers: options.headers),
            data: options.data,
            queryParameters: options.queryParameters,
          );
          handler.resolve(retried);
          return;
        }
      } catch (e) {
        AppLogger.error(
          'AuthInterceptor',
          'Token refresh failed - clearing token',
          e,
        );
        await _storage.clearAccessToken();
      } finally {
        _isRefreshing = false;
      }
    }

    handler.next(err);
  }
}
