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
    final restaurant = json['restaurant'];
    final restaurantMap = restaurant is Map ? Map<String, dynamic>.from(restaurant) : const <String, dynamic>{};
    final category = json['category'];
    final categoryMap = category is Map ? Map<String, dynamic>.from(category) : const <String, dynamic>{};
    final imagesRaw = json['images'] ?? json['imageUrls'] ?? json['photos'];
    final images = <String>[];
    if (imagesRaw is List) {
      for (final item in imagesRaw) {
        final value = item?.toString() ?? '';
        if (value.isNotEmpty) images.add(_absoluteImageUrl(value));
      }
    }
    final singleImage = json['photoUrl'] ?? json['imageUrl'] ?? json['image'] ?? json['coverImageUrl'];
    if (images.isEmpty && singleImage != null) {
      final value = singleImage.toString();
      if (value.isNotEmpty) images.add(_absoluteImageUrl(value));
    }

    final priceRaw = json['price'] ?? json['prix'] ?? json['unitPrice'] ?? json['amount'];
    final price = priceRaw is num ? priceRaw.toInt() : int.tryParse(priceRaw?.toString() ?? '') ?? 0;

    return Plat(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      restoId: (json['restaurantId'] ?? json['restaurant_id'] ?? restaurantMap['id'] ?? restaurantMap['_id'] ?? '').toString(),
      nom: (json['name'] ?? json['nom'] ?? json['title'] ?? 'Plat').toString(),
      categorie: (json['categoryName'] ?? categoryMap['name'] ?? json['category'] ?? json['categoryId'] ?? 'Plats').toString(),
      description: (json['description'] ?? '').toString(),
      prix: price,
      images: images,
      disponible: json['isAvailable'] != false && json['disponible'] != false,
    );
  }

  static String _absoluteImageUrl(String value) {
    if (value.startsWith('/assets/')) {
      return 'https://fast-eat-npb7.onrender.com$value';
    }
    return value;
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
