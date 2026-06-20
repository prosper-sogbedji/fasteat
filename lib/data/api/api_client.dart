import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

/// Exception HTTP normalisée pour toute l'application.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.isTimeout = false,
    this.isUnauthorized = false,
    this.isNetworkError = false,
  });

  final String message;
  final int? statusCode;
  final bool isTimeout;
  final bool isUnauthorized;
  final bool isNetworkError;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration defaultTimeout = Duration(seconds: 15);

  Future<Map<String, String>> authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, String>> _publicHeaders() async => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
    Duration timeout = defaultTimeout,
    bool authenticated = true,
  }) async {
    final headers = authenticated ? await authHeaders() : await _publicHeaders();
    return _request(
      () => _client.get(_uri(path, queryParameters), headers: headers),
      timeout: timeout,
    );
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Duration timeout = defaultTimeout,
    bool authenticated = true,
  }) async {
    final headers = authenticated ? await authHeaders() : await _publicHeaders();
    return _request(
      () => _client.post(
        _uri(path, queryParameters),
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      ),
      timeout: timeout,
    );
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    Duration timeout = defaultTimeout,
  }) async {
    final headers = await authHeaders();
    return _request(
      () => _client.put(
        _uri(path),
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      ),
      timeout: timeout,
    );
  }

  Future<dynamic> patch(
    String path, {
    Object? body,
    Duration timeout = defaultTimeout,
  }) async {
    final headers = await authHeaders();
    return _request(
      () => _client.patch(
        _uri(path),
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      ),
      timeout: timeout,
    );
  }

  Future<dynamic> delete(String path, {Duration timeout = defaultTimeout}) async {
    final headers = await authHeaders();
    return _request(
      () => _client.delete(_uri(path), headers: headers),
      timeout: timeout,
    );
  }

  Future<dynamic> _request(
    Future<http.Response> Function() send, {
    required Duration timeout,
  }) async {
    try {
      final response = await send().timeout(
        timeout,
        onTimeout: () => throw const ApiException(
          'Délai de connexion dépassé. Vérifiez votre réseau.',
          isTimeout: true,
        ),
      );
      return _parseResponse(response);
    } on ApiException {
      rethrow;
    } on http.ClientException {
      throw const ApiException(
        'Impossible de joindre le serveur.',
        isNetworkError: true,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  dynamic _parseResponse(http.Response response) {
    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = response.body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    String message = 'Erreur serveur (${response.statusCode})';
    if (body is Map) {
      message = (body['message'] ?? body['error'] ?? message).toString();
    }

    throw ApiException(
      message,
      statusCode: response.statusCode,
      isUnauthorized: response.statusCode == 401,
    );
  }

  static List<dynamic> extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in ['data', 'items', 'results', 'orders', 'promotions', 'conversations']) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return [];
  }

  static Map<String, dynamic> extractMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) return nested;
      return data;
    }
    return {};
  }

  static int toInt(dynamic value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double toDouble(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
