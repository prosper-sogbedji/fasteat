import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock/mock_user.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _load();
  }

  static const _kConnectedKey = 'auth.isConnected';
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  UserModel get currentUser => mockUser;

  Future<void> loginMock() async {
    _isConnected = true;
    await _save();
    notifyListeners();
  }

  Future<void> logoutMock() async {
    _isConnected = false;
    await _save();
    notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _isConnected = prefs.getBool(_kConnectedKey) ?? false;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kConnectedKey, _isConnected);
  }
}
