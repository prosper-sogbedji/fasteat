import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../models/restaurant.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/restaurants_provider.dart';
import '../../navigation/main_shell_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_feedback.dart';
import '../../widgets/common/image_fallback.dart';
import '../../widgets/common/skeleton_loader.dart';
import '../../widgets/common/offline_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Catégorie active pour les filtres de la section "À découvrir".
  String _categorieActive = 'Tous';

  static const _categories = ['Tous', 'Populaires', 'Mieux notés', 'Livraison', 'Nouveautés'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (!auth.isConnected) return;
      context.read<NotificationsProvider>().refresh();
      context.read<FavoritesProvider>().syncFromApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final catalog = context.watch<RestaurantsProvider>();
    final fav = context.watch<FavoritesProvider>();
    final unread = context.watch<NotificationsProvider>().unreadCount;

    final mesRestaurants = fav.favoriteRestaurants.isNotEmpty
        ? fav.favoriteRestaurants
        : catalog.restaurants.where((r) => fav.isFavorite(r.id)).toList();

    // Base : restaurants non-favoris
    var aDecouvrir = catalog.restaurants
        .where((r) => !fav.isFavorite(r.id))
        .toList();

    // Application du filtre actif
    switch (_categorieActive) {
      case 'Populaires':
        aDecouvrir.sort((a, b) => b.note.compareTo(a.note));
        break;
      case 'Mieux notés':
        aDecouvrir = aDecouvrir.where((r) => r.note >= 4.5).toList()
          ..sort((a, b) => b.note.compareTo(a.note));
        break;
      case 'Livraison':
        aDecouvrir = aDecouvrir.where((r) => r.livraison).toList();
        break;
      case 'Nouveautés':
        // TODO: remplacer par un tri sur createdAt dès que ce champ sera disponible côté API
        aDecouvrir = aDecouvrir.reversed.toList();
        break;
      default: // 'Tous'
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await catalog.loadRestaurants(force: true);
          if (auth.isConnected) await fav.syncFromApi();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            // ---- AppBar ----
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 1,
              toolbarHeight: 72,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push(AppRoutes.profil);
                    },
                    child: Container(
                      width: AppSizes.avatarMd,
                      height: AppSizes.avatarMd,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6F3F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          auth.isConnected ? auth.currentUser.initials : '?',
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Outfit'),
                            children: [
                              TextSpan(
                                text: _getGreetingMessage(),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              if (auth.isConnected && auth.currentUser.nom.isNotEmpty)
                                TextSpan(
                                  text: ', ${auth.currentUser.nom.split(' ').first}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary),
                                ),
                              const TextSpan(text: ' 👋', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Row(
                          children: [
                            Icon(Icons.location_on_rounded, size: 12, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'Cotonou, Bénin',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.push(AppRoutes.notifications);
                    },
                    icon: Badge(
                      isLabelVisible: unread > 0,
                      label: Text('$unread'),
                      child: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),

            // ---- Erreur réseau ----
            if (catalog.lastError != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 0),
                  child: OfflineBanner(message: catalog.lastError!),
                ),
              ),

            // ---- Section : Mes restaurants (masquée si aucun favori) ----
            if (mesRestaurants.isNotEmpty || (catalog.isLoading && catalog.restaurants.isEmpty)) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mes restaurants',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Vos établissements enregistrés',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.mesRestaurants),
                        child: const Text('Voir tout', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenu : skeleton ou scroll horizontal
              if (catalog.isLoading && catalog.restaurants.isEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: AppSizes.cardImageSm,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, 8),
                      itemCount: 3,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (_, _) => const Skeleton(width: 140, height: AppSizes.cardImageSm, borderRadius: AppRadius.lg),
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: AppSizes.cardImageSm,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, 8),
                      itemCount: mesRestaurants.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (_, i) {
                        final r = mesRestaurants[i];
                        return _MesRestaurantCard(restaurant: r, fav: fav);
                      },
                    ),
                  ),
                ),
            ],

            // ---- Divider (uniquement si "Mes restaurants" est affiché) ----
            if (mesRestaurants.isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.xl, 16, AppSpacing.xl, 0),
                  child: Divider(),
                ),
              ),

            // ---- Section : À découvrir ----
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  mesRestaurants.isNotEmpty ? 20 : AppSpacing.xxl,
                  AppSpacing.xl,
                  12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'À découvrir',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Nouveaux établissements près de vous',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => goMainTab(context, AppRoutes.recherche),
                      child: const Text('Voir tout', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
            
            // ---- Filtres (Chips) fonctionnels ----
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemCount: _categories.length,
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    return _FilterChip(
                      label: cat,
                      isSelected: _categorieActive == cat,
                      onTap: () => setState(() => _categorieActive = cat),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Contenu "À découvrir"
            if (catalog.isLoading && catalog.restaurants.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.navClearance),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => const Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: Skeleton(height: 250, borderRadius: AppRadius.xl),
                    ),
                    childCount: 3,
                  ),
                ),
              )
            else if (aDecouvrir.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, 40),
                  child: EmptyState(
                    title: 'Aucun restaurant disponible',
                    subtitle: 'Revenez plus tard ou actualisez la page.',
                    actionLabel: 'Actualiser',
                    onAction: () => catalog.loadRestaurants(force: true),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.navClearance),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final r = aDecouvrir[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ADecouvrirCard(restaurant: r, fav: fav),
                      );
                    },
                    childCount: aDecouvrir.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }
}


