import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_routes.dart';
import '../../data/mock/mock_restaurants.dart';
import '../../models/restaurant.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/formatters.dart';
import '../../widgets/common/image_fallback.dart';

class RechercheScreen extends StatefulWidget {
  const RechercheScreen({super.key});

  @override
  State<RechercheScreen> createState() => _RechercheScreenState();
}

class _RechercheScreenState extends State<RechercheScreen> {
  final _controller = TextEditingController();
  final _filtres = const ['Tous', 'Localisation', 'Cuisine', 'Notes', 'Livraison gratuite'];
  final _locations = const ['Tous', 'Haie Vive', 'Ganhi', 'Cadjehoun', 'Akpakpa', 'Calavi'];
  final _cuisines = const ['Toutes', 'Beninoise', 'Africaine', 'Fast-food', 'Ivoirienne'];
  String _filtre = 'Tous';
  String _selectedLocation = 'Tous';
  String _selectedCuisine = 'Toutes';
  bool _filtresOuverts = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Restaurant> _filtered() {
    List<Restaurant> results = List.of(mockRestaurants);
    final q = _controller.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      results = results.where((r) => r.nom.toLowerCase().contains(q) || r.cuisine.toLowerCase().contains(q)).toList();
    }
    if (_filtre == 'Livraison gratuite') {
      results = results.where((r) => r.livraison).toList();
    } else if (_filtre == 'Notes') {
      results = results.where((r) => r.note >= 4.5).toList();
    }
    if (_selectedLocation != 'Tous') {
      results = results.where((r) => r.quartier.toLowerCase().contains(_selectedLocation.toLowerCase())).toList();
    }
    if (_selectedCuisine != 'Toutes') {
      results = results.where((r) => r.cuisine.toLowerCase().contains(_selectedCuisine.toLowerCase())).toList();
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
                    const Text('Filtres optionnels', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text(
                      'Affinez la liste si besoin. Vous pouvez chercher sans appliquer de filtre.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _filtres.map((name) {
                        final sel = f == name;
                        return FilterChip(
                          selected: sel,
                          label: Text(name, style: const TextStyle(fontSize: 12)),
                          onSelected: (_) => setModal(() => f = name),
                          selectedColor: const Color(0xFF1F2937),
                          backgroundColor: const Color(0xFFF3F4F6),
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
                        items: _locations.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                        onChanged: (v) => setModal(() => loc = v ?? 'Tous'),
                        decoration: const InputDecoration(labelText: 'Quartier'),
                      ),
                    ],
                    if (f == 'Cuisine') ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: cui,
                        items: _cuisines.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setModal(() => cui = v ?? 'Toutes'),
                        decoration: const InputDecoration(labelText: 'Type de cuisine'),
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
                            child: const Text('Reinitialiser'),
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
    final results = _filtered();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.home),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'Recherche',
                      style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
              child: TextField(
                controller: _controller,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Rechercher un plat ou restaurant...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Text('${results.length} résultats', style: const TextStyle(color: AppColors.textSecondary)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _openFiltresOptionnels,
                    icon: Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: _filtresOuverts && _filtre != 'Tous' ? AppColors.primary : null,
                    ),
                    label: const Text('Filtres'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filtre = 'Tous';
                        _controller.clear();
                        _selectedLocation = 'Tous';
                        _selectedCuisine = 'Toutes';
                        _filtresOuverts = false;
                      });
                    },
                    child: const Text('Voir tout'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Resultats de recherche', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('Aucun restaurant trouve'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                      itemCount: results.length,
                      itemBuilder: (context, i) {
                        final r = results[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: InkWell(
                            onTap: () => context.push('${AppRoutes.restaurant}/${r.id}'),
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
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: ImageFallback(path: r.image, label: r.nom, height: 138, radius: 0),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(child: Text(r.nom, style: const TextStyle(fontWeight: FontWeight.w700))),
                                      Text(fcfa(i == 0 ? 2500 : 3000), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(r.cuisine, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  const SizedBox(height: 8),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size.fromHeight(42),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => context.push('${AppRoutes.restaurant}/${r.id}'),
                                    child: Text(i == 0 ? 'Commander Maintenant' : 'Voir le Menu'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FastEatBottomNavBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) context.go(AppRoutes.home);
          if (i == 1) context.go(AppRoutes.favoris);
          if (i == 2) context.go(AppRoutes.historique);
          if (i == 3) context.go(AppRoutes.profil);
        },
      ),
    );
  }
}
