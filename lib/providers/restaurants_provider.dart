import 'package:flutter/foundation.dart';

import '../core/app_mode.dart';
import '../data/repositories/restaurants_repository.dart';
import '../models/plat.dart';
import '../models/restaurant.dart';

class RestaurantsProvider extends ChangeNotifier {
  RestaurantsProvider({RestaurantsRepository? repository})
      : _repository = repository ?? AppCatalogRepository.create() {
    loadRestaurants();
  }

  RestaurantsRepository _repository;

  void reloadMode() {
    _repository = AppCatalogRepository.create();
    loadRestaurants(force: true);
  }


  bool _isLoading = false;
  bool _menuLoading = false;
  String? _lastError;
  List<Restaurant> _restaurants = [];
  final Map<String, List<Plat>> _menusByRestaurant = {};

  bool get isLoading => _isLoading;
  bool get menuLoading => _menuLoading;
  bool get usingOfflineData => AppMode.isDemoMode;
  String? get lastError => _lastError;
  List<Restaurant> get restaurants => List.unmodifiable(_restaurants);


  Future<void> loadRestaurants({bool force = false}) async {
    if (_isLoading && !force) return;
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      _restaurants = await _repository.getRestaurants();
    } catch (e) {
      debugPrint('Error loading restaurants: $e');
      _restaurants = [];
      _lastError = 'Impossible de contacter le serveur. Verifiez votre connexion.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMenu(String restaurantId, {bool force = false}) async {
    if (restaurantId.isEmpty) return;
    if (!force && _menusByRestaurant.containsKey(restaurantId)) return;
    _menuLoading = true;
    notifyListeners();
    try {
      _menusByRestaurant[restaurantId] = await _repository.getRestaurantMenu(restaurantId);
    } catch (e) {
      debugPrint('Error loading menu for $restaurantId: $e');
      _menusByRestaurant[restaurantId] = [];
      _lastError = 'Impossible de charger le menu du restaurant.';
    } finally {
      _menuLoading = false;
      notifyListeners();
    }
  }

  List<Plat> menuFor(String restaurantId) {
    return List.unmodifiable(_menusByRestaurant[restaurantId] ?? const []);
  }

  Plat? platParId(String platId) {
    for (final menu in _menusByRestaurant.values) {
      for (final plat in menu) {
        if (plat.id == platId) return plat;
      }
    }
    return null;
  }

  Restaurant? maybeRestaurantById(String id) {
    for (final restaurant in _restaurants) {
      if (restaurant.id == id) return restaurant;
    }
    return null;
  }

  Restaurant restaurantById(String id) {
    return maybeRestaurantById(id) ??
        const Restaurant(
          id: '',
          nom: 'Restaurant introuvable',
          cuisine: '',
          quartier: '',
          note: 0,
          avis: 0,
          tempsEstime: '',
          livraison: false,
          qrCode: false,
          abonnement: '',
          images: [],
        );
  }
}
