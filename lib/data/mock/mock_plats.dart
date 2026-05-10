import '../../models/plat.dart';

const mockPlats = <Plat>[
  Plat(
    id: 'p1',
    restoId: 'r1',
    nom: 'Riz au gras + Poulet braise',
    categorie: 'Plats',
    description:
        "Riz cuit dans une sauce tomate epicee, accompagne d'un demi-poulet braise grille au charbon",
    prix: 2500,
    image: 'assets/images/plat_real_1.jpg',
    disponible: true,
  ),
  Plat(
    id: 'p2',
    restoId: 'r1',
    nom: 'Attieke Poisson braise',
    categorie: 'Plats',
    description:
        "Semoule de manioc fraiche accompagnee d'un poisson braise et d'une sauce tomate pimentee",
    prix: 2000,
    image: 'assets/images/plat_real_2.jpg',
    disponible: true,
  ),
  Plat(
    id: 'p3',
    restoId: 'r1',
    nom: 'Pate noire + Sauce gluglu',
    categorie: 'Plats',
    description:
        'Pate de mais noir traditionnelle avec sauce gombo et viande de boeuf',
    prix: 1500,
    image: 'assets/images/plat_real_1.jpg',
    disponible: true,
  ),
  Plat(
    id: 'p4',
    restoId: 'r1',
    nom: 'Jus de bissap maison',
    categorie: 'Boissons',
    description:
        "Boisson naturelle a base de fleurs d'hibiscus, legerement sucree",
    prix: 500,
    image: 'assets/images/plat_real_2.jpg',
    disponible: true,
  ),
  Plat(
    id: 'p5',
    restoId: 'r2',
    nom: 'Brochettes de boeuf',
    categorie: 'Entrees',
    description:
        '6 brochettes de boeuf marinees et grillees, servies avec oignons et piment',
    prix: 1800,
    image: 'assets/images/plat_real_1.jpg',
    disponible: true,
  ),
  Plat(
    id: 'p6',
    restoId: 'r2',
    nom: 'Poulet yassa',
    categorie: 'Plats',
    description:
        'Poulet mijote a la sauce yassa servi avec du riz blanc',
    prix: 3000,
    image: 'assets/images/plat_real_2.jpg',
    disponible: true,
  ),
];
