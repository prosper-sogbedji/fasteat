import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../data/mock/mock_restaurants.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/restaurant_card.dart';

class FavorisScreen extends StatelessWidget {
  const FavorisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesProvider>();
    final favoris = mockRestaurants.where((r) => fav.isFavorite(r.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: favoris.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border_rounded, size: 56, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun favori pour le moment',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.grey.shade800),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Appuyez sur le cœur sur un restaurant à l’accueil pour l’ajouter ici.',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => context.go(AppRoutes.home),
                      child: const Text('Découvrir les restaurants'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
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
