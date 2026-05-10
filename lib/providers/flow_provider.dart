import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/commande.dart';

enum PaiementMethode { mtn, moov, carte }

class FlowProvider extends ChangeNotifier {
  FlowProvider() {
    _load();
  }

  static const _kMode = 'flow.mode';
  static const _kPaiement = 'flow.paiement';
  static const _kAdresse = 'flow.adresse';
  static const _kTable = 'flow.table';
  static const _kHeureRecup = 'flow.heure.recup';

  ModeCommande modeCommande = ModeCommande.programmee;
  PaiementMethode paiementMethode = PaiementMethode.mtn;

  String adresseLivraison = 'Quartier Haie Vive, Rue 402';
  String codeTableQr = 'TABLE-3';
  String heureRecuperation = '12:30';

  int fraisLivraison = 500;

  Future<void> setMode(ModeCommande mode) async {
    modeCommande = mode;
    await _save();
    notifyListeners();
  }

  Future<void> setPaiement(PaiementMethode methode) async {
    paiementMethode = methode;
    await _save();
    notifyListeners();
  }

  Future<void> setAdresse(String adresse) async {
    adresseLivraison = adresse;
    await _save();
    notifyListeners();
  }

  Future<void> setCodeTable(String code) async {
    codeTableQr = code;
    await _save();
    notifyListeners();
  }

  Future<void> setHeureRecuperation(String h) async {
    heureRecuperation = h;
    await _save();
    notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString(_kMode);
    final payName = prefs.getString(_kPaiement);
    modeCommande = ModeCommande.values.firstWhere(
      (e) => e.name == modeName,
      orElse: () => ModeCommande.programmee,
    );
    paiementMethode = PaiementMethode.values.firstWhere(
      (e) => e.name == payName,
      orElse: () => PaiementMethode.mtn,
    );
    adresseLivraison = prefs.getString(_kAdresse) ?? adresseLivraison;
    codeTableQr = prefs.getString(_kTable) ?? codeTableQr;
    heureRecuperation = prefs.getString(_kHeureRecup) ?? heureRecuperation;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMode, modeCommande.name);
    await prefs.setString(_kPaiement, paiementMethode.name);
    await prefs.setString(_kAdresse, adresseLivraison);
    await prefs.setString(_kTable, codeTableQr);
    await prefs.setString(_kHeureRecup, heureRecuperation);
  }
}
