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
}
