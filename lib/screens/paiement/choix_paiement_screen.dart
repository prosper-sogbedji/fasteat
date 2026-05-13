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

class ChoixPaiementScreen extends StatefulWidget {
  const ChoixPaiementScreen({super.key});

  @override
  State<ChoixPaiementScreen> createState() => _ChoixPaiementScreenState();
}

class _ChoixPaiementScreenState extends State<ChoixPaiementScreen> {
  late final TextEditingController _numeroCtrl;

  @override
  void initState() {
    super.initState();
    _numeroCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final flow = context.read<FlowProvider>();
    if (_numeroCtrl.text.isEmpty) {
      if (flow.numeroPaiement.isNotEmpty) {
        _numeroCtrl.text = flow.numeroPaiement;
      } else {
        _numeroCtrl.text = '+229 90 00 00 00';
      }
    }
  }

  @override
  void dispose() {
    _numeroCtrl.dispose();
    super.dispose();
  }

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
                  const Text('Numéro de paiement', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text(
                    'Saisissez le numéro qui sera débité (même numéro que votre compte Moov, MTN ou Celtis selon le mode choisi).',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _numeroCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Ex. 01 XX XX XX XX',
                      prefixIcon: Icon(Icons.phone_android_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                    leading: const Icon(Icons.account_balance_rounded, color: AppColors.primary),
                    title: const Text('Celtis Bénin', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Paiement via compte / service Celtis'),
                    trailing: flow.paiementMethode == PaiementMethode.carte
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFFE63946))
                        : const Icon(Icons.circle_outlined),
                  ),
                  const SizedBox(height: 12),
                  const Text('PAIEMENT 100% SECURISE PAR CHIFFREMENT SSL', style: TextStyle(fontSize: 11, color: Colors.black54, letterSpacing: 0.3)),
                  const SizedBox(height: 120),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final n = _numeroCtrl.text.replaceAll(RegExp(r'\s'), '');
                      if (n.length < 8) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Veuillez saisir un numéro de paiement valide.')),
                        );
                        return;
                      }
                      context.read<FlowProvider>().setNumeroPaiement(_numeroCtrl.text.trim());
                      context.push(AppRoutes.paiementProcessing);
                    },
                    child: Text('Confirmer et payer - ${fcfa(total)}'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
