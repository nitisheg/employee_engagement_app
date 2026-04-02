import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'base_view_model.dart';

class AuthViewModel extends BaseViewModel {
  final _api = AuthApiService();

  UserModel? _user;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null && state != ViewState.loading;

  // ── Session restore ──────────────────────────────────────────────────────────

  Future<void> init() async {
    final token = await ApiClient.instance.getToken();
    if (token == null) {
      setIdle();
      return;
    }
    setLoading();
    try {
      final data = await ProfileApiService().getProfile();
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>? ?? data);
      setSuccess();
    } catch (_) {
      await ApiClient.instance.clearToken();
      _user = null;
      setIdle();
    }
  }

  // ── Auth actions ─────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    setLoading();
    try {
      final data = await _api.login(email, password);
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>? ?? {});
      setSuccess();
      return true;
    } on DioException catch (e) {
      setError(ApiException.fromDioException(e));
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String employeeId,
    required String department,
    required String password,
  }) async {
    setLoading();
    try {
      await _api.register(
        name: name,
        email: email,
        employeeId: employeeId,
        department: department,
        password: password,
      );
      setIdle();
      return true;
    } on DioException catch (e) {
      setError(ApiException.fromDioException(e));
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      await _api.forgotPassword(email);
      return true;
    } on DioException catch (e) {
      setError(ApiException.fromDioException(e));
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    _user = null;
    setIdle();
  }

  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearError() {
    if (state == ViewState.error) setIdle();
  }
}
