import '../models/notification_model.dart';
import '../services/api_service.dart';
import 'base_view_model.dart';

class NotificationsViewModel extends BaseViewModel {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  Future<void> loadNotifications() async {
    try {
      setLoading();
      final data = await NotificationApiService().getNotifications();
      _notifications = (data['notifications'] as List? ?? [])
          .map((json) => NotificationModel.fromJson(json))
          .toList();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await NotificationApiService().markNotificationAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        notifyListeners();
      }
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      setLoading();
      await NotificationApiService().markAllNotificationsAsRead();
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      _unreadCount = 0;
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await NotificationApiService().deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  void markNotificationAsReadLocally(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount--;
      notifyListeners();
    }
  }
}
