import 'plat.dart';

enum StatutCataloguePlat {
  brouillon,
  enRelecture,
  publie,
  suspendu,
}

extension StatutCataloguePlatX on StatutCataloguePlat {
  String get libelle => switch (this) {
        StatutCataloguePlat.brouillon => 'Brouillon',
        StatutCataloguePlat.enRelecture => 'En relecture',
        StatutCataloguePlat.publie => 'Publié',
        StatutCataloguePlat.suspendu => 'Suspendu',
      };
}

class MenuCatalogueEntry {
  const MenuCatalogueEntry({
    required this.plat,
    required this.statut,
    required this.maj,
    this.datePublication,
    this.sousTitre,
    this.tags = const [],
    this.allergenes = const [],
    this.tempsPreparationMin,
    this.motsCleRecherche = '',
  });

  final Plat plat;
  final StatutCataloguePlat statut;
  final DateTime maj;
  final DateTime? datePublication;
  final String? sousTitre;
  final List<String> tags;
  final List<String> allergenes;
  final int? tempsPreparationMin;
  final String motsCleRecherche;

  MenuCatalogueEntry copyWith({
    Plat? plat,
    StatutCataloguePlat? statut,
    DateTime? maj,
    DateTime? datePublication,
    String? sousTitre,
    List<String>? tags,
    List<String>? allergenes,
    int? tempsPreparationMin,
    String? motsCleRecherche,
  }) {
    return MenuCatalogueEntry(
      plat: plat ?? this.plat,
      statut: statut ?? this.statut,
      maj: maj ?? this.maj,
      datePublication: datePublication ?? this.datePublication,
      sousTitre: sousTitre ?? this.sousTitre,
      tags: tags ?? this.tags,
      allergenes: allergenes ?? this.allergenes,
      tempsPreparationMin: tempsPreparationMin ?? this.tempsPreparationMin,
      motsCleRecherche: motsCleRecherche ?? this.motsCleRecherche,
    );
  }
}

class PlatWizardDraft {
  PlatWizardDraft({
    this.nom = '',
    this.sousTitre = '',
    this.descriptionCourte = '',
    this.descriptionLongue = '',
    this.categorie = 'Plats',
    List<String>? tags,
    this.ordreAffichage = 0,
    this.prixFcfa = 0,
    this.prixPromoFcfa,
    this.labelPromo = '',
    List<String>? imagesSelection,
    Set<String>? allergenes,
    this.niveauPiquant = 0,
    this.tempsPreparationMin = 20,
    this.portionsDefaut = 1,
    this.caloriesApprox,
    Set<String>? joursDisponibilite,
    this.creneauHoraire = '11h30 – 22h00',
    this.stockIllimite = true,
    this.stockPortions,
    this.modeLivraison = true,
    this.modeSurPlace = true,
    this.modeProgrammeeQr = true,
    List<({String nom, int supplementFcfa})>? optionsSupplement,
    this.motsCleRecherche = '',
    this.datePublicationProgrammee,
    this.publierImmediatement = true,
    this.accepteCharteQualite = false,
    this.accepteConformitePhotos = false,
    this.accepteMentionsLegales = false,
  })  : tags = tags ?? [],
        imagesSelection = imagesSelection ?? [],
        allergenes = allergenes ?? {},
        joursDisponibilite = joursDisponibilite ?? {'lun', 'mar', 'mer', 'jeu', 'ven', 'sam', 'dim'},
        optionsSupplement = optionsSupplement ?? [];

  String nom;
  String sousTitre;
  String descriptionCourte;
  String descriptionLongue;
  String categorie;
  List<String> tags;
  int ordreAffichage;
  int prixFcfa;
  int? prixPromoFcfa;
  String labelPromo;
  List<String> imagesSelection;
  Set<String> allergenes;
  int niveauPiquant;
  int tempsPreparationMin;
  int portionsDefaut;
  int? caloriesApprox;
  Set<String> joursDisponibilite;
  String creneauHoraire;
  bool stockIllimite;
  int? stockPortions;
  bool modeLivraison;
  bool modeSurPlace;
  bool modeProgrammeeQr;
  List<({String nom, int supplementFcfa})> optionsSupplement;
  String motsCleRecherche;
  DateTime? datePublicationProgrammee;
  bool publierImmediatement;
  bool accepteCharteQualite;
  bool accepteConformitePhotos;
  bool accepteMentionsLegales;

  static const joursLabels = <String, String>{
    'lun': 'Lun',
    'mar': 'Mar',
    'mer': 'Mer',
    'jeu': 'Jeu',
    'ven': 'Ven',
    'sam': 'Sam',
    'dim': 'Dim',
  };

  static const allergenesConnus = <String>[
    'Gluten',
    'Crustacés',
    'Œufs',
    'Poisson',
    'Arachides',
    'Soja',
    'Lait',
    'Fruits à coque',
    'Céleri',
    'Moutarde',
    'Sésame',
    'Sulfites',
    'Lupin',
    'Mollusques',
  ];

  static const categoriesSuggestion = <String>[
    'Entrees',
    'Plats',
    'Desserts',
    'Boissons',
    'Accompagnements',
  ];

  static const assetsVisuelsDemo = <String>[
    'assets/images/plat_real_1.jpg',
    'assets/images/plat_real_2.jpg',
    'assets/images/resto_real_1.jpg',
    'assets/images/resto_real_2.jpg',
  ];

  String get descriptionFusionnee {
    final b = StringBuffer(descriptionCourte.trim());
    if (descriptionLongue.trim().isNotEmpty) {
      if (b.isNotEmpty) b.writeln('\n\n');
      b.write(descriptionLongue.trim());
    }
    return b.toString().trim().isEmpty ? 'Description à compléter.' : b.toString();
  }

  int get prixEffect => (prixPromoFcfa != null && prixPromoFcfa! > 0 && prixPromoFcfa! < prixFcfa) ? prixPromoFcfa! : prixFcfa;

  Plat toPlat({required String id, required String restoId}) {
    return Plat(
      id: id,
      restoId: restoId,
      nom: nom.trim(),
      categorie: categorie,
      description: descriptionFusionnee,
      prix: prixEffect,
      images: imagesSelection.isNotEmpty ? List<String>.from(imagesSelection) : PlatWizardDraft.assetsVisuelsDemo.take(1).toList(),
      disponible: true,
    );
  }

  bool etapeValide(int index) {
    switch (index) {
      case 0:
        return true;
      case 1:
        return nom.trim().length >= 3;
      case 2:
        return descriptionCourte.trim().length >= 10 && descriptionLongue.trim().length >= 20;
      case 3:
        return categorie.trim().isNotEmpty;
      case 4:
        return prixFcfa > 0;
      case 5:
        return imagesSelection.isNotEmpty;
      case 6:
        return tempsPreparationMin > 0 && portionsDefaut > 0;
      case 7:
        return joursDisponibilite.isNotEmpty && creneauHoraire.trim().length >= 5;
      case 8:
        return modeLivraison || modeSurPlace || modeProgrammeeQr;
      case 9:
        return true;
      case 10:
        return true;
      case 11:
        return true;
      case 12:
        return accepteCharteQualite && accepteConformitePhotos && accepteMentionsLegales;
      default:
        return true;
    }
  }

  static const titresEtapes = <String>[
    'Bienvenue',
    'Identité du plat',
    'Descriptions',
    'Catégorie & étiquettes',
    'Tarification',
    'Photos & médias',
    'Allergènes & fiche technique',
    'Créneaux & stock',
    'Modes de commande',
    'Options & suppléments',
    'Visibilité & référencement',
    'Récapitulatif',
    'Publication',
  ];
}
