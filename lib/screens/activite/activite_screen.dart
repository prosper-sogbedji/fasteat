import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/commandes_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_feedback.dart';
import '../../widgets/common/segmented_tab.dart';
import '../../models/commande.dart';
import '../../models/reservation.dart';
import '../../widgets/common/skeleton_loader.dart';

class ActiviteScreen extends StatefulWidget {
  const ActiviteScreen({super.key});

  @override
  State<ActiviteScreen> createState() => _ActiviteScreenState();
}

class _ActiviteScreenState extends State<ActiviteScreen> with SingleTickerProviderStateMixin {
  late TabController _mainTab;

  @override
  void initState() {
    super.initState();
    _mainTab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isConnected) {
        context.read<CommandesProvider>().refreshFromApi();
        context.read<ReservationsProvider>().refresh();
      }
    });
  }

  @override
  void dispose() {
    _mainTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isConnected) {
      return Scaffold(
        appBar: AppBar(title: const Text('Activité')),
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
                  child: const Icon(Icons.receipt_long_rounded, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Connectez-vous pour\nsuivre votre activité',
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


    return AnimatedBuilder(
      animation: _mainTab,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Activité', style: TextStyle(fontWeight: FontWeight.w800)),
            centerTitle: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            bottom: TabBar(
              controller: _mainTab,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              tabs: const [
                Tab(text: 'Commandes'),
                Tab(text: 'Réservations'),
              ],
            ),
          ),
          // Plus de FAB pour les réservations ici.
          body: TabBarView(
            controller: _mainTab,
            children: const [
              _CommandesView(),
              _ReservationsView(),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// SOUS-VUE COMMANDES
// ---------------------------------------------------------------------------

class _CommandesView extends StatefulWidget {
  const _CommandesView();

  @override
  State<_CommandesView> createState() => _CommandesViewState();
}

class _CommandesViewState extends State<_CommandesView> {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CommandesProvider>();
    final commandes = prov.commandes;
    final visible = _filterCommandes(commandes);

    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _tabButton('En cours', 0),
              const SizedBox(width: 8),
              _tabButton('Terminées', 1),
              const SizedBox(width: 8),
              _tabButton('Annulées', 2),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: (prov.isSyncing && commandes.isEmpty)
              ? ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  itemCount: 4,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (_, _) => const Skeleton(height: 120, borderRadius: AppRadius.xl),
                )
              : visible.isEmpty
                  ? const Center(child: Text('Aucune commande pour cet onglet', style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (_, i) => _commandeTile(context, visible[i]),
                ),
        ),
      ],
    );
  }

  List<Commande> _filterCommandes(List<Commande> all) {
    switch (tabIndex) {
      case 0:
        return all
            .where(
              (c) =>
                  c.statut != StatutCommande.livree &&
                  c.statut != StatutCommande.annuleeClient &&
                  c.statut != StatutCommande.annuleeRestaurant &&
                  c.statut != StatutCommande.expiree,
            )
            .toList();
      case 1:
        return all.where((c) => c.statut == StatutCommande.livree).toList();
      case 2:
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
    return Expanded(
      child: SegmentedTab(
        label: label,
        selected: tabIndex == idx,
        onTap: () => setState(() => tabIndex = idx),
        compact: true,
      ),
    );
  }

  Widget _commandeTile(BuildContext context, Commande c) {
    final status = switch (c.statut) {
      StatutCommande.enAttenteValidation => ('EN ATTENTE', AppColors.primary),
      StatutCommande.preparation => ('PRÉPARATION', AppColors.primary),
      StatutCommande.prete => ('PRÊTE', AppColors.primary),
      StatutCommande.livraison => ('LIVRAISON', AppColors.primary),
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
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
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
                    style: const TextStyle(fontSize: 17, color: AppColors.primary, fontWeight: FontWeight.w800),
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

// ---------------------------------------------------------------------------
// SOUS-VUE RÉSERVATIONS
// ---------------------------------------------------------------------------

class _ReservationsView extends StatefulWidget {
  const _ReservationsView();

  @override
  State<_ReservationsView> createState() => _ReservationsViewState();
}

class _ReservationsViewState extends State<_ReservationsView> {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ReservationsProvider>();

    if (prov.isLoading && prov.reservations.isEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, _) => const Skeleton(height: 180, borderRadius: AppRadius.xl),
      );
    }

    final visible = _filterReservations(prov);

    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _tabButton('En attente', 0),
                const SizedBox(width: 8),
                _tabButton('Confirmées', 1),
                const SizedBox(width: 8),
                _tabButton('À venir', 2),
                const SizedBox(width: 8),
                _tabButton('Passées', 3),
                const SizedBox(width: 8),
                _tabButton('Annulées', 4),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _ReservationList(
            items: visible,
            emptyTitle: 'Aucune réservation',
            emptySubtitle: 'Réservez une table dans votre restaurant préféré.',
            // Bouton "Faire une réservation" retiré
            emptyAction: null,
            emptyActionLabel: null,
            showCancelButton: tabIndex == 0 || tabIndex == 1 || tabIndex == 2,
            onCancel: (r) => _onCancel(context, r, prov),
          ),
        ),
        // Pas de bouton en bas — le FAB est géré par ActiviteScreen
      ],
    );
  }

  List<Reservation> _filterReservations(ReservationsProvider prov) {
    // 0: En attente, 1: Confirmées, 2: À venir, 3: Passées, 4: Annulées
    final all = prov.reservations;
    switch (tabIndex) {
      case 0:
        return all.where((r) => r.statut == StatutReservation.enAttente).toList();
      case 1:
        return all.where((r) => r.statut == StatutReservation.confirmee).toList();
      case 2:
        return prov.aVenir;
      case 3:
        return prov.passees;
      case 4:
        return all.where((r) => r.statut == StatutReservation.annulee || r.statut == StatutReservation.refusee).toList();
      default:
        return all;
    }
  }

  Widget _tabButton(String label, int idx) {
    return SegmentedTab(
      label: label,
      selected: tabIndex == idx,
      onTap: () => setState(() => tabIndex = idx),
      compact: true,
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
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xl),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
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
    required this.onCancel,
  });

  final Reservation reservation;
  final bool showCancelButton;
  final void Function(Reservation)? onCancel;

  @override
  Widget build(BuildContext context) {
    final status = switch (reservation.statut) {
      StatutReservation.enAttente => ('EN ATTENTE', AppColors.primary),
      StatutReservation.confirmee => ('CONFIRMÉE', const Color(0xFF22C55E)),
      StatutReservation.refusee => ('REFUSÉE RESTO', const Color(0xFFEF4444)),
      StatutReservation.annulee => ('ANNULÉE', const Color(0xFFEF4444)),
      StatutReservation.terminee => ('TERMINÉE', const Color(0xFF6B7280)),
    };

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.restaurantNom,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.event_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${reservation.date.day.toString().padLeft(2, '0')}/${reservation.date.month.toString().padLeft(2, '0')}/${reservation.date.year}',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            reservation.heure,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.border),
            ),
            Row(
              children: [
                const Icon(Icons.people_alt_rounded, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  '${reservation.nombrePersonnes} personne${reservation.nombrePersonnes > 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: status.$2.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: status.$2.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    status.$1,
                    style: TextStyle(color: status.$2, fontWeight: FontWeight.w800, fontSize: 10),
                  ),
                ),
              ],
            ),
            if (showCancelButton && (reservation.statut == StatutReservation.enAttente || reservation.statut == StatutReservation.confirmee)) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onCancel != null ? () => onCancel!(reservation) : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Annuler la réservation', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
