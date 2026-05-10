import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock/mock_plats.dart';
import '../models/plat.dart';

class PanierLigne {
  PanierLigne({required this.plat, this.quantite = 1});
  final Plat plat;
  int quantite;
  int get total => plat.prix * quantite;
}

class PanierProvider extends ChangeNotifier {
  PanierProvider() {
    _load();
  }

  static const _kPanierKey = 'panier.lignes';
  final List<PanierLigne> _lignes = [];

  List<PanierLigne> get lignes => List.unmodifiable(_lignes);
  int get sousTotal => _lignes.fold(0, (sum, e) => sum + e.total);
  int get totalArticles => _lignes.fold(0, (sum, e) => sum + e.quantite);

  Future<void> ajouterPlat(Plat plat) async {
    final i = _lignes.indexWhere((e) => e.plat.id == plat.id);
    if (i >= 0) {
      _lignes[i].quantite++;
    } else {
      _lignes.add(PanierLigne(plat: plat));
    }
    await _save();
    notifyListeners();
  }

  Future<void> changerQuantite(String platId, int nouvelleQte) async {
    final i = _lignes.indexWhere((e) => e.plat.id == platId);
    if (i < 0) return;
    if (nouvelleQte <= 0) {
      _lignes.removeAt(i);
    } else {
      _lignes[i].quantite = nouvelleQte;
    }
    await _save();
    notifyListeners();
  }

  Future<void> vider() async {
    _lignes.clear();
    await _save();
    notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPanierKey);
    if (raw == null || raw.isEmpty) return;
    final data = jsonDecode(raw) as List<dynamic>;
    _lignes.clear();
    for (final item in data) {
      final map = Map<String, dynamic>.from(item as Map);
      final platId = map['platId'] as String;
      final quantite = map['quantite'] as int;
      final plat = mockPlats.firstWhere(
        (p) => p.id == platId,
        orElse: () => mockPlats.first,
      );
      _lignes.add(PanierLigne(plat: plat, quantite: quantite));
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _lignes
        .map((e) => {'platId': e.plat.id, 'quantite': e.quantite})
        .toList();
    await prefs.setString(_kPanierKey, jsonEncode(data));
  }
}
