import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock/mock_plats.dart';
import '../../data/mock/mock_restaurants.dart';
import '../../models/commande.dart';
import '../../models/plat.dart';
import '../../providers/flow_provider.dart';
import '../../providers/panier_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/badge_certifie.dart';
import '../../widgets/common/formatters.dart';
import '../../widgets/common/image_fallback.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key, required this.restaurantId});

  final String restaurantId;

  @override
  Widget build(BuildContext context) {
    final restaurant = mockRestaurants.firstWhere((r) => r.id == restaurantId, orElse: () => mockRestaurants.first);
    final plats = mockPlats.where((p) => p.restoId == restaurant.id).toList();
    final panier = context.watch<PanierProvider>();
    final total = panier.sousTotal;

    final categories = ['Entrees', 'Plats', 'Desserts', 'Boissons', 'Accompagnements'];
    final entrees = plats.where((p) => p.categorie == 'Entrees').toList();
    final platsPrincipaux = plats.where((p) => p.categorie == 'Plats').toList();
    final boissons = plats.where((p) => p.categorie == 'Boissons').toList();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 230,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ImageFallback(path: restaurant.image, label: restaurant.nom, radius: 0, height: 230),
                  Positioned(
                    left: 16,
                    bottom: 14,
                    child: restaurant.certifie ? const BadgeCertifie() : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.nom, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text('${restaurant.cuisine} • ${restaurant.quartier}', style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.primary, size: 18),
                      Text(' ${restaurant.note} • ${restaurant.avis} avis'),
                      const Spacer(),
                      const Icon(Icons.access_time_rounded, size: 16),
                      Text(' ${restaurant.tempsEstime}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.delivery_dining_rounded, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      const Text('Livraison'),
                      const SizedBox(width: 12),
                      const Icon(Icons.restaurant_menu_rounded, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      const Text('Restaurant'),
                      const SizedBox(width: 12),
                      const Icon(Icons.qr_code_rounded, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      const Text('Sur place'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, i) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: i == 0 ? const Color(0xFFFCE8EC) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          categories[i],
                          style: TextStyle(
                            color: i == 0 ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      separatorBuilder: (context, i) => const SizedBox(width: 8),
                      itemCount: categories.length,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          _sectionTitle('Entrees Populaires'),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final p = (entrees.isNotEmpty ? entrees : platsPrincipaux)[i];
                return _menuItem(context, p);
              },
              childCount: (entrees.isNotEmpty ? entrees : platsPrincipaux).length,
            ),
          ),
          _sectionTitle('Plats de Resistance'),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _menuItem(context, platsPrincipaux[i]),
              childCount: platsPrincipaux.length,
            ),
          ),
          _sectionTitle('Boissons'),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _menuItem(context, boissons[i]),
              childCount: boissons.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: panier.totalArticles == 0
          ? null
          : SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  context.push('/panier');
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text('Voir panier   ${fcfa(total)}'),
              ),
            ),
    );
  }

  SliverToBoxAdapter _sectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _menuItem(BuildContext context, Plat p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.push('/plat/${p.id}'),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
            color: Colors.white,
          ),
          child: Row(
            children: [
              ImageFallback(path: p.image, label: p.nom, width: 62, height: 62, radius: 10),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.nom, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(p.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(fcfa(p.prix), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 15,
                  onPressed: () async {
                    final panier = context.read<PanierProvider>();
                    try {
                      await panier.ajouterPlat(p);
                    } on CrossRestaurantException catch (_) {
                      if (context.mounted) {
                        _showCrossRestaurantDialog(context, panier, p);
                      }
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCrossRestaurantDialog(BuildContext context, PanierProvider panier, Plat plat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vider le panier ?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Vous avez déjà des articles d\'un autre restaurant. Voulez-vous vider votre panier actuel pour commander ici ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await panier.vider();
              await panier.ajouterPlat(plat);
            },
            child: const Text('Vider et Ajouter'),
          ),
        ],
      ),
    );
  }
}
