import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/restaurant_menu_provider.dart';

class CommandesTab extends StatelessWidget {
  const CommandesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Gestion des commandes',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF1A1A1A)),
          ),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey[400],
            indicatorColor: AppColors.primary,
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            tabs: const [
              Tab(text: 'En cours'),
              Tab(text: 'Prêtes'),
              Tab(text: 'Historique'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OrderListView(type: 'en_cours'),
            _OrderListView(type: 'pretes'),
            _OrderListView(type: 'historique'),
          ],
        ),
      ),
    );
  }
}

class _OrderListView extends StatelessWidget {
  final String type;
  const _OrderListView({required this.type});

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<RestaurantMenuProvider>();
    final allOrders = menuProvider.orders;

    // Filtrer les commandes selon le statut :
    // - en_cours : NOUVEAU, PREPARATION
    // - pretes : PRÊTE
    // - historique : LIVRÉE
    final List<Map<String, dynamic>> filteredOrders = allOrders.where((order) {
      final status = order['status']?.toString().toUpperCase() ?? 'NOUVEAU';
      if (type == 'en_cours') {
        return status == 'NOUVEAU' || status == 'PREPARATION';
      } else if (type == 'pretes') {
        return status == 'PRÊTE' || status == 'PRETE';
      } else {
        return status == 'LIVRÉE' || status == 'LIVREE';
      }
    }).toList();

    if (menuProvider.isLoadingOrders) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredOrders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'Aucune commande dans cette catégorie.',
            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _OrderCard(order: order, type: type);
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final String type;
  const _OrderCard({required this.order, required this.type});

  void _marquerPrete(BuildContext context, String orderId) async {
    final provider = context.read<RestaurantMenuProvider>();
    final success = await provider.changerStatutCommande(orderId, 'PRÊTE');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'La commande #$orderId est maintenant PRÊTE et déplacée.'
                : 'Erreur lors du changement de statut.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _ouvrirTicketDialog(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ticket #${order['id']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order['status'].toString(),
                  style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w900, fontSize: 10),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFFF0F2F5),
                        child: Icon(Icons.person, size: 16, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Text(order['client'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  const Text('ARTICLES COMMANDÉS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  ...List.generate((order['items'] as List).length, (i) {
                    final item = order['items'][i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text('${item['qty']}x', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(item['name'].toString(), style: const TextStyle(fontWeight: FontWeight.w500))),
                          Text('${item['price'] * item['qty']} F', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    );
                  }),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total à payer', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      Text('${order['total']} F', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('PAIEMENT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFFCC00), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('MTN MoMo', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: const Text('PAYÉ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 8)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('LIVREUR ASSIGNÉ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundImage: AssetImage('assets/images/resto_real_2.jpg'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Sekou Diallo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text('Moto • BJ-7291', style: TextStyle(color: Colors.grey, fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => Navigator.pop(context),
              child: const Text('FERMER', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#${order['id']}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                        if (order['isPriority'] == true) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'PRIORITAIRE',
                              style: TextStyle(color: Colors.red[700], fontSize: 10, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ],
                    ),
                    _StatusBadge(status: order['status']),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFFF0F2F5),
                      child: Icon(Icons.person, color: Colors.grey, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order['client'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(order['time'], style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 20),
                ...List.generate((order['items'] as List).length, (i) {
                  final item = order['items'][i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text('${item['qty']}x', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item['name'],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('${item['price'] * item['qty']} F', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isNarrow = constraints.maxWidth < 400;
                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total à percevoir', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          Text(
                            '${order['total']} F',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF1A1A1A)),
                          ),
                        ],
                      ),
                      if (type == 'en_cours') ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _ouvrirTicketDialog(context, order),
                              child: const Text('Détails', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _marquerPrete(context, order['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: const Text('Prête', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total à percevoir', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        Text(
                          '${order['total']} F',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF1A1A1A)),
                        ),
                      ],
                    ),
                    if (type == 'en_cours')
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => _ouvrirTicketDialog(context, order),
                            child: const Text('Détails', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _marquerPrete(context, order['id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text('Prête', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toUpperCase()) {
      case 'NOUVEAU':
        color = Colors.blue;
        break;
      case 'PREPARATION':
      case 'PRÉPARATION':
        color = Colors.orange;
        break;
      case 'PRÊTE':
      case 'PRETE':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }
}
