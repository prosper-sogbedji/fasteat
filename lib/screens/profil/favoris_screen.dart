import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_routes.dart';
import '../../data/mock/mock_restaurants.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/restaurant_card.dart';

class FavorisScreen extends StatelessWidget {
  const FavorisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoris = mockRestaurants.take(3).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favoris.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RestaurantCard(
            restaurant: favoris[i],
            onTap: () => context.push('${AppRoutes.restaurant}/${favoris[i].id}'),
          ),
        ),
      ),
      bottomNavigationBar: FastEatBottomNavBar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) context.go(AppRoutes.home);
          if (i == 2) context.go(AppRoutes.historique);
          if (i == 3) context.go(AppRoutes.profil);
        },
      ),
    );
  }
}
