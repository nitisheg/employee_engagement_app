import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

enum ViewState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final _api = AuthApiService();

  ViewState _state = ViewState.idle;
  UserModel? _user;
  String? _error;

  ViewState get state => _state;
  UserModel? get user => _user;
  String? get error => _error;

  bool get isLoading => _state == ViewState.loading;
  bool get isAuthenticated => _user != null && _state != ViewState.loading;

  // ── Session restore ──────────────────────────────────────────────────────────

  Future<void> init() async {
    final token = await ApiClient.instance.getToken();
    if (token == null) {
      _state = ViewState.idle;
      notifyListeners();
      return;
    }
    _state = ViewState.loading;
    notifyListeners();
    try {
      final data = await ProfileApiService().getProfile();
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>? ?? data);
      _state = ViewState.success;
    } catch (_) {
      await ApiClient.instance.clearToken();
      _user = null;
      _state = ViewState.idle;
    }
    notifyListeners();
  }

  // ── Auth actions ─────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _state = ViewState.loading;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.login(email, password);
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>? ?? {});
      _state = ViewState.success;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = ApiException.fromDioException(e);
      _state = ViewState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  /// Register returns no token — caller must navigate to login on success.
  Future<bool> register({
    required String name,
    required String email,
    required String employeeId,

    required String department,

    required String password,
  }) async {
    _state = ViewState.loading;
    _error = null;
    notifyListeners();
    try {
      await _api.register(
        name: name,
        email: email,
        employeeId: employeeId,
        department: department,
        password: password,
      );
      _state = ViewState.idle;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = ApiException.fromDioException(e);
      _state = ViewState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _state = ViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _error = null;
    try {
      await _api.forgotPassword(email);
      return true;
    } on DioException catch (e) {
      _error = ApiException.fromDioException(e);
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    _user = null;
    _state = ViewState.idle;
    notifyListeners();
  }

  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    if (_state == ViewState.error) _state = ViewState.idle;
    notifyListeners();
  }
}
