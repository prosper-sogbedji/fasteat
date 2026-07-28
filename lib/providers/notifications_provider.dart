import 'package:flutter/material.dart';

import '../data/api/auth_service.dart';
import '../data/api/notifications_service.dart';
import '../models/notification_item.dart';

class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider({AuthService? authService, NotificationsService? notificationsService})
      : _auth = authService ?? AuthService(),
        _api = notificationsService ?? NotificationsService(authService: authService);

  final AuthService _auth;
  final NotificationsService _api;

  final List<AppNotification> _items = [];
  bool _isLoading = false;
  String? _lastError;

  List<AppNotification> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  int get unreadCount => _items.where((n) => !n.isRead).length;

  Future<bool> _hasSession() async {
    final token = await _auth.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> refresh({String type = 'all'}) async {
    if (!await _hasSession()) {
      _items.clear();
      _lastError = 'Connectez-vous pour voir vos notifications.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      var list = await _api.getNotifications(type: type);
      if (list.isEmpty && type == 'all') {
        for (final fallback in ['order', 'promo', 'system', 'general']) {
          try {
            list = await _api.getNotifications(type: fallback);
            if (list.isNotEmpty) break;
          } catch (_) {}
        }
      }
      _items
        ..clear()
        ..addAll(list);
    } catch (e) {
      debugPrint('Notifications refresh error: $e');
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    if (!await _hasSession()) return false;
    final i = _items.indexWhere((n) => n.id == notificationId);
    if (i < 0) return false;

    final previous = _items[i];
    _items[i] = previous.copyWith(isRead: true);
    notifyListeners();

    try {
      await _api.markAsRead(notificationId);
      return true;
    } catch (e) {
      debugPrint('Mark read error: $e');
      _items[i] = previous;
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    if (!await _hasSession()) return false;

    final backup = List<AppNotification>.from(_items);
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
    notifyListeners();

    try {
      await _api.markAllAsRead();
      return true;
    } catch (e) {
      debugPrint('Mark all read error: $e');
      _items
        ..clear()
        ..addAll(backup);
      notifyListeners();
      return false;
    }
  }

  void clearOnLogout() {
    _items.clear();
    _lastError = null;
    notifyListeners();
  }
}
