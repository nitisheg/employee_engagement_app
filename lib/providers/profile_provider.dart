import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../core/utils/app_logger.dart';

class ProfileProvider extends ChangeNotifier {
  static const _tag = 'ProfileProvider';

  final ProfileApiService _profileApi = ProfileApiService();

  bool _isLoading = false;
  bool _isUpdating = false;
  bool _isUploadingAvatar = false;
  bool _isChangingPassword = false;
  String? _errorMessage;
  String? _successMessage;
  UserModel? _user;

  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get isUploadingAvatar => _isUploadingAvatar;
  bool get isChangingPassword => _isChangingPassword;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  UserModel? get user => _user;

  Future<void> fetchProfile() async {
    AppLogger.info(_tag, 'fetchProfile called');
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final data = await _profileApi.getProfile();
      final userJson = data['user'] as Map<String, dynamic>? ?? data;
      _user = UserModel.fromJson(userJson);
      AppLogger.success(_tag, 'fetchProfile succeeded');
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'fetchProfile DioException', e);
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'fetchProfile error', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String address,
    required String department,
    required String designation,
  }) async {
    AppLogger.info(_tag, 'updateProfile called');
    _isUpdating = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final data = await _profileApi.updateProfile({
        'name': name,
        'phone': phone,
        'address': address,
        'department': department,
        'designation': designation,
      });
      final userJson = data['user'] as Map<String, dynamic>? ?? data;
      _user = UserModel.fromJson(userJson);
      _successMessage = 'Profile updated successfully';
      AppLogger.success(_tag, 'updateProfile succeeded');
      _isUpdating = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'updateProfile DioException', e);
      _isUpdating = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'updateProfile error', e);
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadAvatar(String filePath) async {
    AppLogger.info(_tag, 'uploadAvatar called');
    _isUploadingAvatar = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final data = await _profileApi.uploadAvatar(filePath);
      final userJson = data['user'] as Map<String, dynamic>? ?? data;
      _user = UserModel.fromJson(userJson);
      _successMessage = 'Avatar updated successfully';
      AppLogger.success(_tag, 'uploadAvatar succeeded');
      _isUploadingAvatar = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'uploadAvatar DioException', e);
      _isUploadingAvatar = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'uploadAvatar error', e);
      _isUploadingAvatar = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    AppLogger.info(_tag, 'changePassword called');
    _isChangingPassword = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _profileApi.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _successMessage = 'Password changed successfully';
      AppLogger.success(_tag, 'changePassword succeeded');
      _isChangingPassword = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'changePassword DioException', e);
      _isChangingPassword = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'changePassword error', e);
      _isChangingPassword = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    AppLogger.info(_tag, 'clearMessages called');
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
