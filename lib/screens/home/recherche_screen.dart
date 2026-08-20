import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../models/restaurant.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/restaurants_provider.dart';
import '../../navigation/main_shell_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/image_fallback.dart';

class RechercheScreen extends StatefulWidget {
  const RechercheScreen({super.key});

  @override
  State<RechercheScreen> createState() => _RechercheScreenState();
}

class _RechercheScreenState extends State<RechercheScreen> {
  final _controller = TextEditingController();
  final _filtres = const [
    'Tous',
    'Localisation',
    'Cuisine',
    'Notes',
    'Livraison gratuite',
  ];
  final _locations = const [
    'Tous',
    'Haie Vive',
    'Ganhi',
    'Cadjehoun',
    'Akpakpa',
    'Calavi',
  ];
  final _cuisines = const [
    'Toutes',
    'Beninoise',
    'Africaine',
    'Fast-food',
    'Ivoirienne',
  ];
  String _filtre = 'Tous';
  String _selectedLocation = 'Tous';
  String _selectedCuisine = 'Toutes';
  bool _filtresOuverts = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Restaurant> _filtered(List<Restaurant> source) {
    List<Restaurant> results = List.of(source);
    final q = _controller.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      results = results
          .where(
            (r) =>
                r.nom.toLowerCase().contains(q) ||
                r.cuisine.toLowerCase().contains(q),
          )
          .toList();
    }
    if (_filtre == 'Livraison gratuite') {
      results = results.where((r) => r.livraison).toList();
    } else if (_filtre == 'Notes') {
      results = results.where((r) => r.note >= 4.5).toList();
    }
    if (_filtre == 'Localisation' && _selectedLocation != 'Tous') {
      results = results
          .where(
            (r) => r.quartier.toLowerCase().contains(
              _selectedLocation.toLowerCase(),
            ),
          )
          .toList();
    }
    if (_filtre == 'Cuisine' && _selectedCuisine != 'Toutes') {
      results = results
          .where(
            (r) => r.cuisine.toLowerCase().contains(
              _selectedCuisine.toLowerCase(),
            ),
          )
          .toList();
    }
    return results;
  }

  Future<void> _openFiltresOptionnels() async {
    var f = _filtre;
    var loc = _selectedLocation;
    var cui = _selectedCuisine;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: 20 + MediaQuery.of(ctx).viewPadding.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Filtres optionnels',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Affinez la liste si besoin. Vous pouvez chercher sans appliquer de filtre.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _filtres.map((name) {
                        final sel = f == name;
                        return FilterChip(
                          selected: sel,
                          label: Text(
                            name,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onSelected: (_) => setModal(() => f = name),
                          selectedColor: AppColors.textPrimary,
                          backgroundColor: AppColors.chipBackground,
                          labelStyle: TextStyle(
                            color: sel ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                    if (f == 'Localisation') ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: loc,
                        items: _locations
                            .map(
                              (l) => DropdownMenuItem(value: l, child: Text(l)),
                            )
                            .toList(),
                        onChanged: (v) => setModal(() => loc = v ?? 'Tous'),
                        decoration: const InputDecoration(
                          labelText: 'Quartier',
                        ),
                      ),
                    ],
                    if (f == 'Cuisine') ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: cui,
                        items: _cuisines
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (v) => setModal(() => cui = v ?? 'Toutes'),
                        decoration: const InputDecoration(
                          labelText: 'Type de cuisine',
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModal(() {
                                f = 'Tous';
                                loc = 'Tous';
                                cui = 'Toutes';
                              });
                            },
                            child: const Text('Réinitialiser'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _filtre = f;
                                _selectedLocation = loc;
                                _selectedCuisine = cui;
                                _filtresOuverts = true;
                              });
                              Navigator.pop(ctx);
                            },
                            child: const Text('Appliquer'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final source = context.watch<RestaurantsProvider>().restaurants;
    final results = _filtered(source);
    final topInset = MediaQuery.of(context).padding.top;
    final filtresActifs = _filtresOuverts && _filtre != 'Tous';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _RechercheHeaderDelegate(
              topInset: topInset,
              searchController: _controller,
              onSearchChanged: (_) => setState(() {}),
              resultsCount: results.length,
              filtresActifs: filtresActifs,
              onBack: () => goMainTab(context, AppRoutes.home),
              onOpenFilters: _openFiltresOptionnels,
              onVoirTout: () {
                setState(() {
                  _filtre = 'Tous';
                  _controller.clear();
                  _selectedLocation = 'Tous';
                  _selectedCuisine = 'Toutes';
                  _filtresOuverts = false;
                });
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.xl, 4, AppSpacing.xl, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Résultats de recherche',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          if (results.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Aucun restaurant trouvé')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.navClearance,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final r = results[i];
                  final fav = context.watch<FavoritesProvider>();
                  final isFav = fav.isFavorite(r.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: InkWell(
                      onTap: () =>
                          context.push('${AppRoutes.restaurant}/${r.id}'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 138,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ImageFallback(
                                      path: r.image,
                                      label: r.nom,
                                      radius: 0,
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () async {
                                          HapticFeedback.mediumImpact();
                                          await context
                                              .read<FavoritesProvider>()
                                              .toggle(r.id, restaurant: r);
                                        },
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.1,
                                                ),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            isFav
                                                ? Icons.favorite_rounded
                                                : Icons.favorite_border_rounded,
                                            size: 18,
                                            color: isFav
                                                ? const Color(0xFFE63946)
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.nom,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        r.cuisine,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 13,
                                      color: AppColors.accent,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${r.note}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }, childCount: results.length),
              ),
            ),
        ],
      ),
    );
  }
}

