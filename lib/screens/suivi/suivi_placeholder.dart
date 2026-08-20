import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../models/commande.dart';
import '../../providers/commandes_provider.dart';
import '../../theme/app_theme.dart';

class SuiviPlaceholderScreen extends StatelessWidget {
  const SuiviPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final commandes = context.watch<CommandesProvider>();
    final active = commandes.commandeActive;
    if (active == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Suivi commande')),
        body: const Center(child: Text('Aucune commande active pour le moment.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Suivi commande')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6F3F2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primaryDark),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(active.restaurantNom, style: const TextStyle(fontWeight: FontWeight.w800)),
                            Text(
                              active.id,
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => context.push(AppRoutes.chat),
                    style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Contacter le restaurant'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text('En direct', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
          const SizedBox(height: 8),
          if (active.heureRecuperationSouhaitee != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF7F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                "Retrait demandé à ${_hhmm(active.heureRecuperationSouhaitee!)}",
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryDark),
              ),
            ),
          if (commandes.shouldSuggestCancelForDelay(active))
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8EB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "La commande est toujours en attente de validation.",
                style: TextStyle(color: Color(0xFF7A5A00), fontWeight: FontWeight.w600),
              ),
            ),
          _step(
            'En attente de validation',
            'Le restaurant consulte votre commande.',
            _isReached(active.statut, StatutCommande.enAttenteValidation),
          ),
          _step('En préparation', 'Le chef s’occupe de vos délicieux plats.', _isReached(active.statut, StatutCommande.preparation)),
          _step('Commande prête', 'Le restaurant vous notifie quand le repas est prêt.', _isReached(active.statut, StatutCommande.prete)),
          _step('En livraison', 'Le livreur a récupéré votre commande.', _isReached(active.statut, StatutCommande.livraison)),
          _step('Livrée', 'Bon appétit !', _isReached(active.statut, StatutCommande.livree)),
          const SizedBox(height: 16),
          if (active.statut == StatutCommande.livraison)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.delivery_dining)),
                title: const Text('Kofi G.', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('64 43 42 (livreur)'),
                trailing: TextButton(
                  onPressed: () => context.push(AppRoutes.chat),
                  child: const Icon(Icons.call_rounded),
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (commandes.canClientCancel(active))
            OutlinedButton(
              onPressed: () => context.read<CommandesProvider>().annulerCommandeParClient(active.id),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Annuler (${commandes.remainingClientCancel(active).inMinutes} min restantes)'),
            ),
          if (!commandes.canClientCancel(active) && active.statut == StatutCommande.enAttenteValidation)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                "Le délai d'annulation (20 min) est dépassé.",
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
          if (commandes.getCommandeAnnulationMessage(active) != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                commandes.getCommandeAnnulationMessage(active)!,
                style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _step(String label, String sub, bool active) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF22C55E) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? const Color(0xFF22C55E) : const Color(0xFFCDD5D7)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(sub, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  bool _isReached(StatutCommande current, StatutCommande step) {
    const order = {
      StatutCommande.enAttenteValidation: 0,
      StatutCommande.preparation: 1,
      StatutCommande.prete: 2,
      StatutCommande.livraison: 3,
      StatutCommande.livree: 4,
      StatutCommande.annuleeClient: -1,
      StatutCommande.annuleeRestaurant: -1,
      StatutCommande.expiree: -1,
    };
    if (current == StatutCommande.annuleeClient ||
        current == StatutCommande.annuleeRestaurant ||
        current == StatutCommande.expiree) {
      return false;
    }
    return (order[current] ?? 0) >= (order[step] ?? 0);
  }

  String _hhmm(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
