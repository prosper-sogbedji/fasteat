class Restaurant {
  const Restaurant({
    required this.id,
    required this.nom,
    required this.cuisine,
    required this.quartier,
    required this.note,
    required this.avis,
    required this.tempsEstime,
    required this.livraison,
    required this.qrCode,
    required this.abonnement,
    required this.images,
    this.certifie = false,
  });

  final String id;
  final String nom;
  final String cuisine;
  final String quartier;
  final double note;
  final int avis;
  final String tempsEstime;
  final bool livraison;
  final bool qrCode;
  final String abonnement;
  /// Plusieurs visuels pour carrousel (accueil, etc.). Le premier sert d’image principale.
  final List<String> images;
  final bool certifie;

  String get image => images.isNotEmpty ? images.first : '';

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final imagesRaw = json['images'] ?? json['imageUrls'] ?? json['photos'];
    final images = <String>[];
    if (imagesRaw is List) {
      for (final item in imagesRaw) {
        final s = item?.toString() ?? '';
        if (s.isNotEmpty) images.add(s);
      }
    }
    final singleImage = json['imageUrl'] ?? json['coverImageUrl'] ?? json['image'] ?? json['heroImageUrl'];
    if (images.isEmpty && singleImage != null) {
      String s = singleImage.toString();
      if (s.startsWith('/assets/')) {
        // Le backend renvoie parfois un chemin relatif. On le transforme en lien absolu.
        s = 'https://fast-eat-npb7.onrender.com\$s';
      }
      if (s.isNotEmpty) images.add(s);
    }

    double note = 0;
    final noteRaw = json['note'] ?? json['rating'] ?? json['averageRating'];
    if (noteRaw is num) {
      note = noteRaw.toDouble();
    } else {
      note = double.tryParse(noteRaw?.toString() ?? '') ?? 0;
    }

    int avis = 0;
    final avisRaw = json['avis'] ?? json['reviewCount'] ?? json['reviewsCount'] ?? json['reviews'];
    if (avisRaw is num) {
      avis = avisRaw.toInt();
    } else {
      avis = int.tryParse(avisRaw?.toString() ?? '') ?? 0;
    }

    return Restaurant(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      nom: (json['nom'] ?? json['name'] ?? '').toString(),
      cuisine: (json['cuisine'] ?? json['cuisineType'] ?? json['category'] ?? '').toString(),
      quartier: (json['quartier'] ?? json['district'] ?? json['address'] ?? json['location'] ?? '').toString(),
      note: note,
      avis: avis,
      tempsEstime: (json['tempsEstime'] ?? json['estimatedTime'] ?? json['deliveryTime'] ?? '15 min').toString(),
      livraison: json['livraison'] == true || json['deliveryEnabled'] == true || json['hasDelivery'] == true,
      qrCode: json['qrCode'] == true || json['qrEnabled'] == true || json['hasQrOrdering'] == true,
      abonnement: (json['abonnement'] ?? json['subscription'] ?? json['plan'] ?? 'starter').toString(),
      images: images,
      certifie: json['certifie'] == true || json['certified'] == true || json['isCertified'] == true,
    );
  }
}
