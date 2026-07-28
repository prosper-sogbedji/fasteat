import '../../core/app_mode.dart';
import '../../models/plat.dart';
import '../../models/restaurant.dart';
import '../api/restaurants_service.dart';
import '../mock/mock_plats.dart';
import '../mock/mock_restaurants.dart';

enum CatalogSourceMode { demo, api }

abstract interface class RestaurantsRepository {
  Future<List<Restaurant>> getRestaurants();
  Future<List<Plat>> getRestaurantMenu(String restaurantId);
}

class DemoRestaurantsRepository implements RestaurantsRepository {
  @override
  Future<List<Restaurant>> getRestaurants() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return mockRestaurants;
  }

  @override
  Future<List<Plat>> getRestaurantMenu(String restaurantId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return mockPlats.where((plat) => plat.restoId == restaurantId).toList();
  }
}

class ApiRestaurantsRepository implements RestaurantsRepository {
  ApiRestaurantsRepository({RestaurantsService? service})
      : _service = service ?? RestaurantsService();

  final RestaurantsService _service;

  @override
  Future<List<Restaurant>> getRestaurants() => _service.getRestaurants();

  @override
  Future<List<Plat>> getRestaurantMenu(String restaurantId) {
    return _service.getRestaurantMenu(restaurantId);
  }
}

/// Factory qui crée le bon repository selon le mode actif au moment de l'appel.
/// Utilise [AppMode.isDemoMode] (bascule possible à l'exécution via menu dev).
class AppCatalogRepository {
  static RestaurantsRepository create() {
    return AppMode.isDemoMode
        ? DemoRestaurantsRepository()
        : ApiRestaurantsRepository();
  }
}
