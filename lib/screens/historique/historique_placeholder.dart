import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../providers/commandes_provider.dart';
import '../../models/commande.dart';
import '../../theme/app_theme.dart';

class HistoriquePlaceholderScreen extends StatefulWidget {
  const HistoriquePlaceholderScreen({super.key});

  @override
  State<HistoriquePlaceholderScreen> createState() => _HistoriquePlaceholderScreenState();
}

class _HistoriquePlaceholderScreenState extends State<HistoriquePlaceholderScreen> {
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommandesProvider>().refreshFromApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final commandes = context.watch<CommandesProvider>().commandes;
    final visible = _filterCommandes(commandes);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique commandes'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _tabButton('Toutes', 0),
                const SizedBox(width: 8),
                _tabButton('En cours', 1),
                const SizedBox(width: 8),
                _tabButton('Terminees', 2),
                const SizedBox(width: 8),
                _tabButton('Annulees', 3),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: visible.isEmpty
                ? const Center(child: Text('Aucune commande pour cet onglet'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: visible.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _commandeTile(context, visible[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<Commande> _filterCommandes(List<Commande> all) {
    switch (tabIndex) {
      case 1:
        return all
            .where(
              (c) =>
                  c.statut != StatutCommande.livree &&
                  c.statut != StatutCommande.annuleeClient &&
                  c.statut != StatutCommande.annuleeRestaurant &&
                  c.statut != StatutCommande.expiree,
            )
            .toList();
      case 2:
        return all.where((c) => c.statut == StatutCommande.livree).toList();
      case 3:
        return all
            .where(
              (c) =>
                  c.statut == StatutCommande.annuleeClient ||
                  c.statut == StatutCommande.annuleeRestaurant ||
                  c.statut == StatutCommande.expiree,
            )
            .toList();
      default:
        return all;
    }
  }

  Widget _tabButton(String label, int idx) {
    final selected = tabIndex == idx;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => tabIndex = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _commandeTile(BuildContext context, Commande c) {
    final status = switch (c.statut) {
      StatutCommande.enAttenteValidation => ('EN ATTENTE', const Color(0xFF0B6E6E)),
      StatutCommande.preparation => ('PRÉPARATION', const Color(0xFF0B6E6E)),
      StatutCommande.prete => ('PRÊTE', const Color(0xFF0B6E6E)),
      StatutCommande.livraison => ('LIVRAISON', const Color(0xFF0B6E6E)),
      StatutCommande.livree => ('LIVRÉE', const Color(0xFF22C55E)),
      StatutCommande.annuleeRestaurant => ('ANNULÉE RESTO', const Color(0xFFEF4444)),
      StatutCommande.annuleeClient => ('ANNULÉE', const Color(0xFFEF4444)),
      StatutCommande.expiree => ('EXPIRÉE', const Color(0xFFF59E0B)),
    };

    final isEnCours = c.statut == StatutCommande.enAttenteValidation ||
        c.statut == StatutCommande.preparation ||
        c.statut == StatutCommande.prete ||
        c.statut == StatutCommande.livraison;
    final isLivree = c.statut == StatutCommande.livree;
    final annulationMessage = context.read<CommandesProvider>().getCommandeAnnulationMessage(c);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.restaurantNom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  Text(
                    '${c.date.day}/${c.date.month}/${c.date.year}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    c.mode == ModeCommande.programmee
                        ? 'Commande programmée'
                        : c.mode == ModeCommande.livraison
                            ? 'Commande en livraison'
                            : 'Commande sur place',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  if (annulationMessage != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      annulationMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${c.total} FCFA',
                    style: const TextStyle(fontSize: 20, color: AppColors.primary, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status.$2.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(status.$1, style: TextStyle(color: status.$2, fontWeight: FontWeight.w700, fontSize: 10)),
                ),
                if (isEnCours) ...[
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => context.push(AppRoutes.suivi),
                    style: FilledButton.styleFrom(minimumSize: const Size(88, 34)),
                    child: const Text('Suivre', style: TextStyle(fontSize: 11)),
                  ),
                ],
                if (isLivree) ...[
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => context.push('${AppRoutes.restaurant}/${c.restaurantId}'),
                    style: FilledButton.styleFrom(minimumSize: const Size(96, 34)),
                    child: const Text('Re-commander', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
