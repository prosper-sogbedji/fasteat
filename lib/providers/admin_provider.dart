import 'package:flutter/foundation.dart';

import '../data/api/admin_dashboard_service.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider({AdminDashboardService? service})
      : _service = service ?? AdminDashboardService();

  final AdminDashboardService _service;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _dashboard = {};
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _restaurants = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get dashboard => _dashboard;
  List<Map<String, dynamic>> get users => _users;
  List<Map<String, dynamic>> get restaurants => _restaurants;

  Future<void> loadAll({bool allowMockFallback = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.getDashboard(),
        _service.getUsers(status: 'all'),
        _service.getRestaurants(status: 'all'),
      ]);
      _dashboard = results[0] as Map<String, dynamic>;
      _users = results[1] as List<Map<String, dynamic>>;
      _restaurants = results[2] as List<Map<String, dynamic>>;
    } catch (e) {
      debugPrint('Admin API error: $e');
      _error = e.toString();
      if (allowMockFallback) {
        _dashboard = {};
        _users = [];
        _restaurants = [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> suspendUser(String userId) async {
    try {
      await _service.updateUserStatus(userId, 'suspended');
      await loadAll(allowMockFallback: false);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRestaurantStatus(String restaurantId, String status) async {
    try {
      await _service.updateRestaurantStatus(restaurantId, status);
      await loadAll(allowMockFallback: false);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  int kpi(String key, {int fallback = 0}) {
    final v = _dashboard[key];
    if (v is num) return v.toInt();
    return fallback;
  }
}
