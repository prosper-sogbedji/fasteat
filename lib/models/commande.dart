enum StatutCommande {
  enAttenteValidation,
  preparation,
  prete,
  livraison,
  livree,
  annuleeClient,
  annuleeRestaurant,
  expiree,
}
enum ModeCommande { programmee, livraison, qrCode }
enum ModeConsommation { surPlace, aEmporter, livraison }

class LigneCommande {
  const LigneCommande({
    required this.platId,
    required this.nomPlat,
    required this.quantite,
    required this.prixUnitaire,
  });

  final String platId;
  final String nomPlat;
  final int quantite;
  final int prixUnitaire;

  int get total => quantite * prixUnitaire;

  Map<String, dynamic> toJson() => {
        'platId': platId,
        'nomPlat': nomPlat,
        'quantite': quantite,
        'prixUnitaire': prixUnitaire,
      };

  factory LigneCommande.fromJson(Map<String, dynamic> json) {
    return LigneCommande(
      platId: json['platId'] as String,
      nomPlat: json['nomPlat'] as String,
      quantite: json['quantite'] as int,
      prixUnitaire: json['prixUnitaire'] as int,
    );
  }
}

class Commande {
  const Commande({
    required this.id,
    required this.restaurantId,
    required this.restaurantNom,
    required this.date,
    required this.createdAt,
    required this.mode,
    required this.statut,
    required this.lignes,
    required this.fraisLivraison,
    this.heureRecuperationSouhaitee,
    this.validatedAt,
    this.readyAt,
    this.motifAnnulation,
    this.modeConsommation,
  });

  final String id;
  final String restaurantId;
  final String restaurantNom;
  final DateTime date;
  final DateTime createdAt;
  final ModeCommande mode;
  final StatutCommande statut;
  final List<LigneCommande> lignes;
  final int fraisLivraison;
  final DateTime? heureRecuperationSouhaitee;
  final DateTime? validatedAt;
  final DateTime? readyAt;
  final String? motifAnnulation;
  final ModeConsommation? modeConsommation;

  int get sousTotal => lignes.fold(0, (sum, l) => sum + l.total);
  int get total => sousTotal + fraisLivraison;

  Commande copyWith({
    StatutCommande? statut,
    DateTime? validatedAt,
    DateTime? readyAt,
    String? motifAnnulation,
    ModeConsommation? modeConsommation,
  }) {
    return Commande(
      id: id,
      restaurantId: restaurantId,
      restaurantNom: restaurantNom,
      date: date,
      createdAt: createdAt,
      mode: mode,
      statut: statut ?? this.statut,
      lignes: lignes,
      fraisLivraison: fraisLivraison,
      heureRecuperationSouhaitee: heureRecuperationSouhaitee,
      validatedAt: validatedAt ?? this.validatedAt,
      readyAt: readyAt ?? this.readyAt,
      motifAnnulation: motifAnnulation ?? this.motifAnnulation,
      modeConsommation: modeConsommation ?? this.modeConsommation,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurantId': restaurantId,
        'restaurantNom': restaurantNom,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'mode': mode.name,
        'statut': statut.name,
        'lignes': lignes.map((e) => e.toJson()).toList(),
        'fraisLivraison': fraisLivraison,
        'heureRecuperationSouhaitee': heureRecuperationSouhaitee?.toIso8601String(),
        'validatedAt': validatedAt?.toIso8601String(),
        'readyAt': readyAt?.toIso8601String(),
        'motifAnnulation': motifAnnulation,
        'modeConsommation': modeConsommation?.name,
      };

  factory Commande.fromJson(Map<String, dynamic> json) {
    final modeName = json['mode'] as String;
    final statutName = json['statut'] as String? ?? 'enAttenteValidation';
    final statut = _mapStatut(statutName);
    final created = json['createdAt'] as String?;
    final dateRaw = json['date'] as String;
    final wantedAt = json['heureRecuperationSouhaitee'] as String?;
    final validated = json['validatedAt'] as String?;
    final ready = json['readyAt'] as String?;
    final modeConsName = json['modeConsommation'] as String?;
    return Commande(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      restaurantNom: json['restaurantNom'] as String,
      date: DateTime.parse(dateRaw),
      createdAt: DateTime.parse(created ?? dateRaw),
      mode: ModeCommande.values.firstWhere((m) => m.name == modeName, orElse: () => ModeCommande.programmee),
      statut: statut,
      lignes: (json['lignes'] as List<dynamic>)
          .map((e) => LigneCommande.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      fraisLivraison: json['fraisLivraison'] as int,
      heureRecuperationSouhaitee: wantedAt == null ? null : DateTime.parse(wantedAt),
      validatedAt: validated == null ? null : DateTime.parse(validated),
      readyAt: ready == null ? null : DateTime.parse(ready),
      motifAnnulation: json['motifAnnulation'] as String?,
      modeConsommation: modeConsName != null 
          ? ModeConsommation.values.firstWhere((m) => m.name == modeConsName, orElse: () => ModeConsommation.surPlace)
          : null,
    );
  }

  static StatutCommande _mapStatut(String raw) {
    switch (raw) {
      case 'recue':
        return StatutCommande.enAttenteValidation;
      case 'annulee':
        return StatutCommande.annuleeClient;
      default:
        return StatutCommande.values.firstWhere(
          (s) => s.name == raw,
          orElse: () => StatutCommande.enAttenteValidation,
        );
    }
  }
}
