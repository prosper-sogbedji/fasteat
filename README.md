# FastEat Benin — Application client

Application Flutter **mobile client** pour commander auprès des restaurants partenaires au Bénin.

Le **back-office restaurant** est un projet séparé : `../fasteat_dashboard`.

## API

- Base : `https://fast-eat-npb7.onrender.com/api/v1`
- Configuration : `lib/data/api/api_config.dart`

## Lancer l'app

```bash
cd fasteat
flutter pub get
flutter run
```

## Architecture

| Dossier | Rôle |
|---------|------|
| `lib/data/api/` | Services HTTP (auth, restaurants, panier, commandes, paiements, favoris, notifications) |
| `lib/providers/` | État global (Provider) |
| `lib/screens/` | Écrans client uniquement |
| `lib/data/mock/` | Données de secours hors ligne / démo |

## Parcours principal

1. Onboarding / connexion (JWT)
2. Accueil → restaurant → détail plat → panier
3. Paiement Mobile Money (checkout API si connecté)
4. Suivi & historique des commandes
5. Favoris restaurants synchronisés (`/favorites`)
6. Centre de notifications (`/notifications`)

## Projets liés

- **Client (ce repo)** : `fasteat`
- **Dashboard restaurant** : `fasteat_dashboard`
