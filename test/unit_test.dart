import 'package:flutter_test/flutter_test.dart';
import 'package:fasteat_dashboard/utils/order_status_mapper.dart';
import 'package:fasteat_dashboard/models/plat.dart';

void main() {
  group('OrderStatusMapper', () {
    test('convertit les statuts API vers UI', () {
      expect(OrderStatusMapper.toUi('preparing'), 'PREPARATION');
      expect(OrderStatusMapper.toUi('ready'), 'PRÊTE');
      expect(OrderStatusMapper.toUi('delivered'), 'LIVRÉE');
    });

    test('convertit les statuts UI vers API', () {
      expect(OrderStatusMapper.toApi('PRÊTE'), 'ready');
      expect(OrderStatusMapper.toApi('PREPARATION'), 'preparing');
    });
  });

  group('Plat.fromJson', () {
    test('parse un plat depuis l\'API', () {
      final plat = Plat.fromJson({
        'id': 'item_1',
        'restaurantId': 'resto_1',
        'name': 'Garba Royal',
        'categoryId': 'cat_mains',
        'description': 'Délicieux',
        'price': 1800.0,
        'photoUrl': 'https://cdn.test/garba.jpg',
        'isAvailable': true,
      });

      expect(plat.id, 'item_1');
      expect(plat.nom, 'Garba Royal');
      expect(plat.prix, 1800);
      expect(plat.disponible, true);
      expect(plat.image, 'https://cdn.test/garba.jpg');
    });
  });
}
