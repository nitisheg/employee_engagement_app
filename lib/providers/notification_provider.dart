import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/notification_model.dart';
import '../models/privacy_settings_model.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationApiService _notificationApi = NotificationApiService();

  bool _isLoading = false;
  bool _isUpdatingSettings = false;
  String? _errorMessage;
  String? _successMessage;
  List<NotificationModel> _notifications = [];
  PrivacySettingsModel? _privacySettings;
  int _unreadCount = 0;

  bool get isLoading => _isLoading;
  bool get isUpdatingSettings => _isUpdatingSettings;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<NotificationModel> get notifications => _notifications;
  PrivacySettingsModel? get privacySettings => _privacySettings;
  int get unreadCount => _unreadCount;

  Future<void> fetchNotifications({int page = 1, int limit = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _notificationApi.getNotifications(
        page: page,
        limit: limit,
      );
      final notificationList =
          (data['notifications'] as List?)
              ?.map(
                (json) =>
                    NotificationModel.fromJson(json as Map<String, dynamic>),
              )
              .toList() ??
          [];
      _notifications = notificationList;
      _unreadCount = (data['unreadCount'] as int?) ?? 0;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      await _notificationApi.markNotificationAsRead(notificationId);
      _notifications = _notifications.map((n) {
        if (n.id == notificationId) {
          return NotificationModel(
            id: n.id,
            userId: n.userId,
            title: n.title,
            message: n.message,
            type: n.type,
            relatedId: n.relatedId,
            relatedType: n.relatedType,
            isRead: true,
            createdAt: n.createdAt,
            readAt: DateTime.now(),
          );
        }
        return n;
      }).toList();
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await _notificationApi.markAllNotificationsAsRead();
      _notifications = _notifications
          .map(
            (n) => NotificationModel(
              id: n.id,
              userId: n.userId,
              title: n.title,
              message: n.message,
              type: n.type,
              relatedId: n.relatedId,
              relatedType: n.relatedType,
              isRead: true,
              createdAt: n.createdAt,
              readAt: DateTime.now(),
            ),
          )
          .toList();
      _unreadCount = 0;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchPrivacySettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _notificationApi.getPrivacySettings();
      final settings =
          data['settings'] as Map<String, dynamic>? ?? data;
      _privacySettings = PrivacySettingsModel.fromJson(settings);
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updatePrivacySettings(PrivacySettingsModel newSettings) async {
    _isUpdatingSettings = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final data = await _notificationApi.updatePrivacySettings(
        newSettings.toJson(),
      );
      final settings =
          data['settings'] as Map<String, dynamic>? ?? data;
      _privacySettings = PrivacySettingsModel.fromJson(settings);
      _successMessage = 'Privacy settings updated successfully';
      _isUpdatingSettings = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      _isUpdatingSettings = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isUpdatingSettings = false;
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
