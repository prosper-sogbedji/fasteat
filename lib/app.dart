import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';

import 'screens/auth/connexion_screen.dart';
import 'screens/auth/inscription_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/chat/chat_placeholder.dart';
import 'screens/commande/panier_livraison_screen.dart';
import 'screens/commande/panier_programmee_screen.dart';
import 'screens/commande/panier_qr_screen.dart';
import 'screens/commande/qr_scanner_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/recherche_screen.dart';
import 'screens/historique/historique_placeholder.dart';
import 'screens/historique/laisser_avis_screen.dart';
import 'screens/notifications/notifications_placeholder.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/splash_screen.dart';
import 'screens/paiement/choix_paiement_screen.dart';
import 'screens/paiement/commande_confirmee_screen.dart';
import 'screens/paiement/paiement_processing_screen.dart';
import 'screens/profil/parrainage_screen.dart';
import 'screens/profil/mes_infos_screen.dart';
import 'screens/profil/favoris_screen.dart';
import 'screens/profil/profil_placeholder.dart';
import 'screens/restaurant/plat_detail_screen.dart';
import 'screens/restaurant/restaurant_screen.dart';
import 'screens/suivi/suivi_placeholder.dart';
import 'theme/app_theme.dart';

class FastEatApp extends StatelessWidget {
  const FastEatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.connexion,
          builder: (context, state) => const ConnexionScreen(),
        ),
        GoRoute(
          path: AppRoutes.inscription,
          builder: (context, state) => const InscriptionScreen(),
        ),
        GoRoute(
          path: AppRoutes.otp,
          builder: (context, state) => const OtpScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.recherche,
          builder: (context, state) => const RechercheScreen(),
        ),
        GoRoute(
          path: '${AppRoutes.restaurant}/:id',
          builder: (context, state) => RestaurantScreen(
            restaurantId: state.pathParameters['id'] ?? 'r1',
          ),
        ),
        GoRoute(
          path: '${AppRoutes.plat}/:id',
          builder: (context, state) => PlatDetailScreen(
            platId: state.pathParameters['id'] ?? 'p1',
          ),
        ),
        GoRoute(
          path: AppRoutes.panier,
          builder: (context, state) => const PanierLivraisonScreen(),
        ),
        GoRoute(
          path: AppRoutes.panierProgrammee,
          builder: (context, state) => const PanierProgrammeeScreen(),
        ),
        GoRoute(
          path: AppRoutes.panierQr,
          builder: (context, state) => const PanierQrScreen(),
        ),
        GoRoute(
          path: AppRoutes.qrScanner,
          builder: (context, state) => const QrScannerScreen(),
        ),
        GoRoute(
          path: AppRoutes.paiementChoix,
          builder: (context, state) => const ChoixPaiementScreen(),
        ),
        GoRoute(
          path: AppRoutes.paiementProcessing,
          builder: (context, state) => const PaiementProcessingScreen(),
        ),
        GoRoute(
          path: AppRoutes.commandeConfirmee,
          builder: (context, state) => const CommandeConfirmeeScreen(),
        ),
        GoRoute(
          path: AppRoutes.suivi,
          builder: (context, state) => const SuiviPlaceholderScreen(),
        ),
        GoRoute(
          path: AppRoutes.historique,
          builder: (context, state) => const HistoriquePlaceholderScreen(),
        ),
        GoRoute(
          path: AppRoutes.avis,
          builder: (context, state) => const LaisserAvisScreen(),
        ),
        GoRoute(
          path: AppRoutes.chat,
          builder: (context, state) => const ChatPlaceholderScreen(),
        ),
        GoRoute(
          path: AppRoutes.profil,
          builder: (context, state) => const ProfilPlaceholderScreen(),
        ),
        GoRoute(
          path: AppRoutes.parrainage,
          builder: (context, state) => const ParrainageScreen(),
        ),
        GoRoute(
          path: AppRoutes.mesInfos,
          builder: (context, state) => const MesInfosScreen(),
        ),
        GoRoute(
          path: AppRoutes.favoris,
          builder: (context, state) => const FavorisScreen(),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          builder: (context, state) => const NotificationsPlaceholderScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FastEat Benin',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
