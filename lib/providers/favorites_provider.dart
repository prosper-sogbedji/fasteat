import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider() {
    _load();
  }

  static const _kIds = 'favorites.restaurant.ids';

  final Set<String> _ids = {};

  Set<String> get ids => Set.unmodifiable(_ids);

  bool isFavorite(String restaurantId) => _ids.contains(restaurantId);

  Future<void> toggle(String restaurantId) async {
    if (_ids.contains(restaurantId)) {
      _ids.remove(restaurantId);
    } else {
      _ids.add(restaurantId);
    }
    await _save();
    notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kIds);
    if (raw != null && raw.isNotEmpty) {
      _ids
        ..clear()
        ..addAll(raw.split(',').where((e) => e.isNotEmpty));
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kIds, _ids.join(','));
  }
}
