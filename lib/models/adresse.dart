import 'package:uuid/uuid.dart';

class Adresse {
  Adresse({
    String? id,
    required this.titre,
    required this.adresse,
    this.complement = '',
    required this.telephone,
    this.isDefault = false,
  }) : id = id ?? Uuid().v4();

  final String id;
  final String titre;
  final String adresse;
  final String complement;
  final String telephone;
  final bool isDefault;

  factory Adresse.fromJson(Map<String, dynamic> json) {
    return Adresse(
      id: json['id']?.toString(),
      titre: json['titre'] ?? 'Adresse',
      adresse: json['adresse'] ?? '',
      complement: json['complement'] ?? '',
      telephone: json['telephone'] ?? '',
      isDefault: json['isDefault'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'adresse': adresse,
      'complement': complement,
      'telephone': telephone,
      'isDefault': isDefault,
    };
  }

  Adresse copyWith({
    String? titre,
    String? adresse,
    String? complement,
    String? telephone,
    bool? isDefault,
  }) {
    return Adresse(
      id: id,
      titre: titre ?? this.titre,
      adresse: adresse ?? this.adresse,
      complement: complement ?? this.complement,
      telephone: telephone ?? this.telephone,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
