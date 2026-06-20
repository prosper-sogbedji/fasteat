import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/restaurant_menu_provider.dart';

class AccueilTab extends StatelessWidget {
  const AccueilTab({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;
    final double padding = isDesktop ? 32.0 : 16.0;
    final menuProvider = context.watch<RestaurantMenuProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isDesktop ? _buildStatsCards(menuProvider) : _buildStatsCardsMobile(menuProvider),
          SizedBox(height: padding),
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: _buildRecentOrdersTable(context, menuProvider)),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 3, 
                      child: Column(
                        children: [
                          _buildAlertsMessages(menuProvider),
                          const SizedBox(height: 24),
                          _buildPerformanceChart(menuProvider),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildRecentOrdersTable(context, menuProvider),
                    const SizedBox(height: 24),
                    _buildAlertsMessages(menuProvider),
                    const SizedBox(height: 24),
                    _buildPerformanceChart(menuProvider),
                  ],
                ),
        ],
      ),
    );
  }

  String _formatFcfa(int amount) {
    final s = amount.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      b.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) b.write(' ');
    }
    return '${b.toString()} FCFA';
  }

  Widget _buildStatsCardsMobile(RestaurantMenuProvider menuProvider) {
    final totalOrders = menuProvider.orders.length;
    final totalRevenue = menuProvider.orders.fold<int>(0, (sum, o) => sum + (o['total'] as int? ?? 0));
    final enAttente = menuProvider.orders.where((o) => o['status'] == 'NOUVEAU' || o['status'] == 'EN PRÉPARATION').length;

    return Column(
      children: [
        _buildStatCard(
          'COMMANDES REÇUES',
          '$totalOrders',
          Icons.shopping_cart_outlined,
          const Color(0xFFE0F2FE),
          const Color(0xFF0284C7),
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          "CHIFFRE D'AFFAIRES",
          _formatFcfa(totalRevenue),
          Icons.payments_outlined,
          const Color(0xFFDCFCE7),
          const Color(0xFF16A34A),
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          'EN ATTENTE',
          '$enAttente',
          Icons.timer_outlined,
          const Color(0xFFFEE2E2),
          const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildStatsCards(RestaurantMenuProvider menuProvider) {
    final totalOrders = menuProvider.orders.length;
    final totalRevenue = menuProvider.orders.fold<int>(0, (sum, o) => sum + (o['total'] as int? ?? 0));
    final enAttente = menuProvider.orders.where((o) => o['status'] == 'NOUVEAU' || o['status'] == 'EN PRÉPARATION').length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'COMMANDES REÇUES',
            '$totalOrders',
            Icons.shopping_cart_outlined,
            const Color(0xFFE0F2FE),
            const Color(0xFF0284C7),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildStatCard(
            "CHIFFRE D'AFFAIRES",
            _formatFcfa(totalRevenue),
            Icons.payments_outlined,
            const Color(0xFFDCFCE7),
            const Color(0xFF16A34A),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildStatCard(
            'EN ATTENTE',
            '$enAttente',
            Icons.timer_outlined,
            const Color(0xFFFEE2E2),
            const Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconBg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersTable(BuildContext context, RestaurantMenuProvider menuProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Commandes en Temps Réel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    _filterButton('Filtrer'),
                    const SizedBox(width: 8),
                    _filterButton('Exporter'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          if (menuProvider.orders.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey[200]),
                  const SizedBox(height: 16),
                  const Text('Aucune commande pour le moment', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.go('/plat-nouveau'),
                    icon: const Icon(Icons.restaurant_menu),
                    label: const Text('Commencer par configurer le Menu'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 750,
                child: Table(
                  columnWidths: const {
                    0: FixedColumnWidth(110), // N° COMMANDE
                    1: FlexColumnWidth(),    // CLIENT
                    2: FixedColumnWidth(150), // HEURE / MODE
                    3: FixedColumnWidth(110), // MONTANT
                    4: FixedColumnWidth(130), // STATUT
                    5: FixedColumnWidth(40),  // ALERT
                  },
                  border: const TableBorder(
                    horizontalInside: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                  ),
                  children: [
                    _tableHeaderRow(),
                    ...menuProvider.orders.take(5).map((o) {
                      final status = o['status'].toString();
                      Color bg = const Color(0xFFE0F2FE);
                      Color txt = const Color(0xFF0284C7);
                      if (status == 'NOUVEAU') {
                        bg = const Color(0xFFFEF3C7);
                        txt = const Color(0xFFD97706);
                      } else if (status == 'PRÊTE' || status == 'LIVRÉE') {
                        bg = const Color(0xFFDCFCE7);
                        txt = const Color(0xFF16A34A);
                      }
                      
                      final clientParts = o['client'].toString().split(' ');
                      String initials = '';
                      if (clientParts.isNotEmpty) {
                        initials += clientParts[0][0].toUpperCase();
                        if (clientParts.length > 1) initials += clientParts[1][0].toUpperCase();
                      }

                      return _orderTableRow(
                        o['id'],
                        o['client'].toString().replaceFirst(' ', '\\n'),
                        initials,
                        o['time'],
                        'LIVRAISON', // Simplified mode
                        _formatFcfa(o['total']).replaceFirst(' ', '\\n'),
                        status,
                        bg,
                        txt,
                        o['isPriority'] == true,
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
    );
  }

  TableRow _tableHeaderRow() {
    return TableRow(
      children: [
        _tableHeaderCell('N° COMMANDE'),
        _tableHeaderCell('CLIENT'),
        _tableHeaderCell('HEURE / MODE'),
        _tableHeaderCell('MONTANT'),
        _tableHeaderCell('STATUT'),
        _tableHeaderCell(''),
      ],
    );
  }

  Widget _tableHeaderCell(String label) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF64748B)),
      ),
    );
  }

  TableRow _orderTableRow(String id, String client, String initials, String time, String mode, String amount, String status, Color statusBg, Color statusColor, bool hasAlert) {
    return TableRow(
      children: [
        _tableCell(
          Text(id, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
        _tableCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 16, backgroundColor: const Color(0xFFE2E8F0), child: Text(initials, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF475569)))),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: client.split('\n').map((line) => Text(
                  line,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                )).toList(),
              ),
            ],
          ),
        ),
        _tableCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(time, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(4)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(mode == 'LIVRAISON' ? Icons.moped : Icons.event, size: 10, color: const Color(0xFF0284C7)),
                    const SizedBox(width: 4),
                    Text(mode, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                  ],
                ),
              ),
            ],
          ),
        ),
        _tableCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: amount.split('\n').map((line) => Text(
              line,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            )).toList(),
          ),
        ),
        _tableCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900)),
          ),
        ),
        _tableCell(
          hasAlert ? Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Text('!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
          ) : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _tableCell(Widget child) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  Widget _buildAlertsMessages(RestaurantMenuProvider menuProvider) {
    if (menuProvider.orders.isEmpty) {
      return const SizedBox.shrink(); // Hide alerts if no orders/new account
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text('Alertes et Messages', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rupture de Stock !', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 14)),
                      const SizedBox(height: 8),
                      const Text('L\'article "Pilon de Poulet Grillé" est épuisé. Mettre à jour le menu ?', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                      const SizedBox(height: 12),
                      Text('DÉSACTIVER L\'ARTICLE', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 11, decoration: TextDecoration.underline, decorationColor: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _messageRow('Samir Soglo', 'il y a 2m', 'Est-ce possible de rajouter...'),
                const SizedBox(height: 16),
                _messageRow('Marie Tchékpo', 'il y a 15m', 'Merci pour la livraison rapi...'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageRow(String name, String time, String preview) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 16, backgroundColor: const Color(0xFFF1F5F9), child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF475569)))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(preview, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text('RÉPONDRE', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceChart(RestaurantMenuProvider menuProvider) {
    if (menuProvider.orders.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Performance Horaire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _bar(40, '10h', false),
              _bar(80, '12h', false),
              _bar(120, '14h', true),
              _bar(60, '16h', false),
              _bar(30, '18h', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar(double height, String label, bool isPeak) {
    return Column(
      children: [
        Container(
          width: 24,
          height: height,
          decoration: BoxDecoration(
            color: isPeak ? AppColors.primary : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
      ],
    );
  }
}