// ---- Widget : Carte "Mes restaurants" (scroll horizontal) ----
class _MesRestaurantCard extends StatelessWidget {
  const _MesRestaurantCard({required this.restaurant, required this.fav});
  final Restaurant restaurant;
  final FavoritesProvider fav;

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('${AppRoutes.restaurant}/${r.id}');
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ImageFallback(path: r.image, label: r.nom, radius: 0),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () async {
                          HapticFeedback.mediumImpact();
                          await context.read<FavoritesProvider>().toggle(r.id, restaurant: r);
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            fav.isFavorite(r.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 15,
                            color: fav.isFavorite(r.id) ? const Color(0xFFE63946) : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 11, color: AppColors.accent),
                      const SizedBox(width: 2),
                      Text(
                        '${r.note}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.access_time_rounded, size: 11, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          r.tempsEstime,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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

// ---- Widget : Carte "À découvrir" (liste verticale) ----
class _ADecouvrirCard extends StatelessWidget {
  const _ADecouvrirCard({required this.restaurant, required this.fav});
  final Restaurant restaurant;
  final FavoritesProvider fav;

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    final isFav = fav.isFavorite(r.id);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('${AppRoutes.restaurant}/${r.id}');
      },
      child: Container(
        height: AppSizes.cardImageLg,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ImageFallback(path: r.image, label: r.nom, radius: 0),
                    // Note badge
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 13, color: AppColors.accent),
                            const SizedBox(width: 3),
                            Text('${r.note}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    // Bouton Ajouter à mes restaurants
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () async {
                          HapticFeedback.mediumImpact();
                          final ok = await context.read<FavoritesProvider>().toggle(r.id, restaurant: r);
                          if (!context.mounted || ok) return;
                          final msg = context.read<FavoritesProvider>().lastError;
                          AppFeedback.error(context, msg ?? 'Impossible de mettre à jour.');
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isFav ? AppColors.primary : Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isFav ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
                                size: 14,
                                color: isFav ? Colors.white : AppColors.textPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isFav ? 'Enregistré' : '+ Mes restaurants',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isFav ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Temps estimé
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          r.tempsEstime,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                        ),
                      ),
                    ),
                    // Badge certifié
                    if (r.certifie)
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified, size: 11, color: Colors.white),
                              SizedBox(width: 3),
                              Text('CERTIFIÉ', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.nom,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${r.cuisine} • ${r.quartier}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
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

// ---- Widget : Pilule de Filtre (Chip) ----
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
