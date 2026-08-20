import 'package:flutter/material.dart';
import 'package:fast_eat/widgets/common/app_feedback.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../models/commande.dart';
import '../../providers/flow_provider.dart';
import '../../providers/panier_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/formatters.dart';
import '../../widgets/common/image_fallback.dart';

class PanierProgrammeeScreen extends StatelessWidget {
  const PanierProgrammeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final panier = context.watch<PanierProvider>();
    final flow = context.watch<FlowProvider>();
    const horaires = ['12:00', '12:30', '13:00', '13:30', '14:00'];
    final isLivraison = flow.modeConsommation == ModeConsommation.livraison;
    final fraisLivraison = isLivraison ? flow.fraisLivraison : 0;
    final total = panier.sousTotal + fraisLivraison;

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
          const SizedBox(height: 16),
          const Text('Mode de consommation', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SegmentedButton<ModeConsommation>(
            segments: const [
              ButtonSegment(value: ModeConsommation.surPlace, icon: Icon(Icons.restaurant), label: Text('Sur place')),
              ButtonSegment(value: ModeConsommation.aEmporter, icon: Icon(Icons.takeout_dining), label: Text('À emporter')),
              ButtonSegment(value: ModeConsommation.livraison, icon: Icon(Icons.delivery_dining), label: Text('Livraison')),
            ],
            selected: {if (flow.modeConsommation != null) flow.modeConsommation!},
            onSelectionChanged: (set) => context.read<FlowProvider>().setModeConsommation(set.first),
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
              selectedForegroundColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          if (isLivraison) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18),
                        const SizedBox(width: 6),
                        const Expanded(child: Text('Adresse de livraison', style: TextStyle(fontWeight: FontWeight.w700))),
                        TextButton(onPressed: () {}, child: const Text('Modifier')),
                      ],
                    ),
                    TextFormField(
                      initialValue: flow.adresseLivraison,
                      decoration: const InputDecoration(hintText: 'Quartier Haie Vive, Rue 402'),
                      onChanged: (v) => context.read<FlowProvider>().setAdresse(v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            decoration: const InputDecoration(hintText: 'Instructions speciales'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Sous-total'), Text(fcfa(panier.sousTotal))]),
          if (isLivraison)
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Frais de livraison'), Text(fcfa(fraisLivraison))]),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)), Text(fcfa(total), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFC8102E)))]),
          const SizedBox(height: 18),
          FilledButton(
            style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              if (panier.lignes.isEmpty) {
                AppFeedback.info(context, 'Ajoutez au moins un plat avant de continuer.');
                return;
              }
              if (flow.heureRecuperation.trim().isEmpty) {
                AppFeedback.info(context, 'Veuillez choisir une heure de récupération.');
                return;
              }
              if (flow.modeConsommation == null) {
                AppFeedback.info(context, 'Veuillez choisir un mode de consommation.');
                return;
              }
              if (flow.modeConsommation == ModeConsommation.livraison && flow.adresseLivraison.trim().isEmpty) {
                AppFeedback.info(context, 'Veuillez entrer une adresse de livraison.');
                return;
              }
              await context.read<FlowProvider>().setMode(ModeCommande.programmee);
              if (!context.mounted) return;
              context.push(AppRoutes.paiementChoix);
            },
            child: const Text('Procéder au paiement'),
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
