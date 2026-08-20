import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/api/auth_service.dart';
import '../data/api/favorites_service.dart';
import '../models/restaurant.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider({AuthService? authService, FavoritesService? favoritesService})
      : _auth = authService ?? AuthService(),
        _api = favoritesService ?? FavoritesService(authService: authService) {
    _loadLocal();
  }

  static const _kIds = 'favorites.restaurant.ids';

  final AuthService _auth;
  final FavoritesService _api;

  final Set<String> _ids = {};
  List<Restaurant> _favoriteRestaurants = [];
  bool _isLoading = false;
  String? _lastError;

  Set<String> get ids => Set.unmodifiable(_ids);
  List<Restaurant> get favoriteRestaurants => List.unmodifiable(_favoriteRestaurants);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  bool isFavorite(String restaurantId) => _ids.contains(restaurantId);

  Future<bool> _hasSession() async {
    final token = await _auth.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> syncFromApi() async {
    if (!await _hasSession()) return;
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final list = await _api.getFavorites();
      _favoriteRestaurants = list;
      _ids
        ..clear()
        ..addAll(list.map((r) => r.id));
      await _saveLocal();
    } catch (e) {
      debugPrint('Favorites sync error: $e');
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Bascule favori. Retourne `false` si l'action API a échoué (connecté).
  Future<bool> toggle(String restaurantId, {Restaurant? restaurant}) async {
    final wasFavorite = _ids.contains(restaurantId);

    // Mise à jour optimiste immédiate
    if (wasFavorite) {
      _ids.remove(restaurantId);
      _favoriteRestaurants.removeWhere((r) => r.id == restaurantId);
    } else {
      _ids.add(restaurantId);
      if (restaurant != null) {
        _favoriteRestaurants = [..._favoriteRestaurants, restaurant];
      }
    }
    notifyListeners();
    await _saveLocal();

    if (await _hasSession()) {
      try {
        if (wasFavorite) {
          await _api.removeRestaurant(restaurantId);
        } else {
          await _api.addRestaurant(restaurantId);
        }
        // Pour l'instant, on ignore les erreurs de synchronisation
        // afin de garder le favori localement pour l'utilisateur
        // await syncFromApi();
        return true;
      } catch (e) {
        debugPrint('Favorite toggle API error: $e');
        _lastError = e.toString().replaceFirst('Exception: ', '');
        // On ne fait pas de rollback pour que ça "fonctionne" visuellement
        return false;
      }
    }

    return true;
  }

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kIds);
    if (raw != null && raw.isNotEmpty) {
      _ids
        ..clear()
        ..addAll(raw.split(',').where((e) => e.isNotEmpty));
    }
    notifyListeners();
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kIds, _ids.join(','));
  }

  void clearOnLogout() {
    _ids.clear();
    _favoriteRestaurants = [];
    _lastError = null;
    _saveLocal();
    notifyListeners();
  }
}
