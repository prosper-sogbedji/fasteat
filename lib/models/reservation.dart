enum StatutReservation {
  enAttente,
  confirmee,
  refusee,
  annulee,
  terminee,
}

class Reservation {
  const Reservation({
    required this.id,
    required this.restaurantId,
    required this.restaurantNom,
    required this.date,
    required this.heure,
    required this.nombrePersonnes,
    this.commentaire,
    required this.statut,
    required this.createdAt,
    this.restaurantImage,
    this.tableId,
  });

  final String id;
  final String restaurantId;
  final String restaurantNom;
  final String? restaurantImage;
  final DateTime date;
  final String heure;
  final int nombrePersonnes;
  final String? commentaire;
  final StatutReservation statut;
  final DateTime createdAt;
  final String? tableId;

  /// Label humain du statut
  String get statutLabel {
    switch (statut) {
      case StatutReservation.enAttente:
        return 'En attente';
      case StatutReservation.confirmee:
        return 'Confirmée';
      case StatutReservation.refusee:
        return 'Refusée';
      case StatutReservation.annulee:
        return 'Annulée';
      case StatutReservation.terminee:
        return 'Terminée';
    }
  }

  bool get isActive =>
      statut == StatutReservation.enAttente ||
      statut == StatutReservation.confirmee;

  factory Reservation.fromJson(Map<String, dynamic> json) {
    StatutReservation statut;
    final statutRaw = (json['statut'] ?? json['status'] ?? 'enAttente').toString().toLowerCase();
    switch (statutRaw) {
      case 'confirmee':
      case 'confirmed':
        statut = StatutReservation.confirmee;
        break;
      case 'refusee':
      case 'refused':
      case 'rejected':
        statut = StatutReservation.refusee;
        break;
      case 'annulee':
      case 'cancelled':
      case 'canceled':
        statut = StatutReservation.annulee;
        break;
      case 'terminee':
      case 'completed':
        statut = StatutReservation.terminee;
        break;
      default:
        statut = StatutReservation.enAttente;
    }

    DateTime parseDate(dynamic raw) {
      if (raw == null) return DateTime.now();
      if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
      return DateTime.tryParse(raw.toString()) ?? DateTime.now();
    }

    return Reservation(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      restaurantId: (json['restaurantId'] ?? json['restaurant_id'] ?? '').toString(),
      restaurantNom: (json['restaurantNom'] ?? json['restaurantName'] ?? json['nom'] ?? '').toString(),
      restaurantImage: json['restaurantImage']?.toString(),
      date: parseDate(json['date']),
      heure: (json['heure'] ?? json['time'] ?? '').toString(),
      nombrePersonnes: int.tryParse((json['nombrePersonnes'] ?? json['guests'] ?? json['partySize'] ?? 1).toString()) ?? 1,
      commentaire: json['commentaire']?.toString() ?? json['comment']?.toString(),
      statut: statut,
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
      tableId: json['tableId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'restaurantNom': restaurantNom,
      'restaurantImage': restaurantImage,
      'date': date.toIso8601String(),
      'heure': heure,
      'nombrePersonnes': nombrePersonnes,
      'commentaire': commentaire,
      'statut': statut.name,
      'createdAt': createdAt.toIso8601String(),
      'tableId': tableId,
    };
  }

  Reservation copyWith({StatutReservation? statut, String? commentaire, String? tableId}) {
    return Reservation(
      id: id,
      restaurantId: restaurantId,
      restaurantNom: restaurantNom,
      restaurantImage: restaurantImage,
      date: date,
      heure: heure,
      nombrePersonnes: nombrePersonnes,
      commentaire: commentaire ?? this.commentaire,
      statut: statut ?? this.statut,
      createdAt: createdAt,
      tableId: tableId ?? this.tableId,
    );
  }
}
