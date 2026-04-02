import '../models/user_model.dart';
import '../services/api_service.dart';
import '../core/utils/app_logger.dart';
import 'base_view_model.dart';

class ProfileViewModel extends BaseViewModel {
  static const _tag = 'ProfileViewModel';

  UserModel? _user;
  List<Map<String, dynamic>> _achievements = [];
  List<Map<String, dynamic>> _certifications = [];
  Map<String, dynamic>? _stats;

  UserModel? get user => _user;
  List<Map<String, dynamic>> get achievements => _achievements;
  List<Map<String, dynamic>> get certifications => _certifications;
  Map<String, dynamic>? get stats => _stats;

  Future<void> loadProfile() async {
    AppLogger.info(_tag, 'loadProfile called');
    try {
      setLoading();
      final data = await ProfileApiService().getProfile();
      _user = UserModel.fromJson(data['user'] ?? data);
      AppLogger.success(_tag, 'loadProfile succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadProfile error', e);
      setError(e.toString());
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    AppLogger.info(_tag, 'updateProfile called');
    try {
      setLoading();
      final data = await ProfileApiService().updateProfile(updates);
      _user = UserModel.fromJson(data['user'] ?? data);
      AppLogger.success(_tag, 'updateProfile succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'updateProfile error', e);
      setError(e.toString());
    }
  }

  Future<void> loadAchievements() async {
    AppLogger.info(_tag, 'loadAchievements called');
    try {
      setLoading();
      // TODO: Implement when API is available
      _achievements = [];
      AppLogger.success(_tag, 'loadAchievements succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadAchievements error', e);
      setError(e.toString());
    }
  }

  Future<void> loadCertifications() async {
    AppLogger.info(_tag, 'loadCertifications called');
    try {
      setLoading();
      // TODO: Implement when API is available
      _certifications = [];
      AppLogger.success(_tag, 'loadCertifications succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadCertifications error', e);
      setError(e.toString());
    }
  }

  Future<void> loadStats() async {
    AppLogger.info(_tag, 'loadStats called');
    try {
      setLoading();
      // TODO: Implement when API is available
      _stats = {};
      AppLogger.success(_tag, 'loadStats succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadStats error', e);
      setError(e.toString());
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    AppLogger.info(_tag, 'changePassword called');
    try {
      setLoading();
      await ProfileApiService().changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      AppLogger.success(_tag, 'changePassword succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'changePassword error', e);
      setError(e.toString());
    }
  }

  Future<void> uploadProfileImage(String imagePath) async {
    AppLogger.info(_tag, 'uploadProfileImage called');
    try {
      setLoading();
      final data = await ProfileApiService().uploadAvatar(imagePath);
      if (_user != null) {
        _user = _user!.copyWith(avatar: data['imageUrl']);
      }
      AppLogger.success(_tag, 'uploadProfileImage succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'uploadProfileImage error', e);
      setError(e.toString());
    }
  }
}
