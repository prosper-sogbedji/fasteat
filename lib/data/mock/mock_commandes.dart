import '../../models/commande.dart';

final mockCommandes = <Commande>[
  Commande(
    id: '#FE-2047',
    restaurantId: 'r1',
    restaurantNom: 'Chez Tantie Adjoua',
    date: DateTime(2026, 5, 3, 12, 20),
    createdAt: DateTime(2026, 5, 3, 12, 20),
    mode: ModeCommande.livraison,
    statut: StatutCommande.preparation,
    lignes: const [
      LigneCommande(
        platId: 'p1',
        nomPlat: 'Riz au gras + Poulet braise',
        quantite: 1,
        prixUnitaire: 2500,
      ),
      LigneCommande(
        platId: 'p4',
        nomPlat: 'Jus de bissap maison',
        quantite: 1,
        prixUnitaire: 500,
      ),
    ],
    fraisLivraison: 500,
  ),
  Commande(
    id: '#FE-2033',
    restaurantId: 'r2',
    restaurantNom: 'Maquis du Port',
    date: DateTime(2026, 5, 1, 20, 10),
    createdAt: DateTime(2026, 5, 1, 20, 10),
    mode: ModeCommande.programmee,
    statut: StatutCommande.livree,
    lignes: const [
      LigneCommande(
        platId: 'p6',
        nomPlat: 'Poulet yassa',
        quantite: 2,
        prixUnitaire: 3000,
      ),
    ],
    fraisLivraison: 0,
  ),
];
