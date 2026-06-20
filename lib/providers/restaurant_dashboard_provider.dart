import 'package:flutter/foundation.dart';

import '../data/api/restaurant_dashboard_service.dart';

/// Gère horaires, promotions, analytics et conversations (API restaurant-dashboard).
class RestaurantDashboardProvider extends ChangeNotifier {
  RestaurantDashboardProvider({RestaurantDashboardService? service})
      : _service = service ?? RestaurantDashboardService();

  final RestaurantDashboardService _service;

  bool _isLoadingHours = false;
  bool _isLoadingPromotions = false;
  bool _isLoadingAnalytics = false;
  bool _isLoadingConversations = false;
  String? _error;

  bool get isLoadingHours => _isLoadingHours;
  bool get isLoadingPromotions => _isLoadingPromotions;
  bool get isLoadingAnalytics => _isLoadingAnalytics;
  bool get isLoadingConversations => _isLoadingConversations;
  String? get error => _error;

  List<Map<String, dynamic>> _hours = [];
  List<Map<String, dynamic>> _promotions = [];
  Map<String, dynamic> _analytics = {};
  List<Map<String, dynamic>> _conversations = [];

  List<Map<String, dynamic>> get hours => _hours;
  List<Map<String, dynamic>> get promotions => _promotions;
  Map<String, dynamic> get analytics => _analytics;
  List<Map<String, dynamic>> get conversations => _conversations;

  static const _dayNames = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  String dayName(int dayOfWeek) =>
      dayOfWeek >= 0 && dayOfWeek < _dayNames.length ? _dayNames[dayOfWeek] : 'Jour $dayOfWeek';

  Future<void> loadHours({bool useFallbackOnError = true}) async {
    _isLoadingHours = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _service.getHours();
      _hours = data.isNotEmpty ? data : (useFallbackOnError ? _defaultHours() : []);
    } catch (e) {
      debugPrint('Error loading hours: $e');
      _error = e.toString();
      _hours = useFallbackOnError ? _defaultHours() : [];
    } finally {
      _isLoadingHours = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _defaultHours() {
    return List.generate(7, (i) {
      final closed = i == 6;
      return {
        'dayOfWeek': i,
        'opensAt': closed ? '--:--' : '08:00',
        'closesAt': closed ? '--:--' : '22:00',
        'isClosed': closed,
      };
    });
  }

  Future<bool> saveDayHours({
    required int dayOfWeek,
    required String opensAt,
    required String closesAt,
    required bool isClosed,
  }) async {
    try {
      await _service.updateHours({
        'dayOfWeek': dayOfWeek,
        'opensAt': isClosed ? '00:00' : opensAt,
        'closesAt': isClosed ? '00:00' : closesAt,
        'isClosed': isClosed,
      });
      final idx = _hours.indexWhere((h) => h['dayOfWeek'] == dayOfWeek);
      final entry = {
        'dayOfWeek': dayOfWeek,
        'opensAt': isClosed ? '--:--' : opensAt,
        'closesAt': isClosed ? '--:--' : closesAt,
        'isClosed': isClosed,
      };
      if (idx >= 0) {
        _hours[idx] = entry;
      } else {
        _hours.add(entry);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving hours: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadPromotions({bool useFallbackOnError = true}) async {
    _isLoadingPromotions = true;
    _error = null;
    notifyListeners();
    try {
      _promotions = await _service.getPromotions();
    } catch (e) {
      debugPrint('Error loading promotions: $e');
      _error = e.toString();
      _promotions = useFallbackOnError ? _fallbackPromotions() : [];
    } finally {
      _isLoadingPromotions = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _fallbackPromotions() => [
        {
          'id': 'demo_1',
          'title': 'Offre Rafraîchissante',
          'description': '-10% sur toutes les boissons',
          'status': 'ACTIF',
          'uses': 245,
          'revenue': 82000,
          'remaining': '2 Jours',
        },
        {
          'id': 'demo_2',
          'title': 'Combo Atchéké-Poisson',
          'description': '1 Acheté = 1 Offert (Vendredi)',
          'status': 'EN PAUSE',
          'uses': 12,
          'revenue': 24500,
          'remaining': 'Suspendu',
        },
      ];

  Future<bool> createPromotion({
    required String title,
    required String description,
    required String discountType,
    required double discountValue,
    required String startsAt,
    required String endsAt,
    String? code,
  }) async {
    try {
      final created = await _service.createPromotion({
        'title': title,
        'description': description,
        'discountType': discountType,
        'discountValue': discountValue,
        'startsAt': startsAt,
        'endsAt': endsAt,
        if (code != null && code.isNotEmpty) 'code': code,
      });
      _promotions.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating promotion: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAnalytics({bool useFallbackOnError = true}) async {
    _isLoadingAnalytics = true;
    _error = null;
    notifyListeners();
    try {
      _analytics = await _service.getAnalyticsSummary();
    } catch (e) {
      debugPrint('Error loading analytics: $e');
      _error = e.toString();
      _analytics = useFallbackOnError ? {} : {};
    } finally {
      _isLoadingAnalytics = false;
      notifyListeners();
    }
  }

  Future<void> loadConversations({bool useFallbackOnError = true}) async {
    _isLoadingConversations = true;
    _error = null;
    notifyListeners();
    try {
      _conversations = await _service.getConversations();
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      _error = e.toString();
      _conversations = useFallbackOnError ? _fallbackConversations() : [];
    } finally {
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _fallbackConversations() => [
        {
          'id': 'conv_1',
          'clientName': 'Koffi Mensah',
          'lastMessage': 'Où est ma commande #FE-2024 ?',
          'updatedAt': DateTime.now().subtract(const Duration(minutes: 35)).toIso8601String(),
          'orderId': 'FE-2024',
        },
        {
          'id': 'conv_2',
          'clientName': 'Abla Gnonlonfoun',
          'lastMessage': 'Merci pour le piment supplémentaire !',
          'updatedAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        },
      ];

  int analyticsInt(String key, {int fallback = 0}) =>
      (_analytics[key] is num) ? (_analytics[key] as num).toInt() : fallback;

  double analyticsDouble(String key, {double fallback = 0}) =>
      (_analytics[key] is num) ? (_analytics[key] as num).toDouble() : fallback;
}
