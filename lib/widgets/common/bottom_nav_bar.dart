import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';

/// Barre de navigation avec bouton central (Recherche) surélevé.
///
/// Architecture : [Stack] avec [Row] pour les onglets latéraux et
/// un [Positioned] pour le bouton central qui sort de la barre.
class FastEatBottomNavBar extends StatelessWidget {
  const FastEatBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Combien de pixels le bouton central dépasse au-dessus de la barre.
  static const double _lift = 14.0;

  /// Diamètre du bouton central surélevé.
  static const double _centerSize = 58.0;

  static const _sideItems = [
    (icon: Icons.home_outlined, active: Icons.home_rounded, label: 'Accueil', index: 0),
    (icon: Icons.assignment_outlined, active: Icons.assignment_rounded, label: 'Activité', index: 2),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        // Hauteur = barre + dépassement du bouton central
        height: 74 + _lift,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // ---- Barre principale ----
            Positioned(
              bottom: 0,
              left: 16,
              right: 16,
              child: Container(
                height: 74,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Onglet Accueil
                    Expanded(child: _buildSideTab(_sideItems[0])),
                    // Espace réservé au centre pour le bouton flottant
                    const SizedBox(width: _centerSize + 12),
                    // Onglet Activité
                    Expanded(child: _buildSideTab(_sideItems[1])),
                  ],
                ),
              ),
            ),

            // ---- Bouton central surélevé (Recherche) ----
            Positioned(
              bottom: _lift,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(1);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: _centerSize,
                  height: _centerSize,
                  decoration: BoxDecoration(
                    color: currentIndex == 1
                        ? AppColors.primaryDark
                        : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: currentIndex == 1 ? 0.45 : 0.30),
                        blurRadius: currentIndex == 1 ? 18 : 12,
                        offset: const Offset(0, 4),
                        spreadRadius: currentIndex == 1 ? 1 : 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    currentIndex == 1
                        ? Icons.search_rounded
                        : Icons.search_rounded,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideTab(
    ({IconData icon, IconData active, String label, int index}) item,
  ) {
    final selected = currentIndex == item.index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(item.index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.active : item.icon,
              size: 24,
              color: selected
                  ? AppColors.primary
                  : AppColors.textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

