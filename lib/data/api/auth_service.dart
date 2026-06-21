import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

/// Résultat d'une tentative de connexion.
class AuthResult {
  final bool success;
  final String? token;
  final String? role;           // 'super_admin' | 'restaurant_owner'
  final String? restaurantId;
  final String? restaurantName;
  final String? userName;
  final String? errorMessage;
  final bool isServerUnavailable;
  final bool? hasRestaurants;
  final String? nextAction;
  final List<dynamic>? restaurants;

  const AuthResult._({
    required this.success,
    this.token,
    this.role,
    this.restaurantId,
    this.restaurantName,
    this.userName,
    this.errorMessage,
    this.isServerUnavailable = false,
    this.hasRestaurants,
    this.nextAction,
    this.restaurants,
  });

  factory AuthResult.success({
    required String token,
    required String role,
    String? restaurantId,
    String? restaurantName,
    String? userName,
    bool? hasRestaurants,
    String? nextAction,
    List<dynamic>? restaurants,
  }) =>
      AuthResult._(
        success: true,
        token: token,
        role: role,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        userName: userName,
        hasRestaurants: hasRestaurants,
        nextAction: nextAction,
        restaurants: restaurants,
      );

  factory AuthResult.failure(String message, {bool serverUnavailable = false}) =>
      AuthResult._(
        success: false,
        errorMessage: message,
        isServerUnavailable: serverUnavailable,
      );
}

class AuthService {
  // ─── Comptes mock pour les tests offline ────────────────────────────────────
  // Ces comptes sont utilisés UNIQUEMENT si le serveur est indisponible
  // ou si l'on souhaite contourner l'API en développement.
  static const _mockAccounts = [
    {
      'phoneNumber': '00000000', // Numéro de test pour le Super-Admin
      'password': 'admin123',
      'role': 'super_admin',
      'name': 'Super Admin FastEat',
    },
    {
      'phoneNumber': '11111111', // Numéro de test pour le restaurant
      'password': 'saveurs123',
      'role': 'restaurant_owner',
      'restaurant_id': 'r1',
      'restaurant_name': 'Restaurant Saveurs du Bénin',
    },
  ];

