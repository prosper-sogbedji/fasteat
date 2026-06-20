import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/restaurant_dashboard_provider.dart';

class HorairesTab extends StatefulWidget {
  const HorairesTab({super.key});

  @override
  State<HorairesTab> createState() => _HorairesTabState();
}

class _HorairesTabState extends State<HorairesTab> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantDashboardProvider>().loadHours();
    });
  }

  Future<void> _toggleDayClosed(RestaurantDashboardProvider provider, int dayOfWeek) async {
    final hours = provider.hours;
    final entry = hours.firstWhere(
      (h) => h['dayOfWeek'] == dayOfWeek,
      orElse: () => {'dayOfWeek': dayOfWeek, 'opensAt': '08:00', 'closesAt': '22:00', 'isClosed': false},
    );
    final newClosed = !(entry['isClosed'] == true);
    setState(() => _isSaving = true);
    final ok = await provider.saveDayHours(
      dayOfWeek: dayOfWeek,
      opensAt: entry['opensAt']?.toString() ?? '08:00',
      closesAt: entry['closesAt']?.toString() ?? '22:00',
      isClosed: newClosed,
    );
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Horaires mis à jour.' : 'Erreur lors de la sauvegarde.')),
      );
    }
  }

  Future<void> _markClosedToday(RestaurantDashboardProvider provider) async {
    final today = DateTime.now().weekday - 1; // 0 = lundi
    final entry = provider.hours.firstWhere(
      (h) => h['dayOfWeek'] == today,
      orElse: () => {'dayOfWeek': today, 'opensAt': '08:00', 'closesAt': '22:00', 'isClosed': false},
    );
    setState(() => _isSaving = true);
    final ok = await provider.saveDayHours(
      dayOfWeek: today,
      opensAt: entry['opensAt']?.toString() ?? '08:00',
      closesAt: entry['closesAt']?.toString() ?? '22:00',
      isClosed: true,
    );
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Restaurant marqué fermé aujourd\'hui.' : 'Erreur.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantDashboardProvider>();
    final bool isDesktop = MediaQuery.of(context).size.width > 900;
    final double padding = isDesktop ? 32.0 : 16.0;
    final hours = provider.hours;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: provider.isLoadingHours && hours.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, provider, isDesktop),
                  const SizedBox(height: 32),
                  _buildHorairesTable(context, provider, hours),
                  const SizedBox(height: 32),
                  Align(
                    alignment: isDesktop ? Alignment.centerRight : Alignment.center,
                    child: SizedBox(
                      width: isDesktop ? null : double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isSaving ? null : () => provider.loadHours(),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Actualiser depuis le serveur', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildAlertBox(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context, RestaurantDashboardProvider provider, bool isDesktop) {
    final infoColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Gestion des Horaires',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF0F172A)),
        ),
        SizedBox(height: 4),
        Text(
          'Configurez les périodes d\'ouverture de votre restaurant.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
      ],
    );

    final closeButton = FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: _isSaving ? null : () => _markClosedToday(provider),
      icon: const Icon(Icons.do_disturb_alt_rounded, size: 16),
      label: const Text('MARQUER FERMÉ AUJOURD\'HUI', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Expanded(child: infoColumn), const SizedBox(width: 24), closeButton],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [infoColumn, const SizedBox(height: 16), SizedBox(width: double.infinity, child: closeButton)],
    );
  }

  Widget _buildHorairesTable(
    BuildContext context,
    RestaurantDashboardProvider provider,
    List<Map<String, dynamic>> hours,
  ) {
    final sorted = List<Map<String, dynamic>>.from(hours)
      ..sort((a, b) => (a['dayOfWeek'] as int? ?? 0).compareTo(b['dayOfWeek'] as int? ?? 0));

    if (sorted.isEmpty) {
      return const Center(child: Text('Aucun horaire configuré.', style: TextStyle(color: AppColors.textSecondary)));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: const [
                Expanded(flex: 2, child: Text('JOUR', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF94A3B8)))),
                Expanded(flex: 2, child: Text('OUVERTURE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF94A3B8)))),
                Expanded(flex: 2, child: Text('FERMETURE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF94A3B8)))),
                Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: Text('STATUT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF94A3B8))))),
              ],
            ),
          ),
          const Divider(height: 1),
          ...sorted.map((entry) {
            final day = entry['dayOfWeek'] as int? ?? 0;
            final isClosed = entry['isClosed'] == true;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(provider.dayName(day), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          isClosed ? '--:--' : entry['opensAt']?.toString() ?? '--:--',
                          style: TextStyle(color: isClosed ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          isClosed ? '--:--' : entry['closesAt']?.toString() ?? '--:--',
                          style: TextStyle(color: isClosed ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: _isSaving ? null : () => _toggleDayClosed(provider, day),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                isClosed ? 'Fermé' : 'Ouvert',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: isClosed ? AppColors.primary : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isClosed ? Icons.check_circle_rounded : Icons.circle_outlined,
                                color: isClosed ? AppColors.primary : const Color(0xFFCBD5E1),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (day != sorted.last['dayOfWeek']) const Divider(height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAlertBox() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline_rounded, color: AppColors.primary),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Impact des modifications', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                SizedBox(height: 4),
                Text(
                  'Les changements apportés aux horaires seront immédiatement visibles pour les clients sur l\'application.',
                  style: TextStyle(color: Color(0xFF475569), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
