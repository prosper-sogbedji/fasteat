import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/restaurant.dart';
import 'api_config.dart';
import 'auth_service.dart';

class FavoritesService {
  FavoritesService({AuthService? authService}) : _authService = authService ?? AuthService();

  final AuthService _authService;

  Future<List<Restaurant>> getFavorites() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.favorites}'),
      headers: await _headers(),
    );
    final data = _handleResponse(response);
    return _extractRestaurants(data);
  }

  Future<void> addRestaurant(String restaurantId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.favoriteRestaurant(restaurantId)}'),
      headers: await _headers(),
    );
    _handleResponse(response);
  }

  Future<void> removeRestaurant(String restaurantId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.favoriteRestaurant(restaurantId)}'),
      headers: await _headers(),
    );
    _handleResponse(response);
  }

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Connexion requise pour gérer les favoris.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return [];
      return jsonDecode(response.body);
    }

    String message = 'Erreur favoris (${response.statusCode})';
    try {
      final errorData = jsonDecode(response.body);
      message = errorData['message'] ?? message;
    } catch (_) {}
    throw Exception(message);
  }

  List<Restaurant> _extractRestaurants(dynamic data) {
    final list = _extractList(data);
    return list.map((raw) {
      if (raw is Map<String, dynamic>) {
        final nested = raw['restaurant'];
        if (nested is Map<String, dynamic>) {
          return Restaurant.fromJson(nested);
        }
        return Restaurant.fromJson(raw);
      }
      return Restaurant.fromJson(Map<String, dynamic>.from(raw as Map));
    }).toList();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in ['items', 'data', 'favorites', 'restaurants', 'results']) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return [];
  }
}
