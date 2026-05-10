import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock/mock_restaurants.dart';
import '../data/mock/mock_commandes.dart';
import '../models/commande.dart';
import '../providers/panier_provider.dart';

class CommandesProvider extends ChangeNotifier {
  static const int delaiAnnulationClientMinutes = 20;
  static const int delaiAlerteValidationMinutes = 10;

  CommandesProvider() {
    _load();
  }

  static const _kCommandesKey = 'commandes.items';
  final List<Commande> _commandes = [];

  List<Commande> get commandes => List.unmodifiable(_commandes);

  List<Commande> get enCours => _commandes.where(_estCommandeEnCours).toList();
  List<Commande> get terminees => _commandes.where((c) => c.statut == StatutCommande.livree).toList();

  Commande? get commandeActive {
    for (final c in _commandes) {
      if (_estCommandeEnCours(c)) {
        return c;
      }
    }
    return null;
  }

  Future<void> placerDepuisPanier({
    required List<PanierLigne> lignes,
    required ModeCommande mode,
    required int fraisLivraison,
    DateTime? heureRecuperationSouhaitee,
  }) async {
    if (lignes.isEmpty) return;
    final first = lignes.first.plat;
    final resto = mockRestaurants.firstWhere(
      (r) => r.id == first.restoId,
      orElse: () => mockRestaurants.first,
    );
    final now = DateTime.now();
    final id = '#FE-${(now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}';

    final commande = Commande(
      id: id,
      restaurantId: resto.id,
      restaurantNom: resto.nom,
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
      return "Commande expirée (pas de validation dans le délai).";
    }
    return null;
  }

  Future<void> traiterDecisionRestaurant({
    required String id,
    required bool accepter,
    String? motifAnnulation,
  }) async {
    final i = _commandes.indexWhere((c) => c.id == id);
    if (i < 0) return;
    final c = _commandes[i];
    if (c.statut != StatutCommande.enAttenteValidation) return;

    if (!accepter) {
      _commandes[i] = c.copyWith(
        statut: StatutCommande.annuleeRestaurant,
        motifAnnulation: motifAnnulation ?? 'Plat indisponible',
      );
    } else {
      _commandes[i] = c.copyWith(
        statut: StatutCommande.preparation,
        validatedAt: DateTime.now(),
      );
    }
    await _save();
    notifyListeners();
  }

  Future<void> avancerStatut(String id) async {
    final i = _commandes.indexWhere((c) => c.id == id);
    if (i < 0) return;
    final c = _commandes[i];
    StatutCommande next = c.statut;
    switch (c.statut) {
      case StatutCommande.enAttenteValidation:
        next = StatutCommande.preparation;
      case StatutCommande.preparation:
        next = StatutCommande.prete;
      case StatutCommande.prete:
        next = StatutCommande.livraison;
      case StatutCommande.livraison:
        next = StatutCommande.livree;
      default:
        return;
    }
    _commandes[i] = c.copyWith(
      statut: next,
      validatedAt: next == StatutCommande.preparation ? (c.validatedAt ?? DateTime.now()) : c.validatedAt,
      readyAt: next == StatutCommande.prete ? DateTime.now() : c.readyAt,
    );
    await _save();
    notifyListeners();
  }

  Future<void> annulerCommandeParClient(String id, {String? motif}) async {
    final i = _commandes.indexWhere((c) => c.id == id);
    if (i < 0) return;
    if (!canClientCancel(_commandes[i])) return;
    _commandes[i] = _commandes[i].copyWith(
      statut: StatutCommande.annuleeClient,
      motifAnnulation: motif ?? "Annulation depuis l'app client",
    );
    await _save();
    notifyListeners();
  }

  Future<void> annulerCommandeParRestaurant(String id, {String? motif}) async {
    final i = _commandes.indexWhere((c) => c.id == id);
    if (i < 0) return;
    _commandes[i] = _commandes[i].copyWith(
      statut: StatutCommande.annuleeRestaurant,
      motifAnnulation: motif ?? 'Rupture de stock',
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
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCommandesKey);
    if (raw == null || raw.isEmpty) {
      _commandes
        ..clear()
        ..addAll(mockCommandes);
      await _save();
      notifyListeners();
      return;
    }
    final arr = jsonDecode(raw) as List<dynamic>;
    _commandes
      ..clear()
      ..addAll(
        arr.map((e) => Commande.fromJson(Map<String, dynamic>.from(e as Map))),
      );
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _commandes.map((e) => e.toJson()).toList();
    await prefs.setString(_kCommandesKey, jsonEncode(data));
  }
}
