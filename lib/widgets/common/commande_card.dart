import 'package:flutter/material.dart';

import '../../models/commande.dart';
import '../../theme/app_theme.dart';

class CommandeCard extends StatelessWidget {
  const CommandeCard({super.key, required this.commande, required this.onTap});

  final Commande commande;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(child: Icon(Icons.restaurant_menu_rounded)),
        title: Text(commande.restaurantNom, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${commande.date.day}/${commande.date.month}/${commande.date.year} • ${commande.mode.name}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatusChip(statut: commande.statut),
            const SizedBox(height: 6),
            Text('${commande.total} FCFA', style: const TextStyle(color: Color(0xFFC8102E), fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.statut});
  final StatutCommande statut;

  @override
  Widget build(BuildContext context) {
    Color c;
    String label;
    switch (statut) {
      case StatutCommande.annuleeClient:
      case StatutCommande.annuleeRestaurant:
      case StatutCommande.expiree:
        c = AppColors.error;
        label = 'Annulee';
      case StatutCommande.livree:
        c = AppColors.success;
        label = 'Terminee';
      default:
        c = AppColors.primary;
        label = 'En cours';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
