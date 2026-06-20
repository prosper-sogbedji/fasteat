import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/restaurant_menu_provider.dart';
import '../../../models/plat.dart';
import '../../../models/menu_catalogue.dart';

class MenuTab extends StatefulWidget {
  const MenuTab({super.key});

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Tous';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<RestaurantMenuProvider>();
    final bool isDesktop = MediaQuery.of(context).size.width > 900;
    final double padding = isDesktop ? 32.0 : 16.0;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _buildHeader(context),
          _buildFilters(context),
          Expanded(
            child: menuProvider.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    children: [
                      _buildDishGrid(context, menuProvider),
                      const SizedBox(height: 32),
                      _buildImportBox(context, menuProvider),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;
    final double padding = isDesktop ? 32.0 : 16.0;
    return Container(
      padding: EdgeInsets.fromLTRB(padding, padding, padding, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'Gestion du Menu',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF0F172A)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary),
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () => context.push('/plat-nouveau'),
                icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                label: const Text('Ajouter', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;
    final double padding = isDesktop ? 32.0 : 16.0;

    final Widget searchField = Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher un plat...',
                hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );

    final Widget filterPills = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterPill('Tous'),
          _filterPill('Entrées'),
          _filterPill('Plats'),
          _filterPill('Desserts'),
          _filterPill('Boissons'),
        ],
      ),
    );

    if (isDesktop) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: searchField,
            ),
            const SizedBox(width: 32),
            filterPills,
          ],
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          children: [
            searchField,
            const SizedBox(height: 12),
            filterPills,
          ],
        ),
      );
    }
  }

  Widget _filterPill(String label) {
    final bool isActive = _selectedCategory == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDishGrid(BuildContext context, RestaurantMenuProvider menuProvider) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;
    
    // Filtrage combiné : recherche textuelle + catégorie
    final dishes = menuProvider.entreesPourRestaurant(menuProvider.currentRestaurantId ?? 'r1').where((entry) {
      final plat = entry.plat;
      
      // 1. Filtrage par pilules de catégorie
      if (_selectedCategory != 'Tous') {
        final String categoryTarget = switch (_selectedCategory) {
          'Entrées' => 'entrees',
          'Plats' => 'plats',
          'Desserts' => 'desserts',
          'Boissons' => 'boissons',
          _ => _selectedCategory.toLowerCase(),
        };
        
        final String platCat = plat.categorie.toLowerCase();
        final bool isPlatMatch = (categoryTarget == 'plats' && (platCat == 'plats' || platCat == 'cat_mains'));
        final bool isEntreeMatch = (categoryTarget == 'entrees' && (platCat == 'entrees' || platCat == 'accompagnements'));
        final bool isGeneralMatch = platCat == categoryTarget;
        
        if (!isPlatMatch && !isEntreeMatch && !isGeneralMatch) {
          return false;
        }
      }
      
      // 2. Filtrage par recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = plat.nom.toLowerCase().contains(query);
        final matchesDesc = plat.description.toLowerCase().contains(query);
        final matchesTags = entry.tags.any((t) => t.toLowerCase().contains(query));
        if (!matchesName && !matchesDesc && !matchesTags) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    if (dishes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text('Aucun plat ne correspond à vos critères.', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: isDesktop ? 280 : 180,
        childAspectRatio: isDesktop ? 0.85 : 0.72,
        crossAxisSpacing: isDesktop ? 24 : 12,
        mainAxisSpacing: isDesktop ? 24 : 12,
      ),
      itemCount: dishes.length,
      itemBuilder: (context, index) {
        final entry = dishes[index];
        final dish = entry.plat;
        final bool isDispo = dish.disponible;
        final double innerPadding = isDesktop ? 16.0 : 10.0;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      (() {
                        final imgPath = dish.image;
                        if (imgPath.isEmpty) {
                          return Image.asset('assets/images/plat_real_1.jpg', fit: BoxFit.cover);
                        }
                        if (imgPath.startsWith('http')) {
                          return Image.network(
                            imgPath, 
                            fit: BoxFit.cover, 
                            errorBuilder: (c, e, s) => Image.asset('assets/images/plat_real_1.jpg', fit: BoxFit.cover),
                          );
                        }
                        if (imgPath.startsWith('data:image')) {
                          final base64Str = imgPath.split(',').last;
                          return Image.memory(
                            base64Decode(base64Str),
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Image.asset('assets/images/plat_real_1.jpg', fit: BoxFit.cover),
                          );
                        }
                        final cleanPath = imgPath.startsWith('/') ? imgPath.substring(1) : imgPath;
                        return Image.asset(
                          cleanPath,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Image.asset('assets/images/plat_real_1.jpg', fit: BoxFit.cover),
                        );
                      })(),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            dish.categorie.toUpperCase(),
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(innerPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dish.nom,
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: isDesktop ? 14 : 12, color: const Color(0xFF0F172A)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${dish.prix} FCFA',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: isDesktop ? 12 : 11),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_outlined, size: isDesktop ? 16 : 14, color: Colors.grey[600]),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _modifierPlatDialog(context, menuProvider, dish),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: isDesktop ? 16 : 14, color: Colors.red[400]),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _supprimerPlatDialog(context, menuProvider, dish),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: isDesktop ? 16 : 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isDispo ? 'Dispo.' : 'Rupture',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: isDesktop ? 11 : 10,
                            color: isDispo ? const Color(0xFF475569) : AppColors.primary,
                          ),
                        ),
                        Transform.scale(
                          scale: isDesktop ? 0.8 : 0.7,
                          child: Switch.adaptive(
                            value: isDispo,
                            onChanged: (v) {
                              context.read<RestaurantMenuProvider>().definirDisponibilitePlat(dish.id, v);
                            },
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey[300],
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImportBox(BuildContext context, RestaurantMenuProvider menuProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.restaurant_menu_rounded, size: 40, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),
          const Text('Plus de plats à afficher', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _importerPlatsDemoDialog(context, menuProvider),
            child: const Text(
              'Importer une liste de plats',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, decoration: TextDecoration.underline, decorationColor: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _supprimerPlatDialog(BuildContext context, RestaurantMenuProvider provider, Plat plat) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Supprimer le plat', style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer "${plat.nom}" ? Cette action est irréversible.',
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ANNULER', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                Navigator.pop(context);
                final success = await provider.supprimerPlat(plat.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Plat supprimé avec succès.' : 'Erreur lors de la suppression.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('SUPPRIMER', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _modifierPlatDialog(BuildContext context, RestaurantMenuProvider provider, Plat plat) {
    final nameController = TextEditingController(text: plat.nom);
    final priceController = TextEditingController(text: '${plat.prix}');
    String selectedCat = plat.categorie;
    bool isDispo = plat.disponible;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              titlePadding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
              contentPadding: const EdgeInsets.symmetric(horizontal: 32),
              actionsPadding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Text('Édition rapide', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF1E293B))),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('NOM DU PLAT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF334155)),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('PRIX (FCFA)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF334155)),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('CATÉGORIE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: PlatWizardDraft.categoriesSuggestion.contains(selectedCat) ? selectedCat : PlatWizardDraft.categoriesSuggestion.first,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF334155)),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                        items: PlatWizardDraft.categoriesSuggestion.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedCat = val);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Disponible à la commande', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF334155))),
                          value: isDispo,
                          activeColor: Colors.white,
                          activeTrackColor: Colors.green,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.grey.shade300,
                          onChanged: (val) {
                            setDialogState(() => isDispo = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/plat-nouveau?rid=${provider.currentRestaurantId ?? 'r1'}&platId=${plat.id}');
                      },
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('PLUS D\'OPTIONS', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
                          child: const Text('ANNULER', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            final nom = nameController.text.trim();
                            final prix = int.tryParse(priceController.text.replaceAll(RegExp(r'\D'), '')) ?? 0;
                            
                            if (nom.length < 3 || prix <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Veuillez saisir un nom et un prix valides.')),
                              );
                              return;
                            }

                            Navigator.pop(context);
                            final success = await provider.modifierPlat(
                              platId: plat.id,
                              nom: nom,
                              prix: prix,
                              categorie: selectedCat,
                              disponible: isDispo,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success ? 'Plat mis à jour avec succès.' : 'Erreur lors de la mise à jour.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('ENREGISTRER', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _importerPlatsDemoDialog(BuildContext context, RestaurantMenuProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.download_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Importer les plats démo', style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          content: const Text(
            'Voulez-vous injecter le pack de démo (Garba royal, Aloco pimenté, Jus de Bissap, Atassi complet) ? Cela peuplera votre carte instantanément.',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ANNULER', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                Navigator.pop(context);
                final success = await provider.importerPlatsDemo('r1');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Plats importés avec succès !' : 'Erreur lors de l\'importation.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('IMPORTER', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
