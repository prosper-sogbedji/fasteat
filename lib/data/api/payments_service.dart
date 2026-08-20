import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../providers/flow_provider.dart';
import 'api_config.dart';
import 'auth_service.dart';

class PaymentInitResult {
  const PaymentInitResult({
    required this.paymentId,
    this.providerReference,
    this.status,
  });

  final String paymentId;
  final String? providerReference;
  final String? status;
}

class PaymentsService {
  PaymentsService({AuthService? authService}) : _authService = authService ?? AuthService();

  final AuthService _authService;

  Future<List<dynamic>> getMethods() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.paymentMethods}'),
      headers: await _headers(),
    );
    final data = _handleResponse(response);
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in ['items', 'data', 'methods', 'providers']) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return const [];
  }

  Future<PaymentInitResult?> initiate({
    required String orderId,
    required PaiementMethode method,
    required String phoneNumber,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.paymentInitiate}'),
      headers: await _headers(),
      body: jsonEncode({
        'orderId': orderId,
        'provider': providerForMethod(method),
        if (phoneNumber.isNotEmpty) 'phoneNumber': normalizePhone(phoneNumber),
      }),
    );
    final data = _handleResponse(response);
    final map = _extractMap(data);
    final paymentId = _firstString(map, ['paymentId', 'id', 'transactionId']);
    if (paymentId == null) return null;
    return PaymentInitResult(
      paymentId: paymentId,
      providerReference: _firstString(map, ['providerReference', 'reference']),
      status: _firstString(map, ['status']),
    );
  }

  Future<Map<String, dynamic>> getPayment(String paymentId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.payment(paymentId)}'),
      headers: await _headers(),
    );
    final data = _handleResponse(response);
    return _extractMap(data);
  }

  Future<Map<String, dynamic>> confirm({
    required String paymentId,
    required String providerReference,
    String? otp,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.paymentConfirm(paymentId)}'),
      headers: await _headers(),
      body: jsonEncode({
        'providerReference': providerReference,
        if (otp != null && otp.isNotEmpty) 'otp': otp,
      }),
    );
    final data = _handleResponse(response);
    return _extractMap(data);
  }

  static String providerForMethod(PaiementMethode method) {
    return switch (method) {
      PaiementMethode.mtn => 'mtn_momo',
      PaiementMethode.moov => 'moov_money',
      PaiementMethode.carte => 'celtiis',
    };
  }

  static String normalizePhone(String raw) {
    final trimmed = raw.replaceAll(RegExp(r'\s'), '');
    if (trimmed.startsWith('+')) return trimmed;
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.startsWith('229') ? '+$digits' : '+229$digits';
  }

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Connexion requise pour lancer un paiement.');
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

    String message = 'Erreur paiement (${response.statusCode})';
    try {
      final errorData = jsonDecode(response.body);
      message = errorData['message'] ?? message;
    } catch (_) {}
    throw Exception(message);
  }

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) return nested;
      return data;
    }
    return {};
  }

  String? _firstString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }
}
