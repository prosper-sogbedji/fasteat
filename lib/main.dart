import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/api/auth_service.dart';
import 'providers/auth_provider.dart';
import 'providers/commandes_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/flow_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/panier_provider.dart';
import 'providers/reservations_provider.dart';
import 'providers/restaurants_provider.dart';
import 'providers/adresses_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: authService),
        ),
        ChangeNotifierProvider(create: (_) => RestaurantsProvider()),
        ChangeNotifierProxyProvider<RestaurantsProvider, PanierProvider>(
          create: (_) => PanierProvider(authService: authService),
          update: (_, restaurants, panier) => panier!..updateRestaurants(restaurants),
        ),
        ChangeNotifierProvider(
          create: (_) => CommandesProvider(authService: authService),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(authService: authService),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationsProvider(authService: authService),
        ),
        ChangeNotifierProvider(
          create: (_) => ReservationsProvider(authService: authService),
        ),
        ChangeNotifierProvider(
          create: (_) => AdressesProvider(),
        ),
        ChangeNotifierProvider(create: (_) => FlowProvider()),
      ],
      child: const FastEatApp(),
    ),
  );
}
