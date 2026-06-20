import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/api/auth_service.dart';
import 'theme/app_theme.dart';
import 'providers/restaurant_menu_provider.dart';
import 'providers/restaurant_dashboard_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/dashboard_restaurant/dashboard_restaurant_screen.dart';
import 'screens/dashboard_restaurant/plat_wizard/creer_plat_wizard_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/dashboard_admin/dashboard_admin_screen.dart';
import 'screens/dashboard_restaurant/create_restaurant_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static bool _isPublicRoute(String location) {
    return location == '/splash' ||
        location == '/onboarding' ||
        location == '/login' ||
        location == '/signup';
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) async {
        final location = state.matchedLocation;
        if (_isPublicRoute(location)) return null;

        final session = await AuthService.getCurrentSession();
        final token = session['jwt_token'];
        final role = session['user_role'];

        if (token == null || token.isEmpty) {
          return '/login';
        }

        if (location.startsWith('/admin') && role != 'super_admin') {
          return '/';
        }

        if (location == '/' && role == 'super_admin') {
          return '/admin';
        }

        // Si propriétaire de resto mais pas de resto -> obliger à créer
        final restoId = session['restaurant_id'];
        if (role != 'super_admin' && (restoId == null || restoId.toString().isEmpty) && location != '/create-restaurant') {
          return '/create-restaurant';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardRestaurantScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const DashboardAdminScreen(),
        ),
        GoRoute(
          path: '/create-restaurant',
          builder: (context, state) => const CreateRestaurantScreen(),
        ),
        GoRoute(
          path: '/plat-nouveau',
          builder: (context, state) {
            final rid = state.uri.queryParameters['rid'] ?? 'r1';
            final platId = state.uri.queryParameters['platId'];
            return CreerPlatWizardScreen(restaurantId: rid, platId: platId);
          },
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RestaurantMenuProvider()),
        ChangeNotifierProvider(
          create: (_) => RestaurantDashboardProvider()
            ..loadHours()
            ..loadPromotions()
            ..loadAnalytics()
            ..loadConversations(),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminProvider()..loadAll(),
        ),
      ],
      child: MaterialApp.router(
        title: 'FastEat Pro Dashboard',
        theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.outfitTextTheme(),
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
          ),
        ),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
