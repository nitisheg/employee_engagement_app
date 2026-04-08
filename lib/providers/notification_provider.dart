import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/notification_model.dart';
import '../models/privacy_settings_model.dart';
import '../services/api_service.dart';
import '../core/utils/app_logger.dart';

class NotificationProvider extends ChangeNotifier {
  static const _tag = 'NotificationProvider';

  final NotificationApiService _notificationApi = NotificationApiService();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isUpdatingSettings = false;
  String? _errorMessage;
  String? _successMessage;
  List<NotificationModel> _notifications = [];
  PrivacySettingsModel? _privacySettings;
  int _unreadCount = 0;
  int _currentPage = 1;
  int _pageSize = 20;
  bool _hasMore = true;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isUpdatingSettings => _isUpdatingSettings;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<NotificationModel> get notifications => _notifications;
  PrivacySettingsModel? get privacySettings => _privacySettings;
  int get unreadCount => _unreadCount;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  Future<void> fetchNotifications({
    int page = 1,
    int limit = 20,
    bool refresh = false,
  }) async {
    AppLogger.info(_tag, 'fetchNotifications called');
    final isFirstPage = page <= 1 || refresh;

    if (isFirstPage) {
      _isLoading = true;
      _currentPage = 1;
      _hasMore = true;
      _pageSize = limit;
    } else {
      _isLoadingMore = true;
    }

    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final data = await _notificationApi.getNotifications(
        page: page,
        limit: limit,
      );
      final rawNotifications = data['notifications'];
      if (rawNotifications != null && rawNotifications is! List) {
        throw const FormatException('Unexpected notifications format.');
      }

      final notificationList =
          (rawNotifications as List<dynamic>? ?? <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .map(NotificationModel.fromJson)
              .toList();

      if (isFirstPage) {
        _notifications = notificationList;
      } else {
        final existingIds = _notifications.map((n) => n.id).toSet();
        final newItems = notificationList
            .where((n) => !existingIds.contains(n.id))
            .toList();
        _notifications.addAll(newItems);
      }

      _currentPage = page;

      final pagination = data['pagination'] as Map<String, dynamic>?;
      if (pagination != null) {
        final hasNextPage = pagination['hasNextPage'];
        if (hasNextPage is bool) {
          _hasMore = hasNextPage;
        } else {
          final totalPages =
              (pagination['totalPages'] ?? pagination['total_pages']) as int?;
          if (totalPages != null) {
            _hasMore = page < totalPages;
          } else {
            _hasMore = notificationList.length >= limit;
          }
        }
      } else {
        _hasMore = notificationList.length >= limit;
      }

      final unread = data['unreadCount'];
      if (unread is int) {
        _unreadCount = unread;
      } else {
        _unreadCount = _notifications.where((n) => !n.isRead).length;
      }
      AppLogger.success(_tag, 'fetchNotifications succeeded');
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'fetchNotifications DioException', e);
    } on FormatException catch (e) {
      _errorMessage = e.message;
      AppLogger.error(_tag, 'fetchNotifications format error', e);
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'fetchNotifications error', e);
    }

    if (isFirstPage) {
      _isLoading = false;
    }
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> loadMoreNotifications() async {
    if (_isLoading || _isLoadingMore || !_hasMore) {
      return;
    }
    await fetchNotifications(page: _currentPage + 1, limit: _pageSize);
  }

  Future<bool> markAsRead(String notificationId) async {
    AppLogger.info(_tag, 'markAsRead called');
    _errorMessage = null;
    try {
      final data = await _notificationApi.markNotificationAsRead(
        notificationId,
      );
      final serverNotification = data['notification'];
      NotificationModel? updatedNotification;
      if (serverNotification is Map<String, dynamic>) {
        updatedNotification = NotificationModel.fromJson(serverNotification);
      }

      _notifications = _notifications.map((n) {
        if (n.id == notificationId) {
          if (updatedNotification != null) {
            return n.copyWith(
              title: updatedNotification.title,
              message: updatedNotification.message,
              type: updatedNotification.type,
              isRead: updatedNotification.isRead,
              readAt: updatedNotification.readAt ?? DateTime.now(),
            );
          }
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }
        return n;
      }).toList();

      _unreadCount = _notifications.where((n) => !n.isRead).length;
      AppLogger.success(_tag, 'markAsRead succeeded');
      notifyListeners();
      return true;
    } on DioException catch (e) {
      if (_isRouteNotFound(e)) {
        AppLogger.warning(
          _tag,
          'markAsRead route missing on backend, applying local update',
        );
        _applyLocalRead(notificationId);
        notifyListeners();
        return true;
      }

      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'markAsRead DioException', e);
      notifyListeners();
      return false;
    } on FormatException catch (e) {
      _errorMessage = e.message;
      AppLogger.error(_tag, 'markAsRead format error', e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'markAsRead error', e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    AppLogger.info(_tag, 'markAllAsRead called');
    _errorMessage = null;
    try {
      await _notificationApi.markAllNotificationsAsRead();
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
          .toList();
      _unreadCount = 0;
      AppLogger.success(_tag, 'markAllAsRead succeeded');
      notifyListeners();
      return true;
    } on DioException catch (e) {
      if (_isRouteNotFound(e)) {
        AppLogger.warning(
          _tag,
          'markAllAsRead route missing on backend, applying local update',
        );
        _notifications = _notifications
            .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
            .toList();
        _unreadCount = 0;
        notifyListeners();
        return true;
      }

      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'markAllAsRead DioException', e);
      notifyListeners();
      return false;
    } on FormatException catch (e) {
      _errorMessage = e.message;
      AppLogger.error(_tag, 'markAllAsRead format error', e);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'markAllAsRead error', e);
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchPrivacySettings() async {
    AppLogger.info(_tag, 'fetchPrivacySettings called');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _notificationApi.getPrivacySettings();
      final settings = data['settings'] as Map<String, dynamic>? ?? data;
      _privacySettings = PrivacySettingsModel.fromJson(settings);
      AppLogger.success(_tag, 'fetchPrivacySettings succeeded');
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'fetchPrivacySettings DioException', e);
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'fetchPrivacySettings error', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updatePrivacySettings(PrivacySettingsModel newSettings) async {
    AppLogger.info(_tag, 'updatePrivacySettings called');
    _isUpdatingSettings = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final data = await _notificationApi.updatePrivacySettings(
        newSettings.toJson(),
      );
      final settings = data['settings'] as Map<String, dynamic>? ?? data;
      _privacySettings = PrivacySettingsModel.fromJson(settings);
      _successMessage = 'Privacy settings updated successfully';
      AppLogger.success(_tag, 'updatePrivacySettings succeeded');
      _isUpdatingSettings = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = ApiException.fromDioException(e);
      AppLogger.error(_tag, 'updatePrivacySettings DioException', e);
      _isUpdatingSettings = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      AppLogger.error(_tag, 'updatePrivacySettings error', e);
      _isUpdatingSettings = false;
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

  void _applyLocalRead(String notificationId) {
    _notifications = _notifications.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true, readAt: DateTime.now());
      }
      return n;
    }).toList();
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  bool _isRouteNotFound(DioException e) {
    final statusCode = e.response?.statusCode;
    return statusCode == 404;
  }
}
