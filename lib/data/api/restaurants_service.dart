import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/plat.dart';
import '../../models/restaurant.dart';
import 'api_config.dart';

class RestaurantsService {
  Future<List<Restaurant>> getRestaurants() async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.restaurants}');
    final response = await http.get(url);
    final data = _handleResponse(response);
    final list = _extractList(data);
    return list.map((e) => Restaurant.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<List<Plat>> getRestaurantMenu(String restaurantId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.restaurantMenu(restaurantId)}');
    final response = await http.get(url);
    final data = _handleResponse(response);
    final list = _extractMenuItems(data);
    return list.map((e) => Plat.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return [];
      return jsonDecode(response.body);
    }
    String message = 'Erreur serveur (${response.statusCode})';
    try {
      final errorData = jsonDecode(response.body);
      message = errorData['message'] ?? message;
    } catch (_) {}
    throw Exception(message);
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in ['items', 'data', 'restaurants', 'results', 'plats', 'dishes']) {
        final value = data[key];
        if (value is List) return value;
      }
      for (final value in data.values) {
        if (value is Map<String, dynamic>) {
          final subList = _extractList(value);
          if (subList.isNotEmpty) return subList;
        }
      }
    }
    return [];
  }

  List<dynamic> _extractMenuItems(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in ['items', 'data', 'menuItems', 'dishes', 'plats']) {
        final value = data[key];
        if (value is List) return value;
      }
      final categories = data['categories'];
      if (categories is List) {
        return categories
            .whereType<Map>()
            .expand((category) {
              final items = category['items'] ?? category['menuItems'] ?? category['dishes'] ?? category['plats'];
              return items is List ? items : const [];
            })
            .toList();
      }
      for (final value in data.values) {
        if (value is Map<String, dynamic>) {
          final subList = _extractMenuItems(value);
          if (subList.isNotEmpty) return subList;
        }
      }
    }
    return [];
  }
}
