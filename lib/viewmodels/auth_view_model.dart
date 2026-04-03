import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../core/utils/app_logger.dart';
import 'base/base_view_model.dart';

class AuthViewModel extends BaseViewModel {
  static const _tag = 'AuthViewModel';

  final _api = AuthApiService();

  UserModel? _user;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null && state != ViewState.loading;

  // ── Session restore ──────────────────────────────────────────────────────────

  Future<void> init() async {
    AppLogger.info(_tag, 'init called');
    final token = await ApiClient.instance.getToken();
    if (token == null) {
      AppLogger.warning(_tag, 'init: no token found, setting idle');
      setIdle();
      return;
    }
    setLoading();
    try {
      final data = await ProfileApiService().getProfile();
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>? ?? data);
      AppLogger.success(_tag, 'init: session restored successfully');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'init: session restore failed', e);
      await ApiClient.instance.clearToken();
      _user = null;
      setIdle();
    }
  }

  // ── Auth actions ─────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    AppLogger.info(_tag, 'login called');
    setLoading();
    try {
      final data = await _api.login(email, password);
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>? ?? {});
      AppLogger.success(_tag, 'login succeeded');
      setSuccess();
      return true;
    } on DioException catch (e) {
      AppLogger.error(_tag, 'login DioException', e);
      setError(ApiException.fromDioException(e));
      return false;
    } catch (e) {
      AppLogger.error(_tag, 'login error', e);
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
    AppLogger.info(_tag, 'register called');
    setLoading();
    try {
      await _api.register(
        name: name,
        email: email,
        employeeId: employeeId,
        department: department,
        password: password,
      );
      AppLogger.success(_tag, 'register succeeded');
      setIdle();
      return true;
    } on DioException catch (e) {
      AppLogger.error(_tag, 'register DioException', e);
      setError(ApiException.fromDioException(e));
      return false;
    } catch (e) {
      AppLogger.error(_tag, 'register error', e);
      setError(e.toString());
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    AppLogger.info(_tag, 'forgotPassword called');
    try {
      await _api.forgotPassword(email);
      AppLogger.success(_tag, 'forgotPassword succeeded');
      return true;
    } on DioException catch (e) {
      AppLogger.error(_tag, 'forgotPassword DioException', e);
      setError(ApiException.fromDioException(e));
      return false;
    } catch (e) {
      AppLogger.error(_tag, 'forgotPassword error', e);
      setError(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    AppLogger.info(_tag, 'logout called');
    await _api.logout();
    _user = null;
    AppLogger.success(_tag, 'logout succeeded');
    setIdle();
  }

  void updateUser(UserModel user) {
    AppLogger.info(_tag, 'updateUser called');
    _user = user;
    notifyListeners();
  }

  void clearError() {
    AppLogger.info(_tag, 'clearError called');
    if (state == ViewState.error) setIdle();
  }
}
