import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Pilule de sélection réutilisable (Activité, filtres, etc.).
class SegmentedTab extends StatelessWidget {
  const SegmentedTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          vertical: compact ? 7 : 8,
          horizontal: compact ? 12 : 14,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.textPrimary : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
