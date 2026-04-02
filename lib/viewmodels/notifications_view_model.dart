import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../core/utils/app_logger.dart';
import 'base_view_model.dart';

class NotificationsViewModel extends BaseViewModel {
  static const _tag = 'NotificationsViewModel';

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  Future<void> loadNotifications() async {
    AppLogger.info(_tag, 'loadNotifications called');
    try {
      setLoading();
      final data = await NotificationApiService().getNotifications();
      _notifications = (data['notifications'] as List? ?? [])
          .map((json) => NotificationModel.fromJson(json))
          .toList();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      AppLogger.success(_tag, 'loadNotifications succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'loadNotifications error', e);
      setError(e.toString());
    }
  }

  Future<void> markAsRead(String notificationId) async {
    AppLogger.info(_tag, 'markAsRead called');
    try {
      await NotificationApiService().markNotificationAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        AppLogger.success(_tag, 'markAsRead succeeded');
        notifyListeners();
      } else {
        AppLogger.warning(_tag, 'markAsRead: notification not found locally');
      }
    } catch (e) {
      AppLogger.error(_tag, 'markAsRead error', e);
      setError(e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    AppLogger.info(_tag, 'markAllAsRead called');
    try {
      setLoading();
      await NotificationApiService().markAllNotificationsAsRead();
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      _unreadCount = 0;
      AppLogger.success(_tag, 'markAllAsRead succeeded');
      setSuccess();
    } catch (e) {
      AppLogger.error(_tag, 'markAllAsRead error', e);
      setError(e.toString());
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    AppLogger.info(_tag, 'deleteNotification called');
    try {
      await NotificationApiService().deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      AppLogger.success(_tag, 'deleteNotification succeeded');
      notifyListeners();
    } catch (e) {
      AppLogger.error(_tag, 'deleteNotification error', e);
      setError(e.toString());
    }
  }

  void markNotificationAsReadLocally(String notificationId) {
    AppLogger.info(_tag, 'markNotificationAsReadLocally called');
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount--;
      notifyListeners();
    } else {
      AppLogger.warning(_tag, 'markNotificationAsReadLocally: notification not found or already read');
    }
  }
}
