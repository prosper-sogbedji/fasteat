import '../../models/plat.dart';

const mockPlats = <Plat>[
  // Restaurant 1: Chez Tantie Adjoua (r1)
  Plat(
    id: 'p1_1',
    restoId: 'r1',
    nom: 'Igname pilée sauce graine',
    categorie: 'Plats',
    description: 'Une délicieuse igname pilée servie avec une sauce graine riche et viande de bœuf.',
    prix: 2500,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p1_2',
    restoId: 'r1',
    nom: 'Amiwo au poulet',
    categorie: 'Plats',
    description: 'Pâte rouge béninoise avec un morceau de poulet bien braisé.',
    prix: 2000,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),

  // Restaurant 2: Maquis du Port (r2)
  Plat(
    id: 'p2_1',
    restoId: 'r2',
    nom: 'Poulet braisé complet',
    categorie: 'Grillades',
    description: 'Poulet entier braisé au feu de bois avec des épices locales, servi avec des frites ou alloco.',
    prix: 5000,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p2_2',
    restoId: 'r2',
    nom: 'Poisson braisé',
    categorie: 'Grillades',
    description: 'Tilapia frais braisé, sauce tomate pimentée.',
    prix: 3500,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),

  // Restaurant 3: Le Bananier (r3)
  Plat(
    id: 'p3_1',
    restoId: 'r3',
    nom: 'Attiéké Poisson Thon',
    categorie: 'Plats Ivoirien',
    description: 'Attiéké frais servi avec du poisson thon frit et une petite sauce claire.',
    prix: 1500,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p3_2',
    restoId: 'r3',
    nom: 'Garba Royal',
    categorie: 'Plats Ivoirien',
    description: 'Le vrai garba d\'Abidjan avec un gros morceau de thon.',
    prix: 2500,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),

  // Restaurant 4: Fast Delices (r4)
  Plat(
    id: 'p4_1',
    restoId: 'r4',
    nom: 'Burger Maison',
    categorie: 'Fast Food',
    description: 'Burger avec pain brioché, steak haché 150g, fromage cheddar, sauce secrète.',
    prix: 3000,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p4_2',
    restoId: 'r4',
    nom: 'Pizza Reine',
    categorie: 'Fast Food',
    description: 'Pizza sauce tomate, jambon, champignons frais, mozzarella.',
    prix: 4500,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),

  // Restaurant 5: La Terrasse d'Abomey (r5)
  Plat(
    id: 'p5_1',
    restoId: 'r5',
    nom: 'Pâte noire (Amala) sauce crincrin',
    categorie: 'Traditionnel',
    description: 'Amala chaud avec une sauce gluante et de la viande de mouton.',
    prix: 3000,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p5_2',
    restoId: 'r5',
    nom: 'Doko (Beignets) avec bouillie',
    categorie: 'Dessert / Goûter',
    description: 'Beignets bien sucrés accompagnés d\'une bouillie de mil chaude.',
    prix: 1000,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
];
