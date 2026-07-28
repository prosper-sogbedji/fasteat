import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';

  Future<Map<String, dynamic>> register(String fullName, String phoneNumber) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.register}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'phoneNumber': phoneNumber,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur de connexion au serveur : $e');
    }
  }

  Future<Map<String, dynamic>> resendOtp(String phoneNumber) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.resendOtp}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur renvoi OTP : $e');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String code) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.verifyOtp}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'code': code,
        }),
      );

      final data = _handleResponse(response);
      final token = extractToken(data);
      if (token != null) {
        await saveToken(token);
      }
      return data;
    } catch (e) {
      throw Exception('Erreur de verification OTP : $e');
    }
  }

  Future<Map<String, dynamic>> me() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Aucune session active');
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.me}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur de recuperation du profil : $e');
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logout}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  String? extractToken(Map<String, dynamic> data) {
    final direct = data['token'] ?? data['accessToken'] ?? data['jwt'];
    if (direct is String && direct.isNotEmpty) return direct;

    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      final value = nested['token'] ?? nested['accessToken'] ?? nested['jwt'];
      if (value is String && value.isNotEmpty) return value;
    }

    return null;
  }

  Map<String, dynamic>? extractUser(Map<String, dynamic> data) {
    final direct = data['user'] ?? data['profile'];
    if (direct is Map<String, dynamic>) return direct;

    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      final value = nested['user'] ?? nested['profile'];
      if (value is Map<String, dynamic>) return value;
      return nested;
    }

    return data.isEmpty ? null : data;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    String message = 'Une erreur est survenue';
    try {
      final errorData = jsonDecode(response.body);
      message = errorData['message'] ?? message;
    } catch (_) {}
    throw Exception(message);
  }
}
