import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
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
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final data = await _profileApi.getProfile();
      final userJson = data['user'] as Map<String, dynamic>? ?? data;
      _user = UserModel.fromJson(userJson);
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
    } catch (e) {
      _errorMessage = e.toString();
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
      _isUpdating = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      _isUpdating = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadAvatar(String filePath) async {
    _isUploadingAvatar = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final data = await _profileApi.uploadAvatar(filePath);
      final userJson = data['user'] as Map<String, dynamic>? ?? data;
      _user = UserModel.fromJson(userJson);
      _successMessage = 'Avatar updated successfully';
      _isUploadingAvatar = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      _isUploadingAvatar = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isUploadingAvatar = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
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
      _isChangingPassword = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      _isChangingPassword = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isChangingPassword = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
