import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/commandes_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/flow_provider.dart';
import 'providers/panier_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PanierProvider()),
        ChangeNotifierProvider(create: (_) => CommandesProvider()),
        ChangeNotifierProvider(create: (_) => FlowProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const FastEatApp(),
    ),
  );
}