/// En-tête recherche épinglé : se compresse quand l’utilisateur fait défiler la liste.
class _RechercheHeaderDelegate extends SliverPersistentHeaderDelegate {
  _RechercheHeaderDelegate({
    required this.topInset,
    required this.searchController,
    required this.onSearchChanged,
    required this.resultsCount,
    required this.filtresActifs,
    required this.onBack,
    required this.onOpenFilters,
    required this.onVoirTout,
  });

  final double topInset;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final int resultsCount;
  final bool filtresActifs;
  final VoidCallback onBack;
  final Future<void> Function() onOpenFilters;
  final VoidCallback onVoirTout;

  static const double _maxExtent = 175;
  static const double _minExtent = 155;

  @override
  double get maxExtent => _maxExtent + topInset;

  @override
  double get minExtent => _minExtent + topInset;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final h = (maxExtent - shrinkOffset).clamp(minExtent, maxExtent);
    final range = maxExtent - minExtent;
    final t = range <= 0 ? 0.0 : ((maxExtent - h) / range).clamp(0.0, 1.0);
    final titleSize = lerpDouble(22, 17, t)!;
    final blockPadV = lerpDouble(10, 4, t)!;
    final searchVert = lerpDouble(14, 10, t)!;
    final betweenSearchAndRow = lerpDouble(10, 6, t)!;

    return Material(
      color: Colors.white,
      elevation: overlapsContent || t > 0.05 ? 1.5 : 0,
      shadowColor: Colors.black26,
      child: SizedBox(
        height: h,
        child: Padding(
          padding: EdgeInsets.only(top: topInset, left: 8, right: 8, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: blockPadV),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Recherche',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  style: TextStyle(fontSize: lerpDouble(15, 14, t)),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un plat ou restaurant...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.inputFill,
                    contentPadding: EdgeInsets.symmetric(vertical: searchVert),
                    isDense: t > 0.5,
                  ),
                ),
              ),
              SizedBox(height: betweenSearchAndRow),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Text(
                      '$resultsCount résultat${resultsCount > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: lerpDouble(13, 12, t),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: onOpenFilters,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: lerpDouble(8, 4, t)!,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(
                        Icons.tune_rounded,
                        size: lerpDouble(20, 18, t)!,
                        color: filtresActifs ? AppColors.primary : null,
                      ),
                      label: const Text('Filtres'),
                    ),
                    TextButton(
                      onPressed: onVoirTout,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: lerpDouble(8, 4, t)!,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _RechercheHeaderDelegate oldDelegate) {
    return oldDelegate.resultsCount != resultsCount ||
        oldDelegate.filtresActifs != filtresActifs ||
        oldDelegate.topInset != topInset;
  }
}