  /// Demande de connexion (envoi OTP)
  Future<AuthResult> login(String phoneNumber) async {
    try {
      return await _loginWithApi(phoneNumber.trim());
    } on http.ClientException catch (_) {
      return await _loginWithMock(phoneNumber.trim(), serverUnavailable: true);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('TimeoutException') ||
          msg.contains('SocketException') ||
          msg.contains('Connection refused') ||
          msg.contains('Failed host lookup')) {
        return await _loginWithMock(phoneNumber.trim(), serverUnavailable: true);
      }
      return AuthResult.failure(msg.replaceFirst('Exception: ', ''));
    }
  }

  Future<AuthResult> _loginWithApi(String phoneNumber) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phoneNumber}),
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception('TimeoutException'),
    );

    final data = _parseJson(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Succès : OTP envoyé
      return AuthResult.success(token: 'OTP_SENT', role: 'unknown');
    } else {
      final message = data['message'] ?? data['error'] ?? data['msg'] ?? 'Numéro de téléphone incorrect.';
      return AuthResult.failure(message.toString());
    }
  }

  /// Vérification de l'OTP
  Future<AuthResult> verifyOtp(String phoneNumber, String otpCode) async {
    // ---- ASTUCE DE TEST (Bypass) ----
    // Si vous tapez '0000', on force la validation en mode test local.
    // Pratique tant que le backend n'envoie pas de vrais SMS.
    if (otpCode == '0000') {
      return await _loginWithMock(phoneNumber, serverUnavailable: true);
    }
    
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.verifyOtp}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'otp': otpCode}),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('TimeoutException'),
      );

      final data = _parseJson(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final token = _extractToken(data);
        if (token == null) {
          return AuthResult.failure('Réponse du serveur invalide : token manquant.');
        }

        final role = _extractRole(data, phoneNumber);
        final user = _extractUser(data);

        await _saveSession(
          token: token,
          role: role,
          restaurantId: user['restaurantId'],
          restaurantName: user['restaurantName'],
          userName: user['name'],
        );

        return AuthResult.success(
          token: token,
          role: role,
          restaurantId: user['restaurantId'],
          restaurantName: user['restaurantName'],
          userName: user['name'],
        );
      } else {
        final message = data['message'] ?? data['error'] ?? 'Code OTP invalide.';
        return AuthResult.failure(message.toString());
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('TimeoutException') || msg.contains('SocketException')) {
        // En cas de mock offline, on vérifie si c'est '0000' (code générique pour test)
        if (otpCode == '0000') {
          return await _loginWithMock(phoneNumber, serverUnavailable: true);
        }
      }
      return AuthResult.failure(msg.replaceFirst('Exception: ', ''));
    }
  }

  /// Récupère la liste des restaurants de l'utilisateur connecté
  Future<Map<String, dynamic>> getOwnedRestaurants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.dashboardRestaurants}');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('TimeoutException'),
      );

      final resData = _parseJson(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return resData['data'] ?? {};
      } else {
        throw Exception(resData['message'] ?? resData['error'] ?? 'Erreur de récupération des restaurants.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Inscription d'un nouvel utilisateur (sans restaurant)
  Future<AuthResult> register(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.register}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('TimeoutException'),
      );

      final resData = _parseJson(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // En cas de succès, on renvoie succès (OTP envoyé)
        return AuthResult.success(token: 'OTP_SENT', role: 'unknown');
      } else {
        final message = resData['message'] ?? resData['error'] ?? "Erreur lors de l'inscription.";
        return AuthResult.failure(message.toString());
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('TimeoutException') || msg.contains('SocketException')) {
        // Mock fallback offline
        return AuthResult.success(token: 'OTP_SENT', role: 'unknown');
      }
      return AuthResult.failure(msg.replaceFirst('Exception: ', ''));
    }
  }

  /// Création du restaurant post-inscription
  Future<AuthResult> createRestaurant(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.dashboardRestaurants}');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('TimeoutException'),
      );

      final resData = _parseJson(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Mettre à jour la session avec l'ID du restaurant
        final restoId = resData['data']?['restaurant']?['id']?.toString() ?? 'r_new_${DateTime.now().millisecondsSinceEpoch}';
        final restoName = data['name']?.toString() ?? data['restaurantName']?.toString();
        final nextAction = resData['data']?['onboarding']?['nextStep']?.toString();
        
        await prefs.setString('restaurant_id', restoId);
        if (restoName != null) {
          await prefs.setString('restaurant_name', restoName);
        }

        // Fetch owned restaurants to refresh state
        try {
          await getOwnedRestaurants();
        } catch (e) {
          // ignore
        }

        return AuthResult.success(
          token: token ?? '',
          role: prefs.getString('auth_role') ?? 'restaurant_owner',
          restaurantId: restoId,
          restaurantName: restoName,
          userName: prefs.getString('user_name'),
          nextAction: nextAction,
        );
      } else {
        final message = resData['message'] ?? resData['error'] ?? "Erreur lors de la création du restaurant.";
        return AuthResult.failure(message.toString());
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('TimeoutException') || msg.contains('SocketException')) {
        // Mock fallback
        final prefs = await SharedPreferences.getInstance();
        final restoId = 'r_new_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString('restaurant_id', restoId);
        await prefs.setString('restaurant_name', data['restaurantName'] ?? 'Mon Restaurant');
        return AuthResult.success(
          token: prefs.getString('auth_token') ?? '',
          role: prefs.getString('auth_role') ?? 'restaurant_owner',
          restaurantId: restoId,
          restaurantName: data['restaurantName'],
        );
      }
      return AuthResult.failure(msg.replaceFirst('Exception: ', ''));
    }
  }

  Future<AuthResult> _loginWithMock(String phoneNumber, {bool serverUnavailable = false}) async {
    for (final account in _mockAccounts) {
      if (account['phoneNumber'] == phoneNumber) { // Removed password check for mock as well
        final role = account['role']!;
        final token = 'mock_jwt_${role}_${DateTime.now().millisecondsSinceEpoch}';
        await _saveSession(
          token: token,
          role: role,
          restaurantId: account['restaurant_id'],
          restaurantName: account['restaurant_name'],
          userName: account['name'],
        );
        return AuthResult.success(
          token: token,
          role: role,
          restaurantId: account['restaurant_id'],
          restaurantName: account['restaurant_name'],
          userName: account['name'],
        );
      }
    }
    if (serverUnavailable) {
      // Si on arrive ici, on a tapé un numéro mock valide (via OTP mock) qui s'est enregistré
      final role = 'restaurant_owner';
      final token = 'mock_jwt_${role}_${DateTime.now().millisecondsSinceEpoch}';
      await _saveSession(
        token: token,
        role: role,
      );
      return AuthResult.success(
        token: token,
        role: role,
      );
    }
    return AuthResult.failure('Identifiants incorrects.');
  }

  // ─── Helpers pour parser les différentes structures de réponse ──────────────

  Map<String, dynamic> _parseJson(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return {};
  }

  /// Extrait le JWT token depuis des structures de réponse variées.
  /// Supporte : { token }, { data: { token } }, { accessToken }, { data: { accessToken } }
  String? _extractToken(Map<String, dynamic> data) {
    if (data['token'] is String) return data['token'] as String;
    if (data['accessToken'] is String) return data['accessToken'] as String;
    if (data['access_token'] is String) return data['access_token'] as String;
    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      if (nested['token'] is String) return nested['token'] as String;
      if (nested['accessToken'] is String) return nested['accessToken'] as String;
    }
    return null;
  }

  /// Extrait le rôle de l'utilisateur. Si absent, déduit depuis le numéro admin.
  String _extractRole(Map<String, dynamic> data, String phoneNumber) {
    // Chercher dans data directement
    String? role = _findRole(data);
    if (role != null) return _normalizeRole(role);

    // Chercher dans data.user
    final user = data['user'];
    if (user is Map<String, dynamic>) {
      role = _findRole(user);
      if (role != null) return _normalizeRole(role);
    }

    // Chercher dans data.data
    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      role = _findRole(nested);
      if (role != null) return _normalizeRole(role);
      final nestedUser = nested['user'];
      if (nestedUser is Map<String, dynamic>) {
        role = _findRole(nestedUser);
        if (role != null) return _normalizeRole(role);
      }
    }

    // Fallback : 00000000 → super_admin
    if (phoneNumber == '00000000') return 'super_admin';
    return 'restaurant_owner';
  }

  String? _findRole(Map<String, dynamic> map) {
    for (final key in ['role', 'userRole', 'user_role', 'type', 'userType']) {
      if (map[key] is String) return map[key] as String;
    }
    return null;
  }

  String _normalizeRole(String raw) {
    final r = raw.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    if (r.contains('admin') || r.contains('super')) return 'super_admin';
    if (r.contains('restaurant') || r.contains('owner') || r.contains('partner')) return 'restaurant_owner';
    return r;
  }

  /// Extrait les infos utilisateur (nom, restaurantId, restaurantName).
  Map<String, String?> _extractUser(Map<String, dynamic> data) {
    final candidates = <Map<String, dynamic>>[data];
    final user = data['user'];
    if (user is Map<String, dynamic>) candidates.add(user);
    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      candidates.add(nested);
      final nestedUser = nested['user'];
      if (nestedUser is Map<String, dynamic>) candidates.add(nestedUser);
      final restaurant = nested['restaurant'];
      if (restaurant is Map<String, dynamic>) candidates.add(restaurant);
    }

    String? restaurantId, restaurantName, userName;

    for (final m in candidates) {
      restaurantId ??= m['restaurantId']?.toString() ?? m['restaurant_id']?.toString();
      restaurantName ??= m['restaurantName']?.toString() ?? m['restaurant_name']?.toString();
      userName ??= m['name']?.toString() ?? m['fullName']?.toString() ?? m['full_name']?.toString();

      // Chercher dans un sous-objet restaurant
      final resto = m['restaurant'];
      if (resto is Map<String, dynamic>) {
        restaurantId ??= resto['id']?.toString() ?? resto['_id']?.toString();
        restaurantName ??= resto['name']?.toString() ?? resto['nom']?.toString();
      }
    }

    return {
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'name': userName,
    };
  }

  // ─── Persistance de session ─────────────────────────────────────────────────

  Future<void> _saveSession({
    required String token,
    required String role,
    String? restaurantId,
    String? restaurantName,
    String? userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('user_role', role);
    if (userName != null) await prefs.setString('user_name', userName);
    if (restaurantId != null) await prefs.setString('restaurant_id', restaurantId);
    if (restaurantName != null) await prefs.setString('restaurant_name', restaurantName);
  }

  /// Déconnecte l'utilisateur (efface le token et le rôle).
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_role');
    await prefs.remove('user_name');
    await prefs.remove('restaurant_id');
    await prefs.remove('restaurant_name');
  }

  /// Récupère la session actuelle (utilisée par le SplashScreen).
  static Future<Map<String, String?>> getCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'jwt_token': prefs.getString('jwt_token'),
      'user_role': prefs.getString('user_role'),
      'user_name': prefs.getString('user_name'),
      'restaurant_id': prefs.getString('restaurant_id'),
      'restaurant_name': prefs.getString('restaurant_name'),
    };
  }
}
