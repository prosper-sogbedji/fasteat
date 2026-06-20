import 'package:flutter/foundation.dart';

import '../data/api/auth_service.dart';
import '../data/api/restaurant_dashboard_service.dart';
import '../models/menu_catalogue.dart';
import '../models/plat.dart';

class RestaurantMenuProvider extends ChangeNotifier {
  final RestaurantDashboardService _apiService = RestaurantDashboardService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingOrders = false;
  bool get isLoadingOrders => _isLoadingOrders;

  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> get orders => _orders;

  RestaurantMenuProvider() {
    loadMenuItems();
    loadOrders();
  }

  List<MenuCatalogueEntry> _entries = [];

  String? currentRestaurantId;

  /// Retourne true si l'ID du restaurant correspond au compte de démonstration.
  bool _isMockRestaurant(String? restaurantId) {
    return restaurantId == 'r1' || restaurantId == null;
  }

  bool get isMock => _isMockRestaurant(currentRestaurantId);

  Future<void> loadMenuItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      final session = await AuthService.getCurrentSession();
      final rId = session['restaurant_id'];
      currentRestaurantId = rId;

      final items = await _apiService.getMenuItems();
      if (items.isNotEmpty) {
        _entries = items.map((json) {
          final map = json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json as Map);
          final plat = Plat.fromJson(map);
          return MenuCatalogueEntry(
            plat: plat.copyWith(restoId: plat.restoId.isNotEmpty ? plat.restoId : (rId ?? '')),
            statut: StatutCataloguePlat.publie,
            maj: DateTime.now(),
          );
        }).toList();
      } else if (_isMockRestaurant(rId)) {
        _entries = _getFallbackMenuItems();
      } else {
        _entries = [];
      }
    } catch (e) {
      debugPrint('Error loading menu items: $e');
      // En cas d'erreur réseau, ne jamais afficher les données démo pour un vrai compte
      final session = await AuthService.getCurrentSession();
      final rId = session['restaurant_id'];
      _entries = _isMockRestaurant(rId) ? _getFallbackMenuItems() : [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<MenuCatalogueEntry> _getFallbackMenuItems() {
    return [
      MenuCatalogueEntry(
        plat: Plat(
          id: 'mock_1',
          restoId: 'r1',
          nom: 'Garba Royal Classique',
          categorie: 'plats',
          description: 'Manioc râpé (Attiéké) avec thon frit croustillant, piments frais découpés et oignons caramélisés.',
          prix: 1800,
          images: ['assets/images/plat_real_1.jpg'],
          disponible: true,
        ),
        statut: StatutCataloguePlat.publie,
        maj: DateTime.now(),
      ),
      MenuCatalogueEntry(
        plat: Plat(
          id: 'mock_2',
          restoId: 'r1',
          nom: 'Aloco Traditionnel Pimenté',
          categorie: 'accompagnements',
          description: 'Bananes plantains mûres frites à la perfection, servies avec une sauce piment maison.',
          prix: 1000,
          images: ['assets/images/plat_real_2.jpg'],
          disponible: true,
        ),
        statut: StatutCataloguePlat.publie,
        maj: DateTime.now(),
      ),
    ];
  }

  List<MenuCatalogueEntry> entreesPourRestaurant(String restoId) {
    return _entries;
  }

  List<Plat> platsPublicsPourRestaurant(String restoId) {
    return _entries
        .where((e) => e.plat.restoId == restoId && e.statut == StatutCataloguePlat.publie)
        .map((e) => e.plat)
        .toList();
  }

  Plat? platParId(String platId) {
    for (final e in _entries) {
      if (e.plat.id == platId) return e.plat;
    }
    return null;
  }

  MenuCatalogueEntry? entreeParPlatId(String platId) {
    for (final e in _entries) {
      if (e.plat.id == platId) return e;
    }
    return null;
  }

  Future<bool> enregistrerDepuisAssistant({
    required String restoId,
    required PlatWizardDraft draft,
    required bool publier,
    String? platId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final categoryId = draft.categorie.toLowerCase() == 'plats' ? 'cat_mains' : draft.categorie;
      final payload = {
        'name': draft.nom,
        'description': draft.descriptionFusionnee,
        'price': draft.prixFcfa,
        'categoryId': categoryId,
        'photoUrl': draft.imagesSelection.isNotEmpty ? draft.imagesSelection.first : 'https://placehold.co/400x300.png',
        'isAvailable': publier,
      };
      
      bool apiSuccess = false;
      try {
        if (platId != null) {
          await _apiService.updateMenuItem(platId, payload);
        } else {
          await _apiService.createMenuItem(payload);
        }
        apiSuccess = true;
      } catch (apiError) {
        debugPrint('API operation failed, performing local fallback: $apiError');
      }

      final idToUse = platId ?? 'plat_${DateTime.now().millisecondsSinceEpoch}';

      final localPlat = Plat(
        id: idToUse,
        restoId: restoId,
        nom: draft.nom.trim(),
        categorie: categoryId,
        description: draft.descriptionFusionnee,
        prix: draft.prixFcfa,
        images: draft.imagesSelection.isNotEmpty ? [draft.imagesSelection.first] : ['https://placehold.co/400x300.png'],
        disponible: publier,
      );

      if (apiSuccess) {
        await loadMenuItems();
        if (platId == null && !_entries.any((e) => e.plat.nom.toLowerCase() == draft.nom.trim().toLowerCase())) {
          _entries.add(MenuCatalogueEntry(
            plat: localPlat,
            statut: publier ? StatutCataloguePlat.publie : StatutCataloguePlat.brouillon,
            maj: DateTime.now(),
          ));
        }
      } else {
        if (platId != null) {
          final index = _entries.indexWhere((e) => e.plat.id == platId);
          if (index != -1) {
            _entries[index] = MenuCatalogueEntry(
              plat: localPlat,
              statut: publier ? StatutCataloguePlat.publie : StatutCataloguePlat.brouillon,
              maj: DateTime.now(),
            );
          }
        } else {
          _entries.add(MenuCatalogueEntry(
            plat: localPlat,
            statut: publier ? StatutCataloguePlat.publie : StatutCataloguePlat.brouillon,
            maj: DateTime.now(),
          ));
        }
      }
      return true;
    } catch (e) {
      debugPrint('Error creating/updating menu item: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> definirDisponibilitePlat(String platId, bool disponible) async {
    final i = _entries.indexWhere((e) => e.plat.id == platId);
    if (i < 0) return;
    
    final e = _entries[i];
    _entries[i] = e.copyWith(plat: e.plat.copyWith(disponible: disponible));
    notifyListeners();

    try {
      await _apiService.updateMenuItemAvailability(platId, disponible);
    } catch (err) {
      _entries[i] = e;
      notifyListeners();
    }
  }

  void publierBrouillon(String platId) {
    final i = _entries.indexWhere((e) => e.plat.id == platId && e.statut == StatutCataloguePlat.brouillon);
    if (i < 0) return;
    final e = _entries[i];
    final now = DateTime.now();
    _entries[i] = e.copyWith(
      statut: StatutCataloguePlat.publie,
      maj: now,
      datePublication: now,
      plat: e.plat.copyWith(disponible: true),
    );
    notifyListeners();
  }

  void supprimerBrouillon(String platId) {
    _entries.removeWhere((e) => e.plat.id == platId && e.statut == StatutCataloguePlat.brouillon);
    notifyListeners();
  }

  Future<bool> supprimerPlat(String platId) async {
    final i = _entries.indexWhere((e) => e.plat.id == platId);
    if (i < 0) return false;

    final entry = _entries[i];
    _entries.removeAt(i);
    notifyListeners();

    try {
      await _apiService.deleteMenuItem(platId);
      return true;
    } catch (e) {
      debugPrint('Error deleting menu item: $e');
      // Rollback
      _entries.insert(i, entry);
      notifyListeners();
      return false;
    }
  }

  Future<bool> modifierPlat({
    required String platId,
    required String nom,
    required int prix,
    required String categorie,
    required bool disponible,
  }) async {
    final i = _entries.indexWhere((e) => e.plat.id == platId);
    if (i < 0) return false;

    final oldEntry = _entries[i];
    final now = DateTime.now();
    final updatedPlat = oldEntry.plat.copyWith(
      nom: nom.trim(),
      prix: prix,
      categorie: categorie,
      disponible: disponible,
    );
    
    _entries[i] = oldEntry.copyWith(
      plat: updatedPlat,
      maj: now,
    );
    notifyListeners();

    try {
      final payload = {
        'name': nom.trim(),
        'price': prix,
        'categoryId': categorie.toLowerCase() == 'plats' ? 'cat_mains' : categorie,
        'isAvailable': disponible,
      };
      await _apiService.updateMenuItem(platId, payload);
      return true;
    } catch (e) {
      debugPrint('Error updating menu item: $e');
      // Rollback
      _entries[i] = oldEntry;
      notifyListeners();
      return false;
    }
  }

  Future<bool> importerPlatsDemo(String restoId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final listPlatsDemo = [
        {
          'name': 'Garba Royal Classique',
          'description': 'Manioc râpé (Attiéké) avec thon frit croustillant, piments frais découpés et oignons caramélisés.',
          'price': 1800,
          'categoryId': 'plats',
          'photoUrl': 'assets/images/plat_real_1.jpg',
          'isAvailable': true,
        },
        {
          'name': 'Aloco Traditionnel Pimenté',
          'description': 'Bananes plantains mûres frites à la perfection, servies avec une sauce piment maison béninoise.',
          'price': 1000,
          'categoryId': 'accompagnements',
          'photoUrl': 'assets/images/plat_real_2.jpg',
          'isAvailable': true,
        },
        {
          'name': 'Atassi Royal Complet',
          'description': 'Mélange traditionnel de riz et de haricots rouges locaux cuisinés à l’étouffée, servies avec friture de tomates et poisson frit.',
          'price': 2500,
          'categoryId': 'plats',
          'photoUrl': 'assets/images/resto_real_1.jpg',
          'isAvailable': true,
        },
        {
          'name': 'Jus de Bissap Parfumé',
          'description': 'Boisson traditionnelle rafraîchissante faite de fleurs d’hibiscus séchées infusées avec de la menthe et de l’essence de vanille.',
          'price': 600,
          'categoryId': 'boissons',
          'photoUrl': 'assets/images/resto_real_2.jpg',
          'isAvailable': true,
        },
      ];

      bool allApiFailed = true;
      for (final item in listPlatsDemo) {
        try {
          await _apiService.createMenuItem(item);
          allApiFailed = false;
        } catch (e) {
          debugPrint('API Error for demo item: $e');
          // Fallback local
          final localPlat = Plat(
            id: 'demo_${DateTime.now().microsecondsSinceEpoch}',
            restoId: restoId,
            nom: item['name'] as String,
            categorie: item['categoryId'] as String,
            description: item['description'] as String,
            prix: item['price'] as int,
            images: [item['photoUrl'] as String],
            disponible: item['isAvailable'] as bool,
          );
          _entries.add(MenuCatalogueEntry(
            plat: localPlat,
            statut: StatutCataloguePlat.publie,
            maj: DateTime.now(),
          ));
        }
      }
      
      if (!allApiFailed) {
        await loadMenuItems();
      }
      return true;
    } catch (e) {
      debugPrint('Error importing demo items: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrders() async {
    _isLoadingOrders = true;
    notifyListeners();
    try {
      final session = await AuthService.getCurrentSession();
      final rId = session['restaurant_id'];

      final items = await _apiService.getOrders();
      if (items.isNotEmpty) {
        _orders = items;
      } else if (_isMockRestaurant(rId)) {
        _orders = _getFallbackOrders();
      } else {
        _orders = [];
      }
    } catch (e) {
      debugPrint('Error loading orders from API: $e');
      final session = await AuthService.getCurrentSession();
      final rId = session['restaurant_id'];
      _orders = _isMockRestaurant(rId) ? _getFallbackOrders() : [];
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _getFallbackOrders() {
    return [
      {
        'id': 'FA-1245',
        'client': 'Aurelle Gbemede',
        'items': [
          {'name': 'Riz Gras au Poulet', 'qty': 2, 'price': 2500},
          {'name': 'Coca Cola 33cl', 'qty': 1, 'price': 500},
        ],
        'total': 5500,
        'time': 'Il y a 5 min',
        'status': 'PREPARATION',
        'isPriority': true,
      },
      {
        'id': 'FA-1244',
        'client': 'Marc Kougbe',
        'items': [
          {'name': 'Atchéké Poisson', 'qty': 1, 'price': 2000},
        ],
        'total': 2000,
        'time': 'Il y a 12 min',
        'status': 'NOUVEAU',
        'isPriority': false,
      },
      {
        'id': 'FA-1240',
        'client': 'Jean Houndegla',
        'items': [
          {'name': 'Garba royal classique', 'qty': 3, 'price': 1800},
          {'name': 'Jus de Bissap', 'qty': 3, 'price': 600},
        ],
        'total': 7200,
        'time': 'Il y a 1 heure',
        'status': 'PRÊTE',
        'isPriority': false,
      },
      {
        'id': 'FA-1239',
        'client': 'Lucie Gbaguidi',
        'items': [
          {'name': 'Doko sucrés x10', 'qty': 1, 'price': 1000},
        ],
        'total': 1000,
        'time': 'Hier',
        'status': 'LIVRÉE',
        'isPriority': false,
      },
    ];
  }

  Future<bool> changerStatutCommande(String orderId, String nouveauStatut) async {
    final idx = _orders.indexWhere((o) => o['id'] == orderId);
    if (idx < 0) return false;

    final oldOrder = _orders[idx];
    _orders[idx] = Map<String, dynamic>.from(oldOrder)..['status'] = nouveauStatut.toUpperCase();
    notifyListeners();

    try {
      await _apiService.updateOrderStatus(orderId, nouveauStatut);
      return true;
    } catch (e) {
      debugPrint('Error updating order status on server: $e');
      _orders[idx] = oldOrder;
      notifyListeners();
      return false;
    }
  }
}
