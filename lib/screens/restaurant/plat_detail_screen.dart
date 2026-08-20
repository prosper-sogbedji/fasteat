import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/mock/mock_plats.dart';
import '../../models/plat.dart';
import '../../providers/panier_provider.dart';
import '../../providers/restaurants_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/formatters.dart';
import '../../widgets/common/image_fallback.dart';

class PlatDetailScreen extends StatefulWidget {
  const PlatDetailScreen({super.key, required this.platId});
  final String platId;

  @override
  State<PlatDetailScreen> createState() => _PlatDetailScreenState();
}

class _PlatDetailScreenState extends State<PlatDetailScreen> {
  int _qte = 1;
  String? _accompagnement;
  bool _adding = false;

  static const _accompagnements = [
    'Atassi traditionnel',
    'Alloco (plantain frit)',
    'Riz blanc parfumé',
    'Frites maison',
    'Salade verte fraîche',
  ];

  @override
  Widget build(BuildContext context) {
    Plat? plat = context.watch<RestaurantsProvider>().platParId(widget.platId);
    if (plat == null) {
      try {
        plat = mockPlats.firstWhere((p) => p.id == widget.platId);
      } catch (_) {}
    }

    if (plat == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détail du plat'),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.no_food_rounded,
                  size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              const Text(
                'Ce plat est indisponible\npour le moment.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }
    
    final validPlat = plat;
    final total = validPlat.prix * _qte;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Stack(
        children: [
          // ── Contenu scrollable
          CustomScrollView(
            slivers: [
              // ── Image hero + AppBar
              SliverAppBar(
                pinned: true,
                expandedHeight: isTablet ? 320 : 260,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
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
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      ImageFallback(
                        path: validPlat.image,
                        label: validPlat.nom,
                        radius: 0,
                        height: isTablet ? 320 : 260,
                      ),
                      // Badge prix
                      Positioned(
                        right: 14,
                        bottom: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            fcfa(validPlat.prix),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Corps
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      isTablet ? 32 : 16, 16, isTablet ? 32 : 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom & catégorie
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                validPlat.categorie,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                    color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              validPlat.nom,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: isTablet ? 22 : 20,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              validPlat.description,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Accompagnements
                      _sectionTitle('Accompagnement', required: false),
                      const SizedBox(height: 10),
                      ...(_accompagnements.map((a) =>
                          _AccompagnementTile(
                            label: a,
                            selected: _accompagnement == a,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _accompagnement =
                                  _accompagnement == a ? null : a);
                            },
                          ))),
                      const SizedBox(height: 16),

                      // ── Quantité
                      _sectionTitle('Quantité'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: AppColors.primary, size: 16),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Nombre de portions souhaitées',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black87),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _QuantityStepper(
                              value: _qte,
                              onDecrement: _qte > 1
                                  ? () => setState(() => _qte--)
                                  : null,
                              onIncrement: () =>
                                  setState(() => _qte++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bouton "Ajouter au panier" ancré en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  12 + MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _adding
                      ? null
                      : () => _addToCart(context, validPlat),
                  child: _adding
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_shopping_cart_rounded,
                                size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Ajouter au panier · ${fcfa(total)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, {bool required = true}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: Colors.black87),
        ),
        if (!required) ...[
          const SizedBox(width: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('Optionnel',
                style: TextStyle(
                    fontSize: 11, color: Colors.grey)),
          ),
        ],
      ],
    );
  }

  Future<void> _addToCart(BuildContext context, Plat plat) async {
    HapticFeedback.mediumImpact();
    setState(() => _adding = true);
    final panier = context.read<PanierProvider>();
    try {
      for (int i = 0; i < _qte; i++) {
        await panier.ajouterPlat(plat);
      }
      if (context.mounted) {
        HapticFeedback.heavyImpact();
        Navigator.pop(context);
      }
    } on CrossRestaurantException catch (_) {
      if (context.mounted) {
        setState(() => _adding = false);
        _showCrossRestaurantDialog(context, panier, plat);
      }
    }
  }

  void _showCrossRestaurantDialog(
      BuildContext context, PanierProvider panier, Plat plat) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shopping_bag_outlined,
                    color: Colors.orange.shade700, size: 28),
              ),
              const SizedBox(height: 14),
              const Text('Nouveau restaurant ?',
                  style: TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 17)),
              const SizedBox(height: 8),
              const Text(
                'Votre panier contient des articles d\'un autre restaurant. Voulez-vous le vider pour commander ici ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black54, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Annuler',
                          style: TextStyle(color: Colors.black54)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await panier.vider();
                        for (int i = 0; i < _qte; i++) {
                          await panier.ajouterPlat(plat);
                        }
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Vider et ajouter'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tile d'accompagnement ────────────────────────────────────────────────────
class _AccompagnementTile extends StatelessWidget {
  const _AccompagnementTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.grey.shade200,
              width: selected ? 1.5 : 1.2,
            ),
            boxShadow: selected
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.primary : Colors.grey.shade400,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13.5,
                    color: selected ? Colors.black87 : Colors.black54,
                  ),
                ),
              ),
              if (selected)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Sélectionné',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stepper de quantité ──────────────────────────────────────────────────────
class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.value,
    required this.onIncrement,
    this.onDecrement,
  });

  final int value;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBtn(
          icon: Icons.remove_rounded,
          onTap: onDecrement,
          enabled: onDecrement != null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            '$value',
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.primary),
          ),
        ),
        _StepBtn(icon: Icons.add_rounded, onTap: onIncrement),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColors.primary : Colors.grey.shade400,
        ),
      ),
    );
  }
}
