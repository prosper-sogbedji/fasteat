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

class PanierLivraisonScreen extends StatefulWidget {
  const PanierLivraisonScreen({super.key});

  @override
  State<PanierLivraisonScreen> createState() => _PanierLivraisonScreenState();
}

class _PanierLivraisonScreenState extends State<PanierLivraisonScreen> {
  bool _reservationDeclined = false;
  bool _tableReservee = false;

  @override
  Widget build(BuildContext context) {
    final panier = context.watch<PanierProvider>();
    final flow = context.watch<FlowProvider>();

    final isLivraison = flow.modeConsommation == ModeConsommation.livraison;
    final isSurPlace = flow.modeConsommation == ModeConsommation.surPlace;
    final showReservationCard = isSurPlace && !_reservationDeclined && !_tableReservee;

    final fraisLivraison = isLivraison ? flow.fraisLivraison : 0;
    final total = panier.sousTotal + fraisLivraison;

    final String restoId = panier.lignes.isNotEmpty
        ? panier.lignes.first.plat.restoId
        : '';
    final restaurant = context.read<RestaurantsProvider>().maybeRestaurantById(
      restoId,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Mon Panier'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (restaurant != null) ...[
            Row(
              children: [
                const Icon(Icons.storefront_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    restaurant.nom,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
          ],
          const Text(
            'Mode de consommation',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          SegmentedButton<ModeConsommation>(
            segments: const [
              ButtonSegment(
                value: ModeConsommation.surPlace,
                icon: Icon(Icons.restaurant),
                label: Text('Sur place'),
              ),
              ButtonSegment(
                value: ModeConsommation.aEmporter,
                icon: Icon(Icons.takeout_dining),
                label: Text('À emporter'),
              ),
              ButtonSegment(
                value: ModeConsommation.livraison,
                icon: Icon(Icons.delivery_dining),
                label: Text('Livraison'),
              ),
            ],
            selected: {
              if (flow.modeConsommation != null) flow.modeConsommation!,
            },
            onSelectionChanged: (set) {
              context.read<FlowProvider>().setModeConsommation(set.first);
              setState(() {
                _reservationDeclined = false;
              });
            },
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
              selectedForegroundColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          if (showReservationCard) ...[
            _buildReservationCard(context, flow, restaurant),
            const SizedBox(height: 16),
          ],
          if (_tableReservee) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Table réservée avec succès !',
                      style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

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
                        const Expanded(
                          child: Text(
                            'Adresse de livraison',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Modifier'),
                        ),
                      ],
                    ),
                    TextFormField(
                      initialValue: flow.adresseLivraison,
                      decoration: const InputDecoration(
                        hintText: 'Quartier Haie Vive, Rue 402',
                      ),
                      onChanged: (v) =>
                          context.read<FlowProvider>().setAdresse(v),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('Estimation'),
                        Spacer(),
                        Text(
                          '25 - 35 min',
                          style: TextStyle(
                            color: Color(0xFFC8102E),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          const Text(
            'Votre commande',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...panier.lignes.map((l) => _ligneCard(context, l)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const Text('Sous-total'), Text(fcfa(panier.sousTotal))],
          ),
          if (isLivraison)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Frais de livraison'),
                Text(fcfa(fraisLivraison)),
              ],
            ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                fcfa(total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC8102E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (!showReservationCard)
            FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                if (panier.lignes.isEmpty) {
                  _showErrorDialog(
                    context,
                    'Panier vide',
                    'Ajoutez au moins un plat avant de continuer.',
                  );
                  return;
                }
                if (flow.modeConsommation == null) {
                  _showErrorDialog(
                    context,
                    'Mode de consommation requis',
                    'Veuillez choisir entre Sur place, À emporter ou Livraison avant de continuer.',
                  );
                  return;
                }
                if (flow.modeConsommation == ModeConsommation.livraison &&
                    flow.adresseLivraison.trim().isEmpty) {
                  _showErrorDialog(
                    context,
                    'Adresse manquante',
                    'Veuillez entrer votre adresse de livraison avant de continuer.',
                  );
                  return;
                }
                await context.read<FlowProvider>().setMode(
                  flow.modeConsommation == ModeConsommation.livraison
                      ? ModeCommande.livraison
                      : ModeCommande.programmee,
                );
                if (!context.mounted) return;
                context.push(AppRoutes.paiementChoix);
              },
              child: const Text('Procéder au paiement'),
            ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(BuildContext context, FlowProvider flow, restaurant) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.table_restaurant_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Souhaitez-vous réserver une table ?',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Cela est recommandé si vous venez à plusieurs ou pendant les heures d\'affluence.\n\n'
            '• 1 personne : Facultatif\n'
            '• 2 à 4 personnes : Recommandé\n'
            '• 5+ personnes : Fortement recommandé',
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.4,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              bool? result;
              if (restaurant != null) {
                result = await context.push<bool>(
                  '${AppRoutes.nouvelleReservation}?restaurantId=${restaurant.id}&restaurantNom=${Uri.encodeComponent(restaurant.nom)}&restaurantImage=${Uri.encodeComponent(restaurant.image)}'
                );
              } else {
                result = await context.push<bool>(AppRoutes.nouvelleReservation);
              }
              if (result == true && context.mounted) {
                setState(() {
                  _tableReservee = true;
                });
              }
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Oui, réserver une table'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _reservationDeclined = true;
              });
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Non, je viendrai directement'),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.plat.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fcfa(l.plat.prix),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                _qtyBtn(
                  icon: Icons.add,
                  onTap: () => context.read<PanierProvider>().changerQuantite(
                    l.plat.id,
                    l.quantite + 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    '${l.quantite}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                _qtyBtn(
                  icon: l.quantite > 1
                      ? Icons.remove
                      : Icons.delete_outline_rounded,
                  color: l.quantite > 1 ? AppColors.primary : Colors.red,
                  onTap: () => context.read<PanierProvider>().changerQuantite(
                    l.plat.id,
                    l.quantite - 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) {
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

  void _showErrorDialog(BuildContext context, String title, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Color(0xFFFF7700),
          size: 40,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(msg, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: FilledButton.styleFrom(
              minimumSize: const Size(120, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
