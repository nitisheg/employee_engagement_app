import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/utils/app_logger.dart';
import '../models/dashboard_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthApiService _authApi = AuthApiService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  DashboardModel? _dashboard;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  DashboardModel? get dashboard => _dashboard;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  static const _tag = 'AuthProvider';

  /// Restores session on app start if a token is stored.
  Future<void> init() async {
    AppLogger.info(_tag, 'Initializing — checking stored token');
    final token = await ApiClient.instance.getToken();
    if (token == null) {
      AppLogger.info(_tag, 'No token found — unauthenticated');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      final profileApi = ProfileApiService();
      final data = await profileApi.getProfile();
      final userJson = data['user'] as Map<String, dynamic>? ?? data;
      _user = UserModel.fromJson(userJson);
      await fetchDashboard();
      _status = AuthStatus.authenticated;
      AppLogger.success(_tag, 'Session restored — ${_user?.email}');
    } catch (e) {
      AppLogger.error(_tag, 'Session restore failed — clearing token', e);
      await ApiClient.instance.clearToken();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> fetchDashboard() async {
    AppLogger.info(_tag, 'Fetching dashboard');
    try {
      final profileApi = ProfileApiService();
      final data = await profileApi.getDashboard();
      _dashboard = DashboardModel.fromJson(data);
      if (_dashboard?.user.avatar != null &&
          _dashboard!.user.avatar.isNotEmpty) {
        _user = _user?.copyWith(avatar: _dashboard?.user.avatar);
      }
      AppLogger.success(_tag, 'Dashboard loaded');
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'Dashboard fetch failed', e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'Dashboard fetch failed', e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    AppLogger.info(_tag, 'Login attempt → $email');
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await _authApi.login(email, password);
      final userJson = data['user'] as Map<String, dynamic>? ?? {};
      _user = UserModel.fromJson(userJson);
      await fetchDashboard();
      _status = AuthStatus.authenticated;
      AppLogger.success(_tag, 'Logged in — ${_user?.name}');
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'Login failed — $_errorMessage', e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'Login failed', e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Returns true on success. The user must then login — register returns no token.
  Future<bool> register({
    required String name,
    required String email,
    required String employeeId,
    required String department,
    required String password,
  }) async {
    AppLogger.info(_tag, 'Register attempt → $email ($employeeId)');
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authApi.register(
        name: name,
        email: email,
        password: password,
        employeeId: employeeId,
        department: department,
      );
      _status = AuthStatus.unauthenticated;
      AppLogger.success(_tag, 'Registered successfully');
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'Registration failed — $_errorMessage', e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'Registration failed', e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Returns true if the request was sent (server always responds 200).
  Future<bool> forgotPassword(String email) async {
    AppLogger.info(_tag, 'Forgot password → $email');
    _errorMessage = null;
    try {
      await _authApi.forgotPassword(email);
      AppLogger.success(_tag, 'Forgot password email sent');
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'Forgot password failed', e);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'Forgot password failed', e);
      return false;
    }
  }

  Future<void> logout() async {
    AppLogger.info(_tag, 'Logging out — ${_user?.email}');
    await _authApi.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    AppLogger.success(_tag, 'Logged out');
    notifyListeners();
  }

  void updateUser(UserModel updated) {
    AppLogger.debug(_tag, 'User updated — ${updated.email}');
    _user = updated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
