import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/reservation.dart';
import 'api_config.dart';
import 'auth_service.dart';

class ReservationsService {
  ReservationsService({AuthService? authService})
      : _auth = authService ?? AuthService();

  final AuthService _auth;

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Reservation>> getReservations() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.reservations}'),
      headers: await _headers(),
    );
    final data = _handleResponse(response);
    final list = _extractList(data);
    return list
        .map((e) => Reservation.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Reservation> createReservation({
    required String restaurantId,
    required String restaurantNom,
    String? restaurantImage,
    required DateTime date,
    required String heure,
    required int nombrePersonnes,
    String? commentaire,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.reservations}'),
      headers: await _headers(),
      body: jsonEncode({
        'restaurantId': restaurantId,
        'restaurantNom': restaurantNom,
        'restaurantImage': ?restaurantImage,
        'date': date.toIso8601String(),
        'heure': heure,
        'nombrePersonnes': nombrePersonnes,
        if (commentaire?.isNotEmpty ?? false) 'commentaire': commentaire,
      }),
    );
    final data = _handleResponse(response);
    final resMap = _extractObject(data);
    return Reservation.fromJson(resMap);
  }

  Future<void> cancelReservation(String id) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cancelReservation(id)}'),
      headers: await _headers(),
    );
    _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    }
    String message = 'Erreur serveur (${response.statusCode})';
    try {
      final err = jsonDecode(response.body);
      message = err['message'] ?? message;
    } catch (_) {}
    throw Exception(message);
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in ['reservations', 'data', 'items', 'results']) {
        if (data[key] is List) return data[key] as List;
      }
    }
    return [];
  }

  Map<String, dynamic> _extractObject(dynamic data) {
    if (data is Map<String, dynamic>) {
      for (final key in ['reservation', 'data']) {
        if (data[key] is Map<String, dynamic>) {
          return data[key] as Map<String, dynamic>;
        }
      }
      return data;
    }
    return {};
  }
}
