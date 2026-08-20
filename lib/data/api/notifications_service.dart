import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/notification_item.dart';
import 'api_config.dart';
import 'auth_service.dart';

class NotificationsService {
  NotificationsService({AuthService? authService}) : _authService = authService ?? AuthService();

  final AuthService _authService;

  Future<List<AppNotification>> getNotifications({String type = 'all'}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.notifications}').replace(
      queryParameters: {'type': type},
    );
    final response = await http.get(url, headers: await _headers());
    final data = _handleResponse(response);
    return _extractNotifications(data);
  }

  Future<void> markAsRead(String notificationId) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.notificationRead(notificationId)}'),
      headers: await _headers(),
    );
    _handleResponse(response);
  }

  Future<void> markAllAsRead() async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.notificationsReadAll}'),
      headers: await _headers(),
    );
    _handleResponse(response);
  }

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Connexion requise pour consulter les notifications.');
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

    String message = 'Erreur notifications (${response.statusCode})';
    try {
      final errorData = jsonDecode(response.body);
      message = errorData['message'] ?? message;
    } catch (_) {}
    throw Exception(message);
  }

  List<AppNotification> _extractNotifications(dynamic data) {
    final list = _extractList(data);
    return list
        .whereType<Map>()
        .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in ['items', 'data', 'notifications', 'results']) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return [];
  }
}
