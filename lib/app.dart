import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app_routes.dart';
import 'providers/auth_provider.dart';

import 'navigation/main_shell_screen.dart';
import 'screens/auth/connexion_screen.dart';
import 'screens/auth/inscription_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/commande/panier_livraison_screen.dart';
import 'screens/commande/panier_programmee_screen.dart';
import 'screens/commande/panier_qr_screen.dart';
import 'screens/commande/qr_scanner_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/recherche_screen.dart';
import 'screens/historique/historique_screen.dart';
import 'screens/activite/activite_screen.dart';
import 'screens/historique/laisser_avis_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/splash_screen.dart';
import 'screens/paiement/choix_paiement_screen.dart';
import 'screens/paiement/commande_confirmee_screen.dart';
import 'screens/paiement/paiement_processing_screen.dart';
import 'screens/profil/parrainage_screen.dart';
import 'screens/profil/adresses_screen.dart';
import 'screens/profil/parametres_screen.dart';
import 'screens/profil/aide_screen.dart';
import 'screens/profil/mes_infos_screen.dart';
import 'screens/profil/favoris_screen.dart';
import 'screens/profil/profil_placeholder.dart';
import 'screens/profil/profil_screen.dart';
import 'screens/reservations/reservations_screen.dart';
import 'screens/reservations/nouvelle_reservation_screen.dart';
import 'screens/restaurant/plat_detail_screen.dart';
import 'screens/restaurant/restaurant_screen.dart';
import 'screens/suivi/suivi_screen.dart';
import 'theme/app_theme.dart';

bool _routeRequiresAuth(String location) {
  return location.startsWith(AppRoutes.paiementChoix) ||
      location.startsWith(AppRoutes.paiementProcessing) ||
      location == AppRoutes.mesInfos ||
      location == AppRoutes.parrainage ||
      location == AppRoutes.mesRestaurants ||
      location == AppRoutes.reservations ||
      location == AppRoutes.nouvelleReservation ||
      location == AppRoutes.notifications;
}

class FastEatApp extends StatefulWidget {
  const FastEatApp({super.key});

  @override
  State<FastEatApp> createState() => _FastEatAppState();
}

class _FastEatAppState extends State<FastEatApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _router = GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: auth,
      redirect: (ctx, state) {
        // Lire l'état frais à chaque redirection
        final a = ctx.read<AuthProvider>();
        if (!a.isReady) {
          return state.matchedLocation == AppRoutes.splash ? null : AppRoutes.splash;
        }
        if (_routeRequiresAuth(state.matchedLocation) && !a.isConnected) {
          return AppRoutes.connexion;
        }
        return null;
      },
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
          builder: (context, state) => OtpScreen(phone: state.uri.queryParameters['phone']),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainShellScreen(
              navigationShell: navigationShell,
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  pageBuilder: (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const HomeScreen(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.recherche,
                  pageBuilder: (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const RechercheScreen(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.activite,
                  pageBuilder: (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const ActiviteScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.profil,
          builder: (context, state) {
            final isConnected = context.read<AuthProvider>().isConnected;
            return isConnected ? const ProfilScreen() : const ProfilPlaceholderScreen();
          },
        ),
        GoRoute(
          path: '${AppRoutes.restaurant}/:id',
          builder: (context, state) => RestaurantScreen(
            restaurantId: state.pathParameters['id'] ?? 'r1',
          ),
        ),
        GoRoute(
          path: '${AppRoutes.plat}/:id',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: PlatDetailScreen(platId: state.pathParameters['id'] ?? 'p1'),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 0.2);
              const end = Offset.zero;
              const curve = Curves.easeOutCubic;
              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: animation.drive(tween), child: child),
              );
            },
          ),
        ),
        GoRoute(path: AppRoutes.panier, builder: (context, state) => const PanierLivraisonScreen()),
        GoRoute(path: AppRoutes.panierProgrammee, builder: (context, state) => const PanierProgrammeeScreen()),
        GoRoute(path: AppRoutes.panierQr, builder: (context, state) => const PanierQrScreen()),
        GoRoute(path: AppRoutes.qrScanner, builder: (context, state) => const QrScannerScreen()),
        GoRoute(path: AppRoutes.paiementChoix, builder: (context, state) => const ChoixPaiementScreen()),
        GoRoute(path: AppRoutes.paiementProcessing, builder: (context, state) => const PaiementProcessingScreen()),
        GoRoute(path: AppRoutes.commandeConfirmee, builder: (context, state) => const CommandeConfirmeeScreen()),
        GoRoute(path: AppRoutes.suivi, builder: (context, state) => const SuiviScreen()),
        GoRoute(path: AppRoutes.historique, builder: (context, state) => const HistoriqueScreen()),
        GoRoute(path: AppRoutes.avis, builder: (context, state) => const LaisserAvisScreen()),
        GoRoute(path: AppRoutes.chat, builder: (context, state) => const ChatScreen()),

        GoRoute(path: AppRoutes.parrainage, builder: (context, state) => const ParrainageScreen()),
        GoRoute(path: AppRoutes.mesInfos, builder: (context, state) => const MesInfosScreen()),
        GoRoute(path: AppRoutes.adresses, builder: (context, state) => const AdressesScreen()),
        GoRoute(path: AppRoutes.parametres, builder: (context, state) => const ParametresScreen()),
        GoRoute(path: AppRoutes.aide, builder: (context, state) => const AideScreen()),
        GoRoute(path: AppRoutes.mesRestaurants, builder: (context, state) => const FavorisScreen()),
        GoRoute(
          path: AppRoutes.notifications,
          builder: (context, state) => const NotificationsScreen(),
        ),
        // Reservation routes
        GoRoute(
          path: AppRoutes.reservations,
          builder: (context, state) => const ReservationsScreen(),
        ),
        GoRoute(
          path: AppRoutes.nouvelleReservation,
          builder: (context, state) {
            final params = state.uri.queryParameters;
            return NouvelleReservationScreen(
              restaurantId: params['restaurantId'],
              restaurantNom: params['restaurantNom'],
              restaurantImage: params['restaurantImage'],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FastEat Benin',
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
