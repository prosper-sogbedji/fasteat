import 'package:flutter/material.dart';
import '../models/adresse.dart';

class AdressesProvider extends ChangeNotifier {
  final List<Adresse> _adresses = [
    Adresse(
      titre: 'Maison',
      adresse: '12 Rue des Fleurs, Quartier Résidentiel',
      telephone: '+228 90 00 00 01',
      isDefault: true,
    ),
    Adresse(
      titre: 'Bureau',
      adresse: 'Tour de l\'Entreprise, 5ème étage',
      complement: 'Code porte 1234',
      telephone: '+228 90 00 00 02',
    ),
  ];

  List<Adresse> get adresses => List.unmodifiable(_adresses);
  
  Adresse? get defaultAdresse {
    if (_adresses.isEmpty) return null;
    try {
      return _adresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _adresses.first;
    }
  }

  void addAdresse(Adresse adresse) {
    if (adresse.isDefault) {
      _clearDefault();
    } else if (_adresses.isEmpty) {
      adresse = adresse.copyWith(isDefault: true);
    }
    _adresses.add(adresse);
    notifyListeners();
  }

  void updateAdresse(String id, Adresse updated) {
    final index = _adresses.indexWhere((a) => a.id == id);
    if (index >= 0) {
      if (updated.isDefault) {
        _clearDefault();
      }
      _adresses[index] = updated;
      
      // Assurer qu'il y a toujours une adresse par défaut si possible
      if (!_adresses.any((a) => a.isDefault) && _adresses.isNotEmpty) {
        _adresses[0] = _adresses[0].copyWith(isDefault: true);
      }
      
      notifyListeners();
    }
  }

  void removeAdresse(String id) {
    final adresse = _adresses.firstWhere((a) => a.id == id);
    _adresses.removeWhere((a) => a.id == id);
    
    if (adresse.isDefault && _adresses.isNotEmpty) {
      _adresses[0] = _adresses[0].copyWith(isDefault: true);
    }
    notifyListeners();
  }

  void setDefault(String id) {
    _clearDefault();
    final index = _adresses.indexWhere((a) => a.id == id);
    if (index >= 0) {
      _adresses[index] = _adresses[index].copyWith(isDefault: true);
      notifyListeners();
    }
  }

  void _clearDefault() {
    for (var i = 0; i < _adresses.length; i++) {
      if (_adresses[i].isDefault) {
        _adresses[i] = _adresses[i].copyWith(isDefault: false);
      }
    }
  }
}
