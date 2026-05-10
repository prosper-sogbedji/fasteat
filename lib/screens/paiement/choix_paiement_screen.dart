import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../models/commande.dart';
import '../../providers/flow_provider.dart';
import '../../providers/panier_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/formatters.dart';
import '../../widgets/paiement/moov_button.dart';
import '../../widgets/paiement/mtn_button.dart';

class ChoixPaiementScreen extends StatelessWidget {
  const ChoixPaiementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<FlowProvider>();
    final panier = context.watch<PanierProvider>();
    final total = panier.sousTotal + (flow.modeCommande == ModeCommande.livraison ? flow.fraisLivraison : 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Paiement'), centerTitle: true),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Recapitulatif', style: TextStyle(fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFFCE8EC), borderRadius: BorderRadius.circular(10)),
                                child: const Text('EN ATTENTE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFC8102E))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Sous-total'), Text(fcfa(panier.sousTotal))]),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Frais de livraison'), Text(fcfa(flow.modeCommande == ModeCommande.livraison ? flow.fraisLivraison : 0))]),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('TOTAL A PAYER', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(fcfa(total), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC8102E), fontSize: 18)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Mode de paiement', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 8),
                  MtnButton(selected: flow.paiementMethode == PaiementMethode.mtn, onTap: () => context.read<FlowProvider>().setPaiement(PaiementMethode.mtn)),
                  const SizedBox(height: 8),
                  MoovButton(selected: flow.paiementMethode == PaiementMethode.moov, onTap: () => context.read<FlowProvider>().setPaiement(PaiementMethode.moov)),
                  const SizedBox(height: 8),
                  ListTile(
                    onTap: () => context.read<FlowProvider>().setPaiement(PaiementMethode.carte),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    tileColor: Colors.white,
                    title: const Text('Carte Bancaire', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Visa / Mastercard'),
                    trailing: flow.paiementMethode == PaiementMethode.carte
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFFE63946))
                        : const Icon(Icons.circle_outlined),
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 14),
                  const Text('PAIEMENT 100% SECURISE PAR CHIFFREMENT SSL', style: TextStyle(fontSize: 11, color: Colors.black54, letterSpacing: 0.3)),
                  const SizedBox(height: 18),
                  FilledButton(
                    style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: () => context.push(AppRoutes.paiementProcessing),
                    child: Text('Confirmer et payer - ${fcfa(total)}'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
