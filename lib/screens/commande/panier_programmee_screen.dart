import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../providers/flow_provider.dart';
import '../../providers/panier_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/formatters.dart';
import '../../widgets/common/image_fallback.dart';

class PanierProgrammeeScreen extends StatelessWidget {
  const PanierProgrammeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final panier = context.watch<PanierProvider>();
    final flow = context.watch<FlowProvider>();
    const horaires = ['12:00', '12:30', '13:00', '13:30', '14:00'];
    int total = panier.sousTotal;

    return Scaffold(
      appBar: AppBar(title: const Text('Votre Panier'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Recapitulatif de la commande', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black54)),
          const SizedBox(height: 10),
          ...panier.lignes.map((l) => _ligneCard(context, l)),
          const SizedBox(height: 12),
          const Text('Heure de recuperation', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: horaires
                .map(
                  (h) => ChoiceChip(
                    selected: flow.heureRecuperation == h,
                    label: Text(h),
                    selectedColor: const Color(0xFFFCE8EC),
                    onSelected: (_) => context.read<FlowProvider>().setHeureRecuperation(h),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          TextField(
            decoration: const InputDecoration(hintText: 'Instructions speciales'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Sous-total'), Text(fcfa(total))]),
          const SizedBox(height: 4),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Frais de service'), Text('300 FCFA')]),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)), Text(fcfa(total + 300), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFC8102E)))]),
          const SizedBox(height: 18),
          FilledButton(
            style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => context.push(AppRoutes.paiementChoix),
            child: const Text('Proceder au paiement'),
          ),
        ],
      ),
      bottomNavigationBar: FastEatBottomNavBar(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) context.go(AppRoutes.home);
          if (i == 1) context.go(AppRoutes.favoris);
          if (i == 3) context.go(AppRoutes.profil);
        },
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
                  icon: Icons.remove,
                  onTap: () => context.read<PanierProvider>().changerQuantite(l.plat.id, l.quantite - 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}
