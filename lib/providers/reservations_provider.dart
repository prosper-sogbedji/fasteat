import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/api/auth_service.dart';
import '../data/api/reservations_service.dart';
import '../models/reservation.dart';

class ReservationsProvider extends ChangeNotifier {
  ReservationsProvider({AuthService? authService})
      : _auth = authService ?? AuthService(),
        _service = ReservationsService(authService: authService) {
    _load();
  }

  static const _kCacheKey = 'reservations.cache';

  final AuthService _auth;
  final ReservationsService _service;

  List<Reservation> _reservations = [];
  bool _isLoading = false;
  bool _backendAvailable = true;
  String? _lastError;

  List<Reservation> get reservations => List.unmodifiable(_reservations);
  bool get isLoading => _isLoading;
  bool get backendAvailable => _backendAvailable;
  String? get lastError => _lastError;

  List<Reservation> get aVenir => _reservations
      .where((r) => r.isActive && r.date.isAfter(DateTime.now()))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  List<Reservation> get passees => _reservations
      .where((r) => !r.isActive || r.date.isBefore(DateTime.now()))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  Future<bool> _hasSession() async {
    final token = await _auth.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> refresh() async {
    if (!await _hasSession()) return;
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final remote = await _service.getReservations();
      _reservations = remote;
      _backendAvailable = true;
      await _saveCache();
    } catch (e) {
      debugPrint('Reservations refresh error: $e');
      _backendAvailable = false;
      _lastError = e.toString().replaceFirst('Exception: ', '');
      // On garde le cache local si l'API échoue
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crée une réservation. Retourne la réservation créée ou null en cas d'erreur.
  Future<Reservation?> creer({
    required String restaurantId,
    required String restaurantNom,
    String? restaurantImage,
    required DateTime date,
    required String heure,
    required int nombrePersonnes,
    String? commentaire,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final res = await _service.createReservation(
        restaurantId: restaurantId,
        restaurantNom: restaurantNom,
        restaurantImage: restaurantImage,
        date: date,
        heure: heure,
        nombrePersonnes: nombrePersonnes,
        commentaire: commentaire,
      );
      _reservations.insert(0, res);
      _backendAvailable = true;
      await _saveCache();
      notifyListeners();
      return res;
    } catch (e) {
      debugPrint('Reservation create error: $e');
      _backendAvailable = false;
      _lastError = e.toString().replaceFirst('Exception: ', '');
      // Sauvegarde locale si backend pas encore disponible
      final localRes = Reservation(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        restaurantId: restaurantId,
        restaurantNom: restaurantNom,
        restaurantImage: restaurantImage,
        date: date,
        heure: heure,
        nombrePersonnes: nombrePersonnes,
        commentaire: commentaire,
        statut: StatutReservation.enAttente,
        createdAt: DateTime.now(),
      );
      _reservations.insert(0, localRes);
      await _saveCache();
      notifyListeners();
      return localRes;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> annuler(String id) async {
    try {
      await _service.cancelReservation(id);
      await refresh();
      return true;
    } catch (e) {
      // Annulation locale
      final i = _reservations.indexWhere((r) => r.id == id);
      if (i >= 0) {
        _reservations[i] = _reservations[i].copyWith(statut: StatutReservation.annulee);
        await _saveCache();
        notifyListeners();
      }
      return false;
    }
  }

  Future<void> _load() async {
    if (await _hasSession()) {
      await refresh();
      if (_reservations.isNotEmpty) return;
    }
    await _loadCache();
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCacheKey);
    if (raw == null || raw.isEmpty) {
      notifyListeners();
      return;
    }
    final arr = jsonDecode(raw) as List<dynamic>;
    _reservations = arr
        .map((e) => Reservation.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    notifyListeners();
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCacheKey, jsonEncode(_reservations.map((r) => r.toJson()).toList()));
  }

  void clearOnLogout() {
    _reservations = [];
    _lastError = null;
    _saveCache();
    notifyListeners();
  }
}
