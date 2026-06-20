class Plat {
  const Plat({
    required this.id,
    required this.restoId,
    required this.nom,
    required this.categorie,
    required this.description,
    required this.prix,
    required this.images,
    required this.disponible,
  });

  factory Plat.fromJson(Map<String, dynamic> json) {
    final price = json['price'];
    final int prixValue = price is num
        ? price.toInt()
        : int.tryParse(price?.toString() ?? '') ?? 0;

    final photo = json['photoUrl'] ?? json['imageUrl'] ?? json['image'];
    final List<String> images = photo != null ? [photo.toString()] : [];

    return Plat(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      restoId: (json['restaurantId'] ?? json['restaurant_id'] ?? '').toString(),
      nom: (json['name'] ?? json['nom'] ?? '').toString(),
      categorie: (json['categoryId'] ?? json['category'] ?? 'plats').toString(),
      description: (json['description'] ?? '').toString(),
      prix: prixValue,
      images: images,
      disponible: json['isAvailable'] ?? json['disponible'] ?? true,
    );
  }

  final String id;
  final String restoId;
  final String nom;
  final String categorie;
  final String description;
  final int prix;
  final List<String> images;
  final bool disponible;

  String get image => images.isNotEmpty ? images.first : '';

  Plat copyWith({
    String? id,
    String? restoId,
    String? nom,
    String? categorie,
    String? description,
    int? prix,
    List<String>? images,
    bool? disponible,
  }) {
    return Plat(
      id: id ?? this.id,
      restoId: restoId ?? this.restoId,
      nom: nom ?? this.nom,
      categorie: categorie ?? this.categorie,
      description: description ?? this.description,
      prix: prix ?? this.prix,
      images: images ?? this.images,
      disponible: disponible ?? this.disponible,
    );
  }
}
