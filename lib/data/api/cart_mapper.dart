import '../../models/plat.dart';
import '../../providers/panier_provider.dart';
import '../../providers/restaurants_provider.dart';

class CartMapper {
  static List<PanierLigne> lignesFromCart(Map<String, dynamic> cart, {RestaurantsProvider? restaurantsProvider}) {
    final items = _extractItems(cart);
    final lignes = <PanierLigne>[];
    for (final raw in items) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final menuItem = map['menuItem'];
      final menuMap = menuItem is Map ? Map<String, dynamic>.from(menuItem) : <String, dynamic>{};
      
      final platId = (map['menuItemId'] ?? map['menu_item_id'] ?? menuMap['id'] ?? menuMap['_id'] ?? '')?.toString() ?? '';
      
      Plat? plat;
      if (restaurantsProvider != null && platId.isNotEmpty) {
        plat = restaurantsProvider.platParId(platId);
      }

      if (plat == null) {
        if (menuMap.isEmpty && map.containsKey('name')) {
          menuMap.addAll({
            'id': platId,
            'restaurantId': map['restaurantId'],
            'name': map['name'],
            'price': map['price'] ?? map['unitPrice'],
            'photoUrl': map['photoUrl'],
            'isAvailable': true,
          });
        } else if (menuMap.isEmpty && map.containsKey('unitPrice')) {
          menuMap.addAll({
            'id': platId,
            'restaurantId': map['restaurantId'],
            'name': 'Plat',
            'price': map['unitPrice'],
            'isAvailable': true,
          });
        } else if (menuMap.isNotEmpty && platId.isNotEmpty) {
          menuMap['id'] ??= platId;
          menuMap['restaurantId'] ??= map['restaurantId'];
        }
        plat = Plat.fromJson(menuMap);
      }

      final qtyRaw = map['quantity'] ?? map['quantite'] ?? 1;
      final qty = qtyRaw is num ? qtyRaw.toInt() : int.tryParse(qtyRaw.toString()) ?? 1;
      lignes.add(
        PanierLigne(
          plat: plat,
          quantite: qty,
          cartItemId: (map['id'] ?? map['cartItemId'])?.toString(),
        ),
      );
    }
    return lignes;
  }

  static List<dynamic> _extractItems(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in ['items', 'cartItems', 'lines', 'data', 'results']) {
        final value = data[key];
        if (value is List) return value;
        if (value is Map<String, dynamic>) {
          final nested = _extractItems(value);
          if (nested.isNotEmpty) return nested;
        }
      }
    }
    return const [];
  }
}
