import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../models/commande.dart';
import '../../models/reservation.dart';
import '../../providers/flow_provider.dart';
import '../../providers/panier_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../providers/restaurants_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/formatters.dart';
import '../../widgets/common/image_fallback.dart';
import '../../widgets/reservation/reservation_bottom_sheet.dart';

class PanierLivraisonScreen extends StatefulWidget {
  const PanierLivraisonScreen({super.key});

  @override
  State<PanierLivraisonScreen> createState() => _PanierLivraisonScreenState();
}

class _PanierLivraisonScreenState extends State<PanierLivraisonScreen> {
  Reservation? _reservationEffectuee;

  @override
  Widget build(BuildContext context) {
    final panier = context.watch<PanierProvider>();
    final flow = context.watch<FlowProvider>();

    final isLivraison = flow.modeConsommation == ModeConsommation.livraison;
    final fraisLivraison = isLivraison ? flow.fraisLivraison : 0;
    final total = panier.sousTotal + fraisLivraison;

    final String restoId =
        panier.lignes.isNotEmpty ? panier.lignes.first.plat.restoId : '';
    final restaurant =
        context.read<RestaurantsProvider>().maybeRestaurantById(restoId);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Mon Panier',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ---- Nom du restaurant ----
          if (restaurant != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.storefront_rounded,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.nom,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        if (restaurant.quartier.isNotEmpty)
                          Text(
                            restaurant.quartier,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // ---- Mode de consommation ----
          const Text(
            'Mode de consommation',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.textSecondary,
                letterSpacing: 0.3),
          ),
          const SizedBox(height: 8),
          _ModeSelector(
            selected: flow.modeConsommation,
            onChanged: (mode) async {
              HapticFeedback.selectionClick();
              await context.read<FlowProvider>().setModeConsommation(mode);
              if (!context.mounted) return;
              if (mode == ModeConsommation.surPlace &&
                  _reservationEffectuee == null) {
                _showSurPlacePopup(context, restaurant);
              }
            },
          ),
          const SizedBox(height: 14),

          // ---- Résumé de réservation ----
          if (_reservationEffectuee != null) ...[
            _buildReservationSummary(context, _reservationEffectuee!),
            const SizedBox(height: 14),
          ],

          // ---- Section livraison ----
          if (isLivraison) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text('Adresse de livraison',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text('Modifier',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: flow.adresseLivraison,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Quartier Haie Vive, Rue 402',
                      hintStyle:
                          const TextStyle(fontSize: 13, color: Colors.black38),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFEEEEEE))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFEEEEEE))),
                    ),
                    onChanged: (v) =>
                        context.read<FlowProvider>().setAdresse(v),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 13,
                          color: Colors.grey.shade500),
                      const SizedBox(width: 5),
                      Text('Estimation',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500)),
                      const Spacer(),
                      const Text('25 – 35 min',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // ---- Votre commande ----
          const Text(
            'Votre commande',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.textSecondary,
                letterSpacing: 0.3),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ...panier.lignes.asMap().entries.map((entry) {
                  final i = entry.key;
                  final l = entry.value;
                  return Column(
                    children: [
                      if (i > 0)
                        Divider(
                            height: 1,
                            color: Colors.grey.shade100,
                            indent: 16,
                            endIndent: 16),
                      _ligneCard(context, l),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ---- Récapitulatif financier ----
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _recapLine('Sous-total', fcfa(panier.sousTotal)),
                if (isLivraison) ...[
                  const SizedBox(height: 8),
                  _recapLine('Frais de livraison', fcfa(fraisLivraison)),
                ],
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Divider(color: Colors.grey.shade100, height: 1),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15)),
                    Text(fcfa(total),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ---- Bouton paiement ----
          SizedBox(
            height: 50,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: () async {
                if (panier.lignes.isEmpty) {
                  _showInfoDialog(context, 'Panier vide',
                      'Ajoutez au moins un plat avant de continuer.');
                  return;
                }
                if (flow.modeConsommation == null) {
                  _showInfoDialog(
                      context,
                      'Mode de consommation requis',
                      'Veuillez sélectionner un mode avant de poursuivre.');
                  return;
                }
                if (flow.modeConsommation == ModeConsommation.livraison &&
                    flow.adresseLivraison.trim().isEmpty) {
                  _showInfoDialog(context, 'Adresse manquante',
                      'Veuillez entrer votre adresse de livraison.');
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
              child: const Text('Procéder au paiement',
                  style:
                      TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _recapLine(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        Text(value,
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ---- Popup Sur place — design épuré ----
  Future<void> _showSurPlacePopup(BuildContext context, restaurant) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bouton fermer
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(false),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: Colors.black54),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Icône
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.table_restaurant_rounded,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 16),
              // Titre
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      height: 1.4),
                  children: [
                    TextSpan(text: 'Vous avez choisi de manger\n'),
                    TextSpan(
                      text: 'sur place',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Sous-titre
              Text(
                'Souhaitez-vous réserver une table ?\nRecommandé à plusieurs ou aux heures de pointe.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade600,
                    height: 1.5),
              ),
              const SizedBox(height: 22),
              // Bouton Oui
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Oui, réserver une table',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 8),
              // Bouton Non
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Non, je viendrai directement',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true && context.mounted) {
      await _openReservationSheet(context, restaurant);
    }
  }

  Future<void> _openReservationSheet(BuildContext context, restaurant) async {
    final restoId = restaurant?.id ?? '';
    final restoNom = restaurant?.nom ?? 'Restaurant';
    final restoImage = restaurant?.image;

    final result = await showReservationBottomSheet(
      context,
      restaurantId: restoId,
      restaurantNom: restoNom,
      restaurantImage: restoImage,
    );

    if (result != null && mounted) {
      setState(() => _reservationEffectuee = result.reservation);
    }
  }

  // ---- Résumé réservation dans le panier ----
  Widget _buildReservationSummary(BuildContext context, Reservation r) {
    String dateLabel(DateTime d) {
      const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      const months = [
        'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
        'juil', 'août', 'sep', 'oct', 'nov', 'déc',
      ];
      return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FAF1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBDFBE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32), size: 15),
              const SizedBox(width: 6),
              const Text('Table réservée',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B5E20),
                      fontSize: 13)),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _summaryChip(Icons.calendar_month_rounded, dateLabel(r.date)),
              _summaryChip(Icons.access_time_rounded, r.heure),
              _summaryChip(Icons.people_outline_rounded,
                  '${r.nombrePersonnes} pers.'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final restaurant = context
                          .read<RestaurantsProvider>()
                          .maybeRestaurantById(r.restaurantId);
                      await _openReservationSheet(context, restaurant);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 13),
                    label: const Text('Modifier',
                        style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      side: const BorderSide(
                          color: Color(0xFF388E3C), width: 1.2),
                      foregroundColor: const Color(0xFF388E3C),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: OutlinedButton.icon(
                    onPressed: () => _annulerReservation(context, r),
                    icon: const Icon(Icons.cancel_outlined, size: 13),
                    label: const Text('Annuler',
                        style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      side: const BorderSide(
                          color: Color(0xFFE53935), width: 1.2),
                      foregroundColor: const Color(0xFFE53935),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF388E3C)),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Future<void> _annulerReservation(
      BuildContext context, Reservation r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFE53935), size: 24),
              ),
              const SizedBox(height: 14),
              const Text('Annuler la réservation ?',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                  'Voulez-vous vraiment annuler cette réservation de table ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade600)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Non',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text('Oui, annuler',
                            style:
                                TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<ReservationsProvider>().annuler(r.id);
      if (mounted) setState(() => _reservationEffectuee = null);
    }
  }

  // ---- Carte article du panier ----
  Widget _ligneCard(BuildContext context, PanierLigne l) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          ImageFallback(
            path: l.plat.image,
            label: l.plat.nom,
            width: 62,
            height: 62,
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
                      fontSize: 13.5,
                      height: 1.2),
                ),
                const SizedBox(height: 2),
                Text(
                  l.plat.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 5),
                Text(
                  fcfa(l.plat.prix),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Contrôleur de quantité
          Row(
            children: [
              _qtyBtn(
                icon: l.quantite > 1
                    ? Icons.remove
                    : Icons.delete_outline_rounded,
                color: l.quantite > 1 ? Colors.black87 : Colors.red,
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.read<PanierProvider>().changerQuantite(
                      l.plat.id, l.quantite - 1);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('${l.quantite}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
              ),
              _qtyBtn(
                icon: Icons.add,
                color: AppColors.primary,
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.read<PanierProvider>().changerQuantite(
                      l.plat.id, l.quantite + 1);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(height: 14),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(msg,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade600)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('OK',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- Sélecteur de mode en cartes ----
class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.selected, required this.onChanged});

  final ModeConsommation? selected;
  final ValueChanged<ModeConsommation> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _modeCard(
          context,
          mode: ModeConsommation.surPlace,
          icon: Icons.table_restaurant_rounded,
          label: 'Sur place',
        ),
        const SizedBox(width: 8),
        _modeCard(
          context,
          mode: ModeConsommation.aEmporter,
          icon: Icons.shopping_bag_outlined,
          label: 'À emporter',
        ),
        const SizedBox(width: 8),
        _modeCard(
          context,
          mode: ModeConsommation.livraison,
          icon: Icons.electric_moped_outlined,
          label: 'Livraison',
        ),
      ],
    );
  }

  Widget _modeCard(
    BuildContext context, {
    required ModeConsommation mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = selected == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : const Color(0xFFEEEEEE),
              width: isSelected ? 1.8 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? AppColors.primary : Colors.black54,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
