import 'dart:async';
import 'package:flutter/material.dart';
import 'package:novopharma/models/notification_model.dart';
import 'package:novopharma/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  StreamSubscription? _notificationsSubscription;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  // Initialize and listen to notifications
  void initializeNotifications(String userId) {
    // Don't reinitialize if already listening to the same user
    if (_notificationsSubscription != null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    _notificationsSubscription = _notificationService
        .streamUserNotifications(userId)
        .listen(
          (notifications) {
            _notifications = notifications;
            _unreadCount = notifications.where((n) => !n.isRead).length;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  // Mark notification as read
  Future<void> markAsRead(String userId, String notificationId) async {
    await _notificationService.markAsRead(userId, notificationId);
  }

  // Mark all as read
  Future<void> markAllAsRead(String userId) async {
    await _notificationService.markAllAsRead(userId);
  }

  // Delete notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    await _notificationService.deleteNotification(userId, notificationId);
  }

  // Handle notification tap and navigate
  String? getNavigationRoute(NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.newTraining:
        return '/formation/${notification.resourceId}';
      case NotificationType.newBadge:
        return '/badges'; // Navigate to badges screen, could highlight specific badge
      case NotificationType.achievement:
        return '/badges';
      case NotificationType.reminder:
        return null;
    }
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }
}
