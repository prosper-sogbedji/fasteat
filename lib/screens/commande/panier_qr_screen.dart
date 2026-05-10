import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/flow_provider.dart';
import '../../providers/panier_provider.dart';
import '../../widgets/common/formatters.dart';

class PanierQrScreen extends StatelessWidget {
  const PanierQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final panier = context.watch<PanierProvider>();
    final flow = context.watch<FlowProvider>();
    final total = panier.sousTotal;
    return Scaffold(
      appBar: AppBar(title: const Text('Votre panier (QR)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Table détectée : ${flow.codeTableQr}', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...panier.lignes.map(
            (l) => ListTile(
              title: Text(l.plat.nom),
              subtitle: Text(fcfa(l.plat.prix)),
              trailing: Text('x${l.quantite}'),
            ),
          ),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total'), Text(fcfa(total), style: const TextStyle(fontWeight: FontWeight.w700))]),
          const SizedBox(height: 14),
          FilledButton(onPressed: () => context.push('/paiement/choix'), child: const Text('Proceder au paiement')),
        ],
      ),
    );
  }
}
