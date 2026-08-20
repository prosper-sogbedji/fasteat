import '../../models/plat.dart';

const mockPlats = <Plat>[
  // ═══════════════════════════════════════════════════
  // Restaurant 1 : Chez Tantie Adjoua (r1) — Béninoise
  // ═══════════════════════════════════════════════════
  Plat(
    id: 'p1_1',
    restoId: 'r1',
    nom: 'Igname pilée sauce graine',
    categorie: 'Plats de résistance',
    description:
        'Igname pilée onctueuse servie avec une sauce graine riche, mijotée lentement avec de la viande de bœuf fondante et des épices locales. Un incontournable de la cuisine béninoise.',
    prix: 2500,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p1_2',
    restoId: 'r1',
    nom: 'Amiwo au poulet braisé',
    categorie: 'Plats de résistance',
    description:
        'Pâte rouge béninoise préparée avec des tomates fraîches et du concentré, accompagnée d\'un beau morceau de poulet braisé bien mariné. Saveurs authentiques garanties.',
    prix: 2000,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p1_3',
    restoId: 'r1',
    nom: 'Pâte noire sauce crincrin',
    categorie: 'Plats de résistance',
    description:
        'Amala chaud et savoureux accompagné d\'une sauce crincrin gluante, riche en feuilles et servie avec du mouton bien cuit. Recette ancestrale de grand-mère.',
    prix: 2800,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p1_4',
    restoId: 'r1',
    nom: 'Gboma Dessi (Ragoût de bœuf)',
    categorie: 'Entrées',
    description:
        'Ragoût de bœuf mijoté aux feuilles de gboma (aubergine africaine), servi avec une sauce tomate relevée. Entrée consistante et parfumée.',
    prix: 1500,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p1_5',
    restoId: 'r1',
    nom: 'Akassa Fon',
    categorie: 'Entrées',
    description:
        'Boule de pâte de maïs fermentée, servie avec une sauce arachide ou sauce tomate. Spécialité fon très appréciée au petit-déjeuner et en entrée.',
    prix: 800,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p1_6',
    restoId: 'r1',
    nom: 'Boisson Bissap Maison',
    categorie: 'Boissons',
    description:
        'Infusion fraîche de fleurs d\'hibiscus, sucrée naturellement avec du gingembre. Servie bien froide, maison et sans conservateur.',
    prix: 500,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p1_7',
    restoId: 'r1',
    nom: 'Eau minérale 1.5L',
    categorie: 'Boissons',
    description: 'Eau minérale fraîche.',
    prix: 300,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p1_8',
    restoId: 'r1',
    nom: 'Dégué au lait de coco',
    categorie: 'Desserts',
    description:
        'Dessert traditionnel à base de couscous de mil, de lait caillé et lait de coco. Frais, légèrement sucré et très parfumé.',
    prix: 700,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),

  // ═══════════════════════════════════════════════════
  // Restaurant 2 : Maquis du Port (r2) — Grillades
  // ═══════════════════════════════════════════════════
  Plat(
    id: 'p2_1',
    restoId: 'r2',
    nom: 'Poulet braisé complet',
    categorie: 'Grillades',
    description:
        'Poulet entier braisé au feu de bois avec un mélange d\'épices locales secrètes. Servi avec des frites maison ou de l\'alloco. Croustillant dehors, juteux dedans.',
    prix: 5000,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p2_2',
    restoId: 'r2',
    nom: 'Poisson braisé Tilapia',
    categorie: 'Grillades',
    description:
        'Tilapia frais du marché, braisé sur charbon de bois, servi avec une sauce tomate pimentée maison et des oignons. Accompagnement de votre choix.',
    prix: 3500,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p2_3',
    restoId: 'r2',
    nom: 'Côtes d\'agneau grillées',
    categorie: 'Grillades',
    description:
        'Côtes d\'agneau marinées à l\'ail, au persil et aux épices, grillées à point sur braise vive. Tendres et savoureuses, servies avec légumes grillés.',
    prix: 6500,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p2_4',
    restoId: 'r2',
    nom: 'Brochettes de bœuf x5',
    categorie: 'Entrées',
    description:
        '5 brochettes de bœuf tendres, marinées dans une sauce épicée maison. Idéal en entrée ou à partager entre amis.',
    prix: 2000,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p2_5',
    restoId: 'r2',
    nom: 'Salade de crudités',
    categorie: 'Entrées',
    description:
        'Salade fraîche de tomates, concombres, avocats et carottes. Vinaigrette citron-gingembre maison.',
    prix: 1000,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p2_6',
    restoId: 'r2',
    nom: 'Frites maison',
    categorie: 'Accompagnements',
    description: 'Frites de pommes de terre fraîches, cuites à l\'huile de palme. Croustillantes et légèrement salées.',
    prix: 800,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p2_7',
    restoId: 'r2',
    nom: 'Alloco (Banane plantain frite)',
    categorie: 'Accompagnements',
    description: 'Tranches de banane plantain mûre, frites à l\'huile de palme. Sucrées et fondantes.',
    prix: 600,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p2_8',
    restoId: 'r2',
    nom: 'Jus de gingembre frais',
    categorie: 'Boissons',
    description: 'Jus de gingembre fraîchement pressé, légèrement sucré. Énergisant et rafraîchissant.',
    prix: 600,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),

  // ═══════════════════════════════════════════════════
  // Restaurant 3 : Le Bananier (r3) — Ivoirienne/Béninoise
  // ═══════════════════════════════════════════════════
  Plat(
    id: 'p3_1',
    restoId: 'r3',
    nom: 'Attiéké Poisson Thon',
    categorie: 'Plats ivoiriens',
    description:
        'Attiéké frais (couscous de manioc) servi avec du poisson thon frit croustillant et une sauce claire aux oignons et tomates. La valeur sûre de la cuisine ivoirienne.',
    prix: 1500,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p3_2',
    restoId: 'r3',
    nom: 'Garba Royal',
    categorie: 'Plats ivoiriens',
    description:
        'Le vrai garba d\'Abidjan ! Attiéké généreux avec un grand morceau de thon frit, sauce mayo-piment. Un classique devenu culte dans toute l\'Afrique de l\'Ouest.',
    prix: 2500,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p3_3',
    restoId: 'r3',
    nom: 'Kedjenou de poulet',
    categorie: 'Plats ivoiriens',
    description:
        'Poulet mijoté en cocotte hermétique avec des épices et légumes. Cuisson à l\'étouffée qui donne une viande ultra-tendre et un jus savoureux. Servi avec du riz ou de l\'attiéké.',
    prix: 3500,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p3_4',
    restoId: 'r3',
    nom: 'Igname frite sauce aubergine',
    categorie: 'Plats béninois',
    description:
        'Igname fraîche frite dans un bain d\'huile bien chaud, accompagnée d\'une sauce aubergine africaine relevée. Plat complet et nourrissant.',
    prix: 1800,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p3_5',
    restoId: 'r3',
    nom: 'Riz gras djolof',
    categorie: 'Plats béninois',
    description:
        'Riz cuit dans un bouillon de tomates et d\'épices, servi avec du poulet et des légumes. Une recette festive qui fait l\'unanimité.',
    prix: 2200,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p3_6',
    restoId: 'r3',
    nom: 'Gnamakoudji (Gingembre)',
    categorie: 'Boissons',
    description:
        'Boisson de gingembre ivoirienne, épicée et rafraîchissante. Servie bien froide avec une touche de menthe.',
    prix: 500,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p3_7',
    restoId: 'r3',
    nom: 'Boule de plantain rôti',
    categorie: 'Accompagnements',
    description: 'Plantain rôti au four, légèrement caramélisé. Accompagnement parfait pour les grillades.',
    prix: 700,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),

  // ═══════════════════════════════════════════════════
  // Restaurant 4 : Fast Délices (r4) — Fast-food local
  // ═══════════════════════════════════════════════════
  Plat(
    id: 'p4_1',
    restoId: 'r4',
    nom: 'Burger Maison Double',
    categorie: 'Burgers',
    description:
        'Deux steaks hachés de bœuf local 150g, pain brioché toasté, fromage cheddar fondu, sauce secrète maison, tomates fraîches et salade croquante. Notre bestseller absolu.',
    prix: 3500,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p4_2',
    restoId: 'r4',
    nom: 'Pizza Reine Maison',
    categorie: 'Pizzas',
    description:
        'Pizza à pâte fine et croustillante, sauce tomate maison, jambon, champignons frais, poivrons colorés et mozzarella fondante. Cuite au four à bois.',
    prix: 4500,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p4_3',
    restoId: 'r4',
    nom: 'Shawarma Poulet',
    categorie: 'Sandwichs',
    description:
        'Poulet mariné grillé à la broche, légumes frais, sauce blanche et sauce piment. Emballé dans un pain pita chaud et moelleux. Incontournable !',
    prix: 2500,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p4_4',
    restoId: 'r4',
    nom: 'Poulet frit & Frites',
    categorie: 'Burgers',
    description:
        'Morceaux de poulet panés et frits, croustillants à souhait, servis avec une portion de frites maison et sauce ketchup ou mayo.',
    prix: 3000,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p4_5',
    restoId: 'r4',
    nom: 'Frites maison grandes',
    categorie: 'Accompagnements',
    description: 'Grande portion de frites croustillantes, légèrement salées. Cuites dans une huile fraîche.',
    prix: 1000,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p4_6',
    restoId: 'r4',
    nom: 'Coca-Cola 33cl',
    categorie: 'Boissons',
    description: 'Canette Coca-Cola bien fraîche.',
    prix: 500,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p4_7',
    restoId: 'r4',
    nom: 'Milkshake Chocolat',
    categorie: 'Desserts',
    description:
        'Milkshake onctueux au chocolat belge, garni de chantilly et copeaux de chocolat. La touche sucrée parfaite pour finir votre repas.',
    prix: 1500,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),

  // ═══════════════════════════════════════════════════
  // Restaurant 5 : La Terrasse d'Abomey (r5) — Traditionnel
  // ═══════════════════════════════════════════════════
  Plat(
    id: 'p5_1',
    restoId: 'r5',
    nom: 'Pâte noire (Amala) sauce crincrin',
    categorie: 'Plats traditionnels',
    description:
        'Amala chaud et soyeux accompagné d\'une sauce crincrin gluante aux épices, avec de la viande de mouton fondante. La fierté gastronomique d\'Abomey.',
    prix: 3000,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p5_2',
    restoId: 'r5',
    nom: 'Doko (Beignets) & Bouillie',
    categorie: 'Desserts & Goûter',
    description:
        'Beignets croustillants et bien sucrés accompagnés d\'une bouillie de mil chaude et parfumée à la muscade. Le goûter traditionnel béninois.',
    prix: 1000,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p5_3',
    restoId: 'r5',
    nom: 'Sauce arachide royal au bœuf',
    categorie: 'Plats traditionnels',
    description:
        'Sauce arachide crémeuse et riche, préparée avec des arachides grillées maison, viande de bœuf et épices du terroir. Servi avec du riz blanc ou de l\'igname.',
    prix: 3500,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p5_4',
    restoId: 'r5',
    nom: 'Aboboi (Haricots à la sauce)',
    categorie: 'Plats traditionnels',
    description:
        'Haricots blancs cuits à point dans une sauce tomate épicée avec des morceaux de viande de porc. Plat consistant et savoureux, très populaire dans le centre du Bénin.',
    prix: 2000,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p5_5',
    restoId: 'r5',
    nom: 'Tchoukoutou (Bière de mil)',
    categorie: 'Boissons',
    description:
        'Bière artisanale de sorgho fermentée, légèrement alcoolisée. Boisson culturelle ancestrale servie fraîche dans un calebasse traditionnel.',
    prix: 800,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p5_6',
    restoId: 'r5',
    nom: 'Zoom-koom (Eau de mil)',
    categorie: 'Boissons',
    description: 'Boisson non alcoolisée à base de farine de mil, fraîche et naturellement sucrée. Alternative saine et authentique.',
    prix: 400,
    images: ['assets/images/plat_real_2.jpg'],
    disponible: true,
  ),
  Plat(
    id: 'p5_7',
    restoId: 'r5',
    nom: 'Assortiment de galettes',
    categorie: 'Entrées',
    description:
        'Plateau de galettes de maïs, de manioc et de sorgho grillées, servies avec une dip de sauce pimentée. Idéal pour un apéritif authentique.',
    prix: 1500,
    images: ['assets/images/plat_real_1.jpg'],
    disponible: true,
  ),
];
