import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../models/commande.dart';
import '../../providers/flow_provider.dart';
import '../../providers/panier_provider.dart';
import '../../providers/restaurants_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/formatters.dart';
import '../../widgets/common/image_fallback.dart';
import '../../widgets/common/formatters.dart';

/// Écran de confirmation panier en mode QR / Sur place.
/// Affiche le numéro de table détecté et les articles, puis redirige vers le paiement.
class PanierQrScreen extends StatelessWidget {
  const PanierQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final panier = context.watch<PanierProvider>();
    final flow = context.watch<FlowProvider>();
    final lignes = panier.lignes;
    final total = panier.sousTotal;

    final String restoId = lignes.isNotEmpty ? lignes.first.plat.restoId : '';
    final restaurant = context.read<RestaurantsProvider>().maybeRestaurantById(restoId);

    if (lignes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Panier — Sur place'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.red),
              tooltip: 'Quitter la table',
              onPressed: () {
                // Réinitialiser le mode QR pour repasser en mode classique
                context.read<FlowProvider>().setMode(ModeCommande.programmee);
                context.pop();
              },
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text('Votre panier est vide.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier — Sur place'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.red),
            tooltip: 'Quitter la table',
            onPressed: () {
              context.read<FlowProvider>().setMode(ModeCommande.programmee);
              context.pop();
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Badge "Table détectée"
          if (restaurant != null) ...[
            Row(
              children: [
                const Icon(Icons.storefront_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(restaurant.nom, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18))),
              ],
            ),
            const Divider(height: 24),
          ],
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEAF7F7), Color(0xFFD4F3F3)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.table_restaurant_rounded, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Table détectée', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primaryDark)),
                      Text(
                        'Table n° ${flow.codeTableQr}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.verified_rounded, color: AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Liste des articles
          const Text('Vos articles', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1D2939))),
          const SizedBox(height: 10),
          ...lignes.map((l) => _ligneCard(context, l)),

          const Divider(height: 28),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total à payer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              Text(fcfa(total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 20),

          // Bouton payer
          FilledButton(
            onPressed: () async {
              await context.read<FlowProvider>().setMode(ModeCommande.qrCode);
              if (!context.mounted) return;
              context.push(AppRoutes.paiementChoix);
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Procéder au paiement', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Ajouter d\'autres plats'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ligneCard(BuildContext context, PanierLigne l) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ImageFallback(
              path: l.plat.image,
              label: l.plat.nom,
              width: 72,
              height: 72,
              radius: 10,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.plat.nom,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, height: 1.15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.plat.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fcfa(l.plat.prix),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                _qtyBtn(
                  icon: Icons.add,
                  onTap: () => context.read<PanierProvider>().changerQuantite(l.plat.id, l.quantite + 1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text('${l.quantite}', style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                _qtyBtn(
                  icon: l.quantite > 1 ? Icons.remove : Icons.delete_outline_rounded,
                  color: l.quantite > 1 ? AppColors.primary : Colors.red,
                  onTap: () => context.read<PanierProvider>().changerQuantite(l.plat.id, l.quantite - 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn({required IconData icon, required VoidCallback onTap, Color color = AppColors.primary}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
