import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:fast_eat/app.dart';
import 'package:fast_eat/data/api/auth_service.dart';
import 'package:fast_eat/data/repositories/restaurants_repository.dart';
import 'package:fast_eat/providers/auth_provider.dart';
import 'package:fast_eat/providers/commandes_provider.dart';
import 'package:fast_eat/providers/favorites_provider.dart';
import 'package:fast_eat/providers/flow_provider.dart';
import 'package:fast_eat/providers/notifications_provider.dart';
import 'package:fast_eat/providers/panier_provider.dart';
import 'package:fast_eat/providers/restaurants_provider.dart';

class _TestAuthService extends AuthService {
  @override
  Future<String?> getToken() async => null;
}

void main() {
  testWidgets('FastEat app launches', (WidgetTester tester) async {
    final authService = _TestAuthService();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider(authService: authService)),
          ChangeNotifierProvider(create: (_) => RestaurantsProvider(repository: DemoRestaurantsRepository())),
          ChangeNotifierProvider(create: (_) => PanierProvider(authService: authService)),
          ChangeNotifierProvider(create: (_) => CommandesProvider(authService: authService)),
          ChangeNotifierProvider(create: (_) => FavoritesProvider(authService: authService)),
          ChangeNotifierProvider(create: (_) => NotificationsProvider(authService: authService)),
          ChangeNotifierProvider(create: (_) => FlowProvider()),
        ],
        child: const FastEatApp(),
      ),
    );
    expect(find.byType(FastEatApp), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
  });
}
