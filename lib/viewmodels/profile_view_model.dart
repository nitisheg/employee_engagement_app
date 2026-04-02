import '../models/user_model.dart';
import '../services/api_service.dart';
import 'base_view_model.dart';

class ProfileViewModel extends BaseViewModel {
  UserModel? _user;
  List<Map<String, dynamic>> _achievements = [];
  List<Map<String, dynamic>> _certifications = [];
  Map<String, dynamic>? _stats;

  UserModel? get user => _user;
  List<Map<String, dynamic>> get achievements => _achievements;
  List<Map<String, dynamic>> get certifications => _certifications;
  Map<String, dynamic>? get stats => _stats;

  Future<void> loadProfile() async {
    try {
      setLoading();
      final data = await ProfileApiService().getProfile();
      _user = UserModel.fromJson(data['user'] ?? data);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      setLoading();
      final data = await ProfileApiService().updateProfile(updates);
      _user = UserModel.fromJson(data['user'] ?? data);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> loadAchievements() async {
    try {
      setLoading();
      // TODO: Implement when API is available
      _achievements = [];
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> loadCertifications() async {
    try {
      setLoading();
      // TODO: Implement when API is available
      _certifications = [];
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> loadStats() async {
    try {
      setLoading();
      // TODO: Implement when API is available
      _stats = {};
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      setLoading();
      await ProfileApiService().changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> uploadProfileImage(String imagePath) async {
    try {
      setLoading();
      final data = await ProfileApiService().uploadAvatar(imagePath);
      if (_user != null) {
        _user = _user!.copyWith(avatar: data['imageUrl']);
      }
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }
}
