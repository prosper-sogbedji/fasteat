import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/commande.dart';
import 'api_config.dart';
import 'auth_service.dart';

class OrdersService {
  OrdersService({AuthService? authService}) : _authService = authService ?? AuthService();

  final AuthService _authService;

  Future<List<Commande>> getOrders({String status = 'all'}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.orders}').replace(
      queryParameters: {'status': status},
    );
    final response = await http.get(url, headers: await _headers());
    final data = _handleResponse(response);
    return _extractList(data).map(_commandeFromApi).toList();
  }

  Future<Commande> getOrder(String orderId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.order(orderId)}'),
      headers: await _headers(),
    );
    return _commandeFromApi(_handleResponse(response));
  }

  Future<Commande?> getTracking(String orderId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.orderTracking(orderId)}'),
      headers: await _headers(),
    );
    final data = _handleResponse(response);
    if (data.isEmpty) return null;
    return _commandeFromApi(data);
  }

  Future<void> cancelOrder(String orderId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.orderCancel(orderId)}'),
      headers: await _headers(),
    );
    _handleResponse(response);
  }

  Future<void> reorder(String orderId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.orderReorder(orderId)}'),
      headers: await _headers(),
    );
    _handleResponse(response);
  }

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Connexion requise pour recuperer les commandes.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    }

    String message = 'Erreur commandes (${response.statusCode})';
    try {
      final errorData = jsonDecode(response.body);
      message = errorData['message'] ?? message;
    } catch (_) {}
    throw Exception(message);
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in ['items', 'data', 'orders', 'results']) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return [];
  }

  Commande _commandeFromApi(dynamic raw) {
    final map = raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw as Map);
    final normalized = <String, dynamic>{
      'id': (map['id'] ?? map['_id'] ?? map['orderId'] ?? '').toString(),
      'restaurantId': (map['restaurantId'] ?? map['restaurant']?['id'] ?? '').toString(),
      'restaurantNom': (map['restaurantNom'] ?? map['restaurantName'] ?? map['restaurant']?['name'] ?? 'Restaurant').toString(),
      'date': (map['date'] ?? map['createdAt'] ?? map['orderedAt'] ?? DateTime.now().toIso8601String()).toString(),
      'createdAt': (map['createdAt'] ?? map['date'] ?? map['orderedAt'] ?? DateTime.now().toIso8601String()).toString(),
      'mode': _mapMode(map['mode'] ?? map['fulfillmentMode'] ?? map['fulfillment']?['mode']),
      'statut': _mapStatus(map['statut'] ?? map['status']),
      'lignes': _mapLines(map['lignes'] ?? map['items'] ?? map['orderItems']),
      'fraisLivraison': _toInt(map['fraisLivraison'] ?? map['deliveryFee'] ?? map['fees']?['delivery'], fallback: 0),
      'heureRecuperationSouhaitee': map['heureRecuperationSouhaitee'] ?? map['pickupTime'] ?? map['fulfillment']?['pickupTime'],
      'validatedAt': map['validatedAt'],
      'readyAt': map['readyAt'],
      'motifAnnulation': map['motifAnnulation'] ?? map['cancelReason'] ?? map['cancellationReason'],
    };
    return Commande.fromJson(normalized);
  }

  List<Map<String, dynamic>> _mapLines(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((item) {
      final menuItem = item['menuItem'];
      final menuMap = menuItem is Map ? menuItem : const {};
      final price = item['prixUnitaire'] ?? item['unitPrice'] ?? item['price'] ?? menuMap['price'];
      return {
        'platId': (item['platId'] ?? item['menuItemId'] ?? menuMap['id'] ?? '').toString(),
        'nomPlat': (item['nomPlat'] ?? item['name'] ?? menuMap['name'] ?? 'Plat').toString(),
        'quantite': _toInt(item['quantite'] ?? item['quantity'], fallback: 1),
        'prixUnitaire': _toInt(price, fallback: 0),
      };
    }).toList();
  }

  String _mapMode(dynamic raw) {
    return switch (raw?.toString()) {
      'delivery' => ModeCommande.livraison.name,
      'scheduled_pickup' => ModeCommande.programmee.name,
      'pickup_now' => ModeCommande.qrCode.name,
      _ => raw?.toString() ?? ModeCommande.programmee.name,
    };
  }

  String _mapStatus(dynamic raw) {
    return switch (raw?.toString()) {
      'pending' || 'received' || 'recue' => StatutCommande.enAttenteValidation.name,
      'accepted' || 'preparing' || 'preparation' => StatutCommande.preparation.name,
      'ready' || 'prete' => StatutCommande.prete.name,
      'out_for_delivery' || 'delivery' || 'livraison' => StatutCommande.livraison.name,
      'delivered' || 'livree' => StatutCommande.livree.name,
      'cancelled_by_customer' => StatutCommande.annuleeClient.name,
      'cancelled_by_restaurant' => StatutCommande.annuleeRestaurant.name,
      'expired' || 'expiree' => StatutCommande.expiree.name,
      _ => raw?.toString() ?? StatutCommande.enAttenteValidation.name,
    };
  }

  int _toInt(dynamic value, {required int fallback}) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
