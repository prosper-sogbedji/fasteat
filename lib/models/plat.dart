class Plat {
  const Plat({
    required this.id,
    required this.restoId,
    required this.nom,
    required this.categorie,
    required this.description,
    required this.prix,
    required this.image,
    required this.disponible,
  });

  final String id;
  final String restoId;
  final String nom;
  final String categorie;
  final String description;
  final int prix;
  final String image;
  final bool disponible;
}
