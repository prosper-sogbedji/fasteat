import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/api/auth_service.dart';
import '../data/api/cart_service.dart';
import '../data/api/orders_service.dart';

import '../models/commande.dart';
import '../providers/flow_provider.dart';
import '../providers/panier_provider.dart';

class CommandesProvider extends ChangeNotifier {
  static const int delaiAnnulationClientMinutes = 20;
  static const int delaiAlerteValidationMinutes = 10;

  CommandesProvider({
    OrdersService? ordersService,
    CartService? cartService,
    AuthService? authService,
  })  : _orders = ordersService ?? OrdersService(authService: authService),
        _cart = cartService ?? CartService(authService: authService),
        _auth = authService ?? AuthService() {
    _load();
  }

  static const _kCommandesKey = 'commandes.items';
  final OrdersService _orders;
  final CartService _cart;
  final AuthService _auth;
  final List<Commande> _commandes = [];
  bool _isSyncing = false;

  List<Commande> get commandes => List.unmodifiable(_commandes);
  bool get isSyncing => _isSyncing;

  List<Commande> get enCours => _commandes.where(_estCommandeEnCours).toList();
  List<Commande> get terminees => _commandes.where((c) => c.statut == StatutCommande.livree).toList();

  Commande? get commandeActive {
    for (final c in _commandes) {
      if (_estCommandeEnCours(c)) return c;
    }
    return null;
  }

  Future<bool> _hasSession() async {
    final token = await _auth.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> refreshFromApi() async {
    if (!await _hasSession()) return;
    _isSyncing = true;
    notifyListeners();
    try {
      final remote = await _orders.getOrders();
      _commandes
        ..clear()
        ..addAll(remote);
      await _save();
    } catch (e) {
      debugPrint('Orders sync error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<bool> checkoutDepuisPanier({
    required FlowProvider flow,
    required PaiementMethode paiement,
    required String numeroPaiement,
  }) async {
    if (!await _hasSession()) return false;
    try {
      await _cart.updateFulfillment(
        mode: flow.modeCommande,
        pickupTime: flow.modeCommande == ModeCommande.programmee ? flow.heureRecuperation : null,
      );
      await _cart.checkout(
        paymentMethod: paiement,
        paymentPhoneNumber: numeroPaiement,
      );
      await refreshFromApi();
      return _commandes.isNotEmpty;
    } catch (e) {
      debugPrint('Checkout error: $e');
      return false;
    }
  }

  /// Mode démo hors ligne : enregistre une commande locale.
  Future<void> placerDepuisPanier({
    required List<PanierLigne> lignes,
    required ModeCommande mode,
    required int fraisLivraison,
    required String restaurantNom,
    required String restaurantId,
    DateTime? heureRecuperationSouhaitee,
  }) async {
    if (lignes.isEmpty) return;
    final now = DateTime.now();
    final id = '#FE-${(now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}';

    final commande = Commande(
      id: id,
      restaurantId: restaurantId,
      restaurantNom: restaurantNom,
      date: now,
      createdAt: now,
      mode: mode,
      statut: StatutCommande.enAttenteValidation,
      lignes: lignes
          .map(
            (l) => LigneCommande(
              platId: l.plat.id,
              nomPlat: l.plat.nom,
              quantite: l.quantite,
              prixUnitaire: l.plat.prix,
            ),
          )
          .toList(),
      fraisLivraison: fraisLivraison,
      heureRecuperationSouhaitee: heureRecuperationSouhaitee,
    );

    _commandes.insert(0, commande);
    await _save();
    notifyListeners();
  }

  bool canClientCancel(Commande c, {DateTime? now}) {
    if (c.statut != StatutCommande.enAttenteValidation) return false;
    final ref = now ?? DateTime.now();
    return ref.isBefore(c.createdAt.add(const Duration(minutes: delaiAnnulationClientMinutes)));
  }

  bool shouldSuggestCancelForDelay(Commande c, {DateTime? now}) {
    if (c.statut != StatutCommande.enAttenteValidation) return false;
    final ref = now ?? DateTime.now();
    return ref.isAfter(c.createdAt.add(const Duration(minutes: delaiAlerteValidationMinutes)));
  }

  Duration remainingClientCancel(Commande c, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final end = c.createdAt.add(const Duration(minutes: delaiAnnulationClientMinutes));
    final rem = end.difference(ref);
    if (rem.isNegative) return Duration.zero;
    return rem;
  }

  String? getCommandeAnnulationMessage(Commande c) {
    if (c.statut == StatutCommande.annuleeRestaurant && c.motifAnnulation != null) {
      return 'Annulée par le restaurant : ${c.motifAnnulation}';
    }
    if (c.statut == StatutCommande.annuleeClient && c.motifAnnulation != null) {
      return 'Annulée par vous : ${c.motifAnnulation}';
    }
    if (c.statut == StatutCommande.expiree) {
      return 'Commande expirée (pas de validation dans le délai).';
    }
    return null;
  }

  Future<void> annulerCommandeParClient(String id, {String? motif}) async {
    final i = _commandes.indexWhere((c) => c.id == id);
    if (i < 0) return;
    if (!canClientCancel(_commandes[i])) return;

    if (await _hasSession()) {
      try {
        await _orders.cancelOrder(id);
        await refreshFromApi();
        return;
      } catch (e) {
        debugPrint('Cancel order API error: $e');
      }
    }

    _commandes[i] = _commandes[i].copyWith(
      statut: StatutCommande.annuleeClient,
      motifAnnulation: motif ?? "Annulation depuis l'app client",
    );
    await _save();
    notifyListeners();
  }

  bool _estCommandeEnCours(Commande c) {
    return c.statut == StatutCommande.enAttenteValidation ||
        c.statut == StatutCommande.preparation ||
        c.statut == StatutCommande.prete ||
        c.statut == StatutCommande.livraison;
  }

  Future<void> _load() async {
    if (await _hasSession()) {
      // Toujours synchroniser depuis l'API si l'utilisateur est connecté
      await refreshFromApi();
      // Ne jamais utiliser le cache local quand on est connecté
      // (le cache pourrait contenir des données obsolètes après reset backend)
      return;
    }
    // Non connecté : vider le cache local (données potentiellement orphelines)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCommandesKey);
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _commandes.map((e) => e.toJson()).toList();
    await prefs.setString(_kCommandesKey, jsonEncode(data));
  }
}
