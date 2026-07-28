class RestaurantTable {
  const RestaurantTable({
    required this.id,
    required this.restaurantId,
    required this.numero,
    required this.capacite,
    this.description,
  });

  final String id;
  final String restaurantId;
  final String numero;
  final int capacite;
  final String? description;

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      numero: json['numero'] as String,
      capacite: json['capacite'] as int,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'numero': numero,
      'capacite': capacite,
      'description': description,
    };
  }
}

class TimeSlot {
  const TimeSlot({
    required this.id,
    required this.heureDebut,
    required this.heureFin,
    required this.isAvailable,
  });

  final String id;
  final String heureDebut;
  final String heureFin;
  final bool isAvailable;

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] as String,
      heureDebut: json['heureDebut'] as String,
      heureFin: json['heureFin'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'heureDebut': heureDebut,
      'heureFin': heureFin,
      'isAvailable': isAvailable,
    };
  }
}
