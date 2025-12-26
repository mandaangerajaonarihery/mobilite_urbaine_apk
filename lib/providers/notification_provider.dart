import 'package:flutter/foundation.dart';

class NotificationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];

  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);

  int get count => _notifications.length;

  /// Ajouter une notification
  void addNotification(String type, dynamic data) {
    _notifications.insert(0, {
      'type': type,
      'data': data,
      'timestamp': DateTime.now(),
      'read': false,
    });
    notifyListeners();
  }

  /// Marquer toutes les notifications comme lues
  void markAllAsRead() {
    for (var notif in _notifications) {
      notif['read'] = true;
    }
    notifyListeners();
  }

  /// Supprimer toutes les notifications
  void clear() {
    _notifications.clear();
    notifyListeners();
  }
}
