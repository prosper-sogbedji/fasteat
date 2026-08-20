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
  static const _kRestoQr = 'flow.resto.qr';
  static const _kHeureRecup = 'flow.heure.recup';
  static const _kNumeroPaiement = 'flow.numero.paiement';

  ModeCommande modeCommande = ModeCommande.programmee;
  PaiementMethode paiementMethode = PaiementMethode.mtn;
  ModeConsommation? modeConsommation;

  /// Numéro mobile money / opérateur utilisé pour ce paiement (saisie utilisateur).
  String numeroPaiement = '';

  String adresseLivraison = '';
  String codeTableQr = '';
  String restoIdQr = '';
  String heureRecuperation = '';

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

  Future<void> setModeConsommation(ModeConsommation mode) async {
    modeConsommation = mode;
    // Si ce n'est pas livraison, on annule les frais de livraison pour l'affichage (sauf si géré ailleurs)
    // Mais on garde la logique dans le panier
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

  /// Appelé après un scan QR réussi. Stocke le restoId et le numéro de table.
  Future<void> setTableQr(String restoId, String table) async {
    restoIdQr = restoId;
    codeTableQr = table;
    // Forcer le mode "Sur place" automatiquement
    modeConsommation = ModeConsommation.surPlace;
    modeCommande = ModeCommande.qrCode;
    await _save();
    notifyListeners();
  }

  Future<void> setHeureRecuperation(String h) async {
    heureRecuperation = h;
    await _save();
    notifyListeners();
  }

  Future<void> setNumeroPaiement(String value) async {
    numeroPaiement = value;
    await _save();
    notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final payName = prefs.getString(_kPaiement);
    final consName = prefs.getString('flow.modeConsommation');
    modeCommande = ModeCommande.programmee;
    paiementMethode = PaiementMethode.values.firstWhere(
      (e) => e.name == payName,
      orElse: () => PaiementMethode.mtn,
    );
    if (consName != null) {
      modeConsommation = ModeConsommation.values.firstWhere(
        (e) => e.name == consName,
        orElse: () => ModeConsommation.surPlace,
      );
    } else {
      modeConsommation = null;
    }
    adresseLivraison = prefs.getString(_kAdresse) ?? adresseLivraison;
    codeTableQr = prefs.getString(_kTable) ?? codeTableQr;
    restoIdQr = prefs.getString(_kRestoQr) ?? restoIdQr;
    heureRecuperation = prefs.getString(_kHeureRecup) ?? heureRecuperation;
    numeroPaiement = prefs.getString(_kNumeroPaiement) ?? numeroPaiement;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMode, modeCommande.name);
    await prefs.setString(_kPaiement, paiementMethode.name);
    if (modeConsommation != null) {
      await prefs.setString('flow.modeConsommation', modeConsommation!.name);
    } else {
      await prefs.remove('flow.modeConsommation');
    }
    await prefs.setString(_kAdresse, adresseLivraison);
    await prefs.setString(_kTable, codeTableQr);
    await prefs.setString(_kRestoQr, restoIdQr);
    await prefs.setString(_kHeureRecup, heureRecuperation);
    await prefs.setString(_kNumeroPaiement, numeroPaiement);
  }
}
