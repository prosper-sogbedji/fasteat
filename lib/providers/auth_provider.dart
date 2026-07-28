import 'package:flutter/material.dart';

import '../data/api/auth_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService}) : _authService = authService ?? AuthService() {
    _load();
  }

  final AuthService _authService;

  bool _isReady = false;
  bool _isConnected = false;
  String? _token;
  UserModel _currentUser = const UserModel(
    nom: '',
    telephone: '',
    email: '',
    avatar: '',
    soldeCredits: 0,
  );
  String? _pendingPhone;

  bool get isReady => _isReady;
  bool get isConnected => _isConnected;
  UserModel get currentUser => _currentUser;
  String? get pendingPhone => _pendingPhone;
  AuthService get authService => _authService;

  Future<bool> register(String fullName, String phone) async {
    try {
      await _authService.register(fullName, phone);
      _pendingPhone = phone;
      return true;
    } catch (e) {
      debugPrint('Register Error: $e');
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String code) async {
    try {
      // --- DEMO MODE ---
      if (code == '123456') {
        await Future.delayed(const Duration(milliseconds: 600));
        _isConnected = true;
        _token = 'demo_token_123';
        _currentUser = const UserModel(
          nom: 'Utilisateur Démo',
          telephone: '00000000',
          email: 'demo@fasteat.app',
          avatar: '',
          soldeCredits: 5000,
        );
        _pendingPhone = null;
        notifyListeners();
        return true;
      }

      final response = await _authService.verifyOtp(phone, code);
      await _applySession(response);
      _pendingPhone = null;
      return _isConnected;
    } catch (e) {
      debugPrint('Verify OTP Error: $e');
      return false;
    }
  }

  Future<bool> sendOtpWhatsapp(String phone) async {
    try {
      await _authService.resendOtp(phone);
      _pendingPhone = phone;
      return true;
    } catch (e) {
      debugPrint('Resend OTP Error: $e');
      return false;
    }
  }

  // --- DEMO MODE ---
  Future<void> loginDemo() async {
    _isConnected = true;
    _token = 'demo_token_123';
    _currentUser = const UserModel(
      nom: 'Utilisateur Démo',
      telephone: '+229 00000000',
      email: 'demo@fasteat.app',
      avatar: '',
      soldeCredits: 5000,
    );
    _pendingPhone = null;
    notifyListeners();
  }

  Future<void> logout() async {
    _isConnected = false;
    _token = null;
    _currentUser = const UserModel(
      nom: '',
      telephone: '',
      email: '',
      avatar: '',
      soldeCredits: 0,
    );
    _pendingPhone = null;
    await _authService.logout();
    notifyListeners();
  }

  Future<void> _load() async {
    _token = await _authService.getToken();
    if (_token != null && _token!.isNotEmpty) {
      _isConnected = true;
      await _loadProfile();
    }
    _isReady = true;
    notifyListeners();
  }

  Future<void> _applySession(Map<String, dynamic> response) async {
    _token = _authService.extractToken(response) ?? await _authService.getToken();
    _isConnected = _token != null && _token!.isNotEmpty;
    if (_isConnected) {
      await _loadProfile();
    }
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _authService.me();
      final userMap = _authService.extractUser(data);
      if (userMap != null) {
        _currentUser = UserModel.fromJson(userMap);
      }
    } catch (e) {
      debugPrint('Profile load error: $e');
    }
  }
}
