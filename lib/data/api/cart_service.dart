import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/commande.dart';
import '../../providers/flow_provider.dart';
import 'api_config.dart';
import 'auth_service.dart';

class CartService {
  CartService({AuthService? authService}) : _authService = authService ?? AuthService();

  final AuthService _authService;

  Future<Map<String, dynamic>> getCart() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cart}'),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> addItem({
    required String restaurantId,
    required String menuItemId,
    required int quantity,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cartItems}'),
      headers: await _headers(),
      body: jsonEncode({
        'restaurantId': restaurantId,
        'menuItemId': menuItemId,
        'quantity': quantity,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateItem({
    required String itemId,
    required int quantity,
    String? notes,
  }) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cartItem(itemId)}'),
      headers: await _headers(),
      body: jsonEncode({
        'quantity': quantity,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }),
    );
    return _handleResponse(response);
  }

  Future<void> removeItem(String itemId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cartItem(itemId)}'),
      headers: await _headers(),
    );
    _handleResponse(response);
  }

  Future<void> clear() async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cart}'),
      headers: await _headers(),
    );
    _handleResponse(response);
  }

  Future<void> updateFulfillment({
    required ModeCommande mode,
    ModeConsommation? modeConsommation,
    String? pickupTime,
    String? deliveryAddressId,
  }) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cartFulfillment}'),
      headers: await _headers(),
      body: jsonEncode({
        'mode': _fulfillmentMode(mode),
        if (modeConsommation != null) 'consumptionMode': modeConsommation.name,
        if (pickupTime != null && pickupTime.isNotEmpty) 'pickupTime': pickupTime,
        if (deliveryAddressId != null && deliveryAddressId.isNotEmpty) 'deliveryAddressId': deliveryAddressId,
      }),
    );
    _handleResponse(response);
  }

  Future<void> updateInstructions(String instructions) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cartInstructions}'),
      headers: await _headers(),
      body: jsonEncode({'instructions': instructions}),
    );
    _handleResponse(response);
  }

  Future<Map<String, dynamic>> checkout({
    required PaiementMethode paymentMethod,
    required String paymentPhoneNumber,
    String? transactionId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cartCheckout}'),
      headers: await _headers(),
      body: jsonEncode({
        'paymentProvider': _paymentProvider(paymentMethod),
        if (paymentPhoneNumber.isNotEmpty) 'paymentPhoneNumber': _normalizePhone(paymentPhoneNumber),
        if (transactionId != null && transactionId.isNotEmpty) 'transactionId': transactionId,
        'paymentStatus': 'PAID',
      }),
    ).timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Connexion requise pour synchroniser le panier.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      final data = jsonDecode(response.body);
      return data is Map<String, dynamic> ? data : {'data': data};
    }

    String message = 'Erreur panier (${response.statusCode})';
    try {
      final errorData = jsonDecode(response.body);
      message = errorData['message'] ?? message;
    } catch (_) {}
    throw Exception(message);
  }

  String _fulfillmentMode(ModeCommande mode) {
    return switch (mode) {
      ModeCommande.livraison => 'delivery',
      ModeCommande.programmee => 'scheduled_pickup',
      ModeCommande.qrCode => 'pickup_now',
    };
  }

  String _paymentProvider(PaiementMethode method) {
    // Tous les paiements passent désormais par FedaPay
    return 'fedapay';
  }

  String _normalizePhone(String raw) {
    final trimmed = raw.replaceAll(RegExp(r'\s'), '');
    if (trimmed.startsWith('+')) return trimmed;
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.startsWith('229') ? '+$digits' : '+229$digits';
  }
}
