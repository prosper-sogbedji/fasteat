import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/api/auth_service.dart';
import '../data/api/cart_mapper.dart';
import '../data/api/cart_service.dart';
import '../models/plat.dart';

import '../providers/restaurants_provider.dart';

class PanierLigne {
  PanierLigne({required this.plat, this.quantite = 1, this.cartItemId});

  final Plat plat;
  int quantite;
  final String? cartItemId;
  int get total => plat.prix * quantite;
}

class CrossRestaurantException implements Exception {
  final String currentRestoId;
  final String newRestoId;
  CrossRestaurantException(this.currentRestoId, this.newRestoId);
}

class PanierProvider extends ChangeNotifier {
  PanierProvider({CartService? cartService, AuthService? authService})
      : _cart = cartService ?? CartService(authService: authService),
        _auth = authService ?? AuthService() {
    _load();
  }

  static const _kPanierKey = 'panier.lignes';
  final CartService _cart;
  final AuthService _auth;
  final List<PanierLigne> _lignes = [];
  RestaurantsProvider? _restaurantsProvider;

  void updateRestaurants(RestaurantsProvider restaurants) {
    _restaurantsProvider = restaurants;
  }

  List<PanierLigne> get lignes => List.unmodifiable(_lignes);
  int get sousTotal => _lignes.fold(0, (sum, e) => sum + e.total);
  int get totalArticles => _lignes.fold(0, (sum, e) => sum + e.quantite);

  Future<bool> _hasSession() async {
    final token = await _auth.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> syncFromApi() async {
    if (!await _hasSession()) return;
    try {
      final cart = await _cart.getCart();
      final localHadItems = _lignes.isNotEmpty;
      final remoteLines = CartMapper.lignesFromCart(cart, restaurantsProvider: _restaurantsProvider);
      if (remoteLines.isEmpty && localHadItems) {
        debugPrint('Cart sync ignored: API returned no readable items while local cart has items.');
        return;
      }
      _lignes
        ..clear()
        ..addAll(remoteLines);
      await _saveLocal();
      notifyListeners();
    } catch (e) {
      debugPrint('Cart sync error: $e');
    }
  }

  Future<void> ajouterPlat(Plat plat) async {
    if (_lignes.isNotEmpty && _lignes.first.plat.restoId != plat.restoId) {
      throw CrossRestaurantException(_lignes.first.plat.restoId, plat.restoId);
    }
    if (await _hasSession()) {
      try {
        await _cart.addItem(
          restaurantId: plat.restoId,
          menuItemId: plat.id,
          quantity: 1,
        );
        await syncFromApi();
        if (_lignes.any((ligne) => ligne.plat.id == plat.id)) return;
      } catch (e) {
        debugPrint('Cart add API error: $e');
      }
    }

    final i = _lignes.indexWhere((e) => e.plat.id == plat.id);
    if (i >= 0) {
      _lignes[i].quantite++;
    } else {
      _lignes.add(PanierLigne(plat: plat));
    }
    await _saveLocal();
    notifyListeners();
  }

  Future<void> changerQuantite(String platId, int nouvelleQte) async {
    final i = _lignes.indexWhere((e) => e.plat.id == platId);
    if (i < 0) return;

    if (await _hasSession()) {
      final ligne = _lignes[i];
      final cartItemId = ligne.cartItemId;
      try {
        if (nouvelleQte <= 0) {
          if (cartItemId != null) {
            await _cart.removeItem(cartItemId);
          }
        } else if (cartItemId != null) {
          await _cart.updateItem(itemId: cartItemId, quantity: nouvelleQte);
        }
        await syncFromApi();
        return;
      } catch (e) {
        debugPrint('Cart update API error: $e');
      }
    }

    if (nouvelleQte <= 0) {
      _lignes.removeAt(i);
    } else {
      _lignes[i].quantite = nouvelleQte;
    }
    await _saveLocal();
    notifyListeners();
  }

  Future<void> vider() async {
    if (await _hasSession()) {
      try {
        await _cart.clear();
      } catch (e) {
        debugPrint('Cart clear API error: $e');
      }
    }
    _lignes.clear();
    await _saveLocal();
    notifyListeners();
  }

  Future<void> _load() async {
    await _loadLocal();
    if (await _hasSession()) {
      await syncFromApi();
    }
  }

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPanierKey);
    if (raw == null || raw.isEmpty) return;
    final data = jsonDecode(raw) as List<dynamic>;
    _lignes.clear();
    for (final item in data) {
      final map = Map<String, dynamic>.from(item as Map);
      final platId = map['platId'] as String? ?? '';
      final quantite = (map['quantite'] as num?)?.toInt() ?? 1;

      // Chercher le plat réel depuis l'API (via RestaurantsProvider)
      Plat? plat = _restaurantsProvider?.platParId(platId);

      // Si le plat n'est pas encore chargé, on recrée un plat minimal
      // depuis les données sauvegardées pour ne pas perdre l'info
      plat ??= Plat.fromJson({
        'id': platId,
        'name': map['platNom'] ?? 'Plat',
        'price': map['platPrix'] ?? 0,
        'restaurantId': map['restoId'] ?? '',
        'isAvailable': true,
      });

      _lignes.add(PanierLigne(plat: plat, quantite: quantite));
    }
    notifyListeners();
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _lignes.map((e) => {
      'platId': e.plat.id,
      'platNom': e.plat.nom,
      'platPrix': e.plat.prix,
      'restoId': e.plat.restoId,
      'quantite': e.quantite,
    }).toList();
    await prefs.setString(_kPanierKey, jsonEncode(data));
  }
}
