import 'package:flutter/material.dart';
import 'package:fast_eat/widgets/common/app_feedback.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../models/reservation.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/image_fallback.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isConnected) {
        context.read<ReservationsProvider>().refresh();
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final prov = context.watch<ReservationsProvider>();

    if (!auth.isConnected) {
      return Scaffold(
        appBar: AppBar(title: const Text('Réservations')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.event_seat_rounded, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Connectez-vous pour\ngérer vos réservations',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.connexion),
                  child: const Text('Se connecter'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes réservations', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'Passées'),
          ],
        ),
      ),
      body: prov.isLoading && prov.reservations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tab,
              children: [
                _ReservationList(
                  items: prov.aVenir,
                  emptyTitle: 'Aucune réservation à venir',
                  emptySubtitle: 'Réservez une table dans votre restaurant préféré.',
                  emptyAction: null,
                  emptyActionLabel: null,
                  onCancel: (r) => _onCancel(context, r, prov),
                ),
                _ReservationList(
                  items: prov.passees,
                  emptyTitle: 'Aucune réservation passée',
                  emptySubtitle: 'Vos réservations terminées apparaîtront ici.',
                  showCancelButton: false,
                ),
              ],
            ),
      );
  }

  Future<void> _onCancel(BuildContext ctx, Reservation r, ReservationsProvider prov) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Annuler la réservation ?'),
        content: Text('Voulez-vous annuler votre réservation chez ${r.restaurantNom} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Non')),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
    if (confirmed == true && ctx.mounted) {
      await prov.annuler(r.id);
      if (ctx.mounted) {
        AppFeedback.success(ctx, 'Réservation annulée');
      }
    }
  }

}

class _ReservationList extends StatelessWidget {
  const _ReservationList({
    required this.items,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.emptyAction,
    this.emptyActionLabel,
    this.showCancelButton = true,
    this.onCancel,
  });

  final List<Reservation> items;
  final String emptyTitle;
  final String emptySubtitle;
  final VoidCallback? emptyAction;
  final String? emptyActionLabel;
  final bool showCancelButton;
  final void Function(Reservation)? onCancel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.event_available_rounded, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Text(
                emptyTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              if (emptyAction != null && emptyActionLabel != null) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: emptyAction,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(emptyActionLabel!),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ReservationsProvider>().refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: items.length,
        itemBuilder: (_, i) => _ReservationCard(
          reservation: items[i],
          showCancelButton: showCancelButton,
          onCancel: onCancel,
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
    required this.showCancelButton,
    this.onCancel,
  });

  final Reservation reservation;
  final bool showCancelButton;
  final void Function(Reservation)? onCancel;

  Color _statutColor() {
    switch (reservation.statut) {
      case StatutReservation.confirmee:
        return const Color(0xFF22C55E);
      case StatutReservation.refusee:
      case StatutReservation.annulee:
        return const Color(0xFFEF4444);
      case StatutReservation.terminee:
        return AppColors.textSecondary;
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = reservation;
    final statutColor = _statutColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 70,
                height: 70,
                child: r.restaurantImage != null
                    ? ImageFallback(path: r.restaurantImage!, label: r.restaurantNom)
                    : Container(color: AppColors.border, child: const Icon(Icons.restaurant_rounded, color: AppColors.textSecondary)),
              ),
            ),
            const SizedBox(width: 14),
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          r.restaurantNom,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.table_restaurant_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text('Table pour ${r.nombrePersonnes} personnes', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text('${_formatDate(r.date)} • ${r.heure}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Badge + Actions
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statutColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          r.statutLabel,
                          style: TextStyle(color: statutColor, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  if (r.commentaire != null && r.commentaire!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.comment_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            r.commentaire!,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (showCancelButton && r.isActive && onCancel != null) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => onCancel!(r),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Color(0xFFFFCDD2)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  String _formatDate(DateTime d) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
