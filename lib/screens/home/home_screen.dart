import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../data/mock/mock_restaurants.dart';
import '../../models/commande.dart';
import '../../models/restaurant.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/flow_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/image_fallback.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<FlowProvider>();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on_rounded, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Votre position', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      SizedBox(height: 2),
                      Text(
                        'Haie Vive, Cotonou',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.push(AppRoutes.notifications),
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              readOnly: true,
              onTap: () => context.push(AppRoutes.recherche),
              decoration: const InputDecoration(
                hintText: 'Rechercher un restaurant ou un plat',
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.tune_rounded),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _modeChip(
                    context,
                    selected: flow.modeCommande == ModeCommande.programmee,
                    icon: Icons.schedule_rounded,
                    label: 'Programmee',
                    onTap: () => context.read<FlowProvider>().setMode(ModeCommande.programmee),
                  ),
                  const SizedBox(width: 10),
                  _modeChip(
                    context,
                    selected: flow.modeCommande == ModeCommande.livraison,
                    icon: Icons.delivery_dining_rounded,
                    label: 'Livraison',
                    onTap: () => context.read<FlowProvider>().setMode(ModeCommande.livraison),
                  ),
                  const SizedBox(width: 10),
                  _modeChip(
                    context,
                    selected: flow.modeCommande == ModeCommande.qrCode,
                    icon: Icons.table_restaurant_rounded,
                    label: 'Sur place',
                    onTap: () => context.read<FlowProvider>().setMode(ModeCommande.qrCode),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Restaurants proches',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton(onPressed: () => context.push(AppRoutes.recherche), child: const Text('Voir tout')),
              ],
            ),
            const Text(
              'Sélection de la semaine',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: mockRestaurants.length,
              itemBuilder: (context, index) {
                final r = mockRestaurants[index];
                return _HomeRestaurantTile(restaurant: r);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: FastEatBottomNavBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) context.go(AppRoutes.favoris);
          if (i == 2) context.go(AppRoutes.historique);
          if (i == 3) context.go(AppRoutes.profil);
        },
      ),
    );
  }

  Widget _modeChip(
    BuildContext context, {
    required bool selected,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF4F4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary.withValues(alpha: 0.24) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: selected ? const Color(0xFF0B6E6E) : Colors.black54),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFF0B6E6E) : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeRestaurantTile extends StatefulWidget {
  const _HomeRestaurantTile({required this.restaurant});

  final Restaurant restaurant;

  @override
  State<_HomeRestaurantTile> createState() => _HomeRestaurantTileState();
}

class _HomeRestaurantTileState extends State<_HomeRestaurantTile> {
  late final PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    final imgs = r.images.isNotEmpty ? r.images : [r.image];
    final fav = context.watch<FavoritesProvider>();

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('${AppRoutes.restaurant}/${r.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 108,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _pageIndex = i),
                      itemCount: imgs.length,
                      itemBuilder: (context, i) {
                        return ImageFallback(
                          path: imgs[i],
                          label: r.nom,
                          height: 108,
                          radius: 0,
                        );
                      },
                    ),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.94),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => context.read<FavoritesProvider>().toggle(r.id),
                          customBorder: const CircleBorder(),
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: Icon(
                              fav.isFavorite(r.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 20,
                              color: fav.isFavorite(r.id) ? const Color(0xFFE63946) : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (imgs.length > 1)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            imgs.length,
                            (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _pageIndex == i ? Colors.white : Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    r.quartier,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text('${r.note}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      const Spacer(),
                      Text(r.tempsEstime, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
