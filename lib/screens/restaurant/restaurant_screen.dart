import '../../widgets/reservation/reservation_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock/mock_plats.dart';
import '../../data/mock/mock_restaurants.dart';
import '../../models/plat.dart';
import '../../providers/panier_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/badge_certifie.dart';
import '../../widgets/common/formatters.dart';
import '../../widgets/common/image_fallback.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key, required this.restaurantId});
  final String restaurantId;

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late TabController _tabController;
  String _selectedCategory = 'Tous';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = mockRestaurants.firstWhere(
      (r) => r.id == widget.restaurantId,
      orElse: () => mockRestaurants.first,
    );
    final allPlats =
        mockPlats.where((p) => p.restoId == restaurant.id).toList();
    final categories = [
      'Tous',
      ...{for (final p in allPlats) p.categorie},
    ];

    if (_tabController.length != categories.length) {
      _tabController.dispose();
      _tabController =
          TabController(length: categories.length, vsync: this);
      _tabController.addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(
              () => _selectedCategory = categories[_tabController.index]);
        }
      });
    }

    final filteredPlats = _selectedCategory == 'Tous'
        ? allPlats
        : allPlats
            .where((p) => p.categorie == _selectedCategory)
            .toList();

    final panier = context.watch<PanierProvider>();
    final total = panier.sousTotal;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── AppBar avec image hero ─────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: isTablet ? 280 : 220,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.black87, size: 16),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Ajouté aux favoris !'),
                          behavior: SnackBarBehavior.floating),
                    );
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2))
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.favorite_border_rounded,
                        color: Colors.black87, size: 18),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ImageFallback(
                    path: restaurant.image,
                    label: restaurant.nom,
                    radius: 0,
                    height: isTablet ? 280 : 220,
                  ),
                  // Gradient overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black38,
                        ],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                  if (restaurant.certifie)
                    Positioned(
                      left: 16,
                      bottom: 14,
                      child: const BadgeCertifie(),
                    ),
                ],
              ),
            ),
          ),

          // ── Infos restaurant ──────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom
                  Text(
                    restaurant.nom,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: isTablet ? 24 : 20,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${restaurant.cuisine} · ${restaurant.quartier}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: isTablet ? 14 : 13,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Stats row
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      _statChip(
                        Icons.star_rounded,
                        '${restaurant.note}',
                        '(${restaurant.avis} avis)',
                        Colors.amber.shade600,
                      ),
                      _statChip(
                        Icons.access_time_rounded,
                        restaurant.tempsEstime,
                        'Temps estimé',
                        AppColors.primary,
                      ),
                      if (restaurant.livraison)
                        _statChip(
                          Icons.delivery_dining_rounded,
                          'Livraison',
                          'Disponible',
                          Colors.green.shade600,
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Boutons actions
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              _scrollController.animateTo(
                                400,
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                              );
                            },
                            icon: const Icon(Icons.restaurant_menu_rounded,
                                size: 16),
                            label: const Text('Commander',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                  color: AppColors.primary, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              showReservationBottomSheet(
                                context,
                                restaurantId: restaurant.id,
                                restaurantNom: restaurant.nom,
                                restaurantImage: restaurant.image,
                              ).then((res) {
                                if (!context.mounted) return;
                                if (res != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          '✓ Réservation confirmée !'),
                                      backgroundColor:
                                          Colors.green.shade700,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  );
                                }
                              });
                            },
                            icon: const Icon(
                                Icons.table_restaurant_rounded,
                                size: 16),
                            label: const Text('Réserver',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // ── Onglets catégories ────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _CategoryTabDelegate(
              categories: categories,
              tabController: _tabController,
            ),
          ),

          // ── Titre section & nombre de résultats ──────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
              child: Row(
                children: [
                  Text(
                    _selectedCategory == 'Tous'
                        ? 'Tous les plats'
                        : _selectedCategory,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.black87),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${filteredPlats.length}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Liste des plats ───────────────────────────────────
          filteredPlats.isEmpty
              ? const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Aucun plat disponible\ndans cette catégorie.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : isTablet
                  ? SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) =>
                              _PlatCard(plat: filteredPlats[i], tablet: true),
                          childCount: filteredPlats.length,
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _PlatCard(plat: filteredPlats[i]),
                          ),
                          childCount: filteredPlats.length,
                        ),
                      ),
                    ),
        ],
      ),

      // ── FAB panier ────────────────────────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: panier.totalArticles == 0
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.35),
                  ),
                  onPressed: () => context.push('/panier'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${panier.totalArticles}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: Colors.white),
                        ),
                      ),
                      const Text('Voir mon panier',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                      Text(fcfa(total),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _statChip(
      IconData icon, String value, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: Colors.black87)),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ],
    );
  }
}


// ─── Delegate pour les onglets épinglés ───────────────────────────────────────
class _CategoryTabDelegate extends SliverPersistentHeaderDelegate {
  const _CategoryTabDelegate({
    required this.categories,
    required this.tabController,
  });

  final List<String> categories;
  final TabController tabController;

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey.shade500,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: categories.map((c) => Tab(text: c)).toList(),
      ),
    );
  }

  @override
  bool shouldRebuild(_CategoryTabDelegate oldDelegate) =>
      oldDelegate.categories != categories;
}

// ─── Carte de plat ─────────────────────────────────────────────────────────────
class _PlatCard extends StatelessWidget {
  const _PlatCard({required this.plat, this.tablet = false});
  final Plat plat;
  final bool tablet;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/plat/${plat.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ImageFallback(
                path: plat.image,
                label: plat.nom,
                width: tablet ? 70 : 80,
                height: tablet ? 70 : 80,
                radius: 10,
              ),
            ),
            const SizedBox(width: 12),
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plat.nom,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    plat.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        fcfa(plat.prix),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            fontSize: 14),
                      ),
                      const Spacer(),
                      _AddButton(plat: plat),
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

// ─── Bouton + avec état animé ─────────────────────────────────────────────────
class _AddButton extends StatelessWidget {
  const _AddButton({required this.plat});
  final Plat plat;

  @override
  Widget build(BuildContext context) {
    final panier = context.watch<PanierProvider>();
    final qteInPanier = panier.lignes
        .where((l) => l.plat.id == plat.id)
        .fold(0, (sum, l) => sum + l.quantite);

    if (qteInPanier > 0) {
      // Afficher le stepper compact
      return Container(
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 14,
                onPressed: () => context.read<PanierProvider>().changerQuantite(plat.id, qteInPanier - 1),
                icon: const Icon(Icons.remove, color: Colors.white),
              ),
            ),
            Text(
              '$qteInPanier',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13),
            ),
            SizedBox(
              width: 28,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 14,
                onPressed: () async {
                  try {
                    await context.read<PanierProvider>().ajouterPlat(plat);
                  } on CrossRestaurantException catch (_) {
                    // géré via tap sur la carte
                  }
                },
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final p = context.read<PanierProvider>();
        try {
          await p.ajouterPlat(plat);
        } on CrossRestaurantException catch (_) {
          if (context.mounted) {
            // Ouvrir dialog via la carte parente
            context.push('/plat/${plat.id}');
          }
        }
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 17),
      ),
    );
  }
}
