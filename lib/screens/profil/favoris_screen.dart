import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../models/restaurant.dart';
import '../../providers/restaurants_provider.dart';
import '../../widgets/common/offline_banner.dart';
import '../../widgets/common/restaurant_card.dart';

class FavorisScreen extends StatefulWidget {
  const FavorisScreen({super.key});

  @override
  State<FavorisScreen> createState() => _FavorisScreenState();
}

class _FavorisScreenState extends State<FavorisScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().syncFromApi();
    });
  }

  List<Restaurant> _resolveList(FavoritesProvider fav, RestaurantsProvider catalog) {
    if (fav.favoriteRestaurants.isNotEmpty) return fav.favoriteRestaurants;
    return catalog.restaurants.where((r) => fav.isFavorite(r.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fav = context.watch<FavoritesProvider>();
    final catalog = context.watch<RestaurantsProvider>();
    final favoris = _resolveList(fav, catalog);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: !auth.isConnected
          ? const EmptyState(
              title: 'Connexion requise',
              subtitle: 'Connectez-vous pour synchroniser vos restaurants favoris.',
              icon: Icons.favorite_border_rounded,
            )
          : fav.isLoading && favoris.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : favoris.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const EmptyState(
                              title: 'Aucun favori',
                              subtitle: 'Appuyez sur le cœur sur un restaurant à l\'accueil.',
                              icon: Icons.favorite_border_rounded,
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () => context.go(AppRoutes.home),
                              child: const Text('Découvrir les restaurants'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => fav.syncFromApi(),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: favoris.length,
                        itemBuilder: (_, i) {
                          final r = favoris[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: RestaurantCard(
                              restaurant: r,
                              onTap: () => context.push('${AppRoutes.restaurant}/${r.id}'),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
