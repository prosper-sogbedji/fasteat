import 'package:flutter/material.dart';
import 'package:fast_eat/widgets/common/app_feedback.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../models/commande.dart';
import '../../providers/commandes_provider.dart';
import '../../providers/flow_provider.dart';
import '../../providers/panier_provider.dart';
import '../../providers/restaurants_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/formatters.dart';

class ChoixPaiementScreen extends StatefulWidget {
  const ChoixPaiementScreen({super.key});

  @override
  State<ChoixPaiementScreen> createState() => _ChoixPaiementScreenState();
}

class _ChoixPaiementScreenState extends State<ChoixPaiementScreen> {
  static const bool _demoMode = bool.fromEnvironment('FASTEAT_DEMO', defaultValue: false);

  bool _isProcessing = false;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    final flow = context.read<FlowProvider>();
    _phoneCtrl = TextEditingController(text: flow.numeroPaiement);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmerPaiement() async {
    final phone = _normalizePhone(_phoneCtrl.text);
    if (phone.length < 8) {
      AppFeedback.info(context, 'Veuillez saisir un numero de telephone valide.');
      return;
    }

    final panier = context.read<PanierProvider>();
    final flow = context.read<FlowProvider>();
    final commandes = context.read<CommandesProvider>();
    final restos = context.read<RestaurantsProvider>();
    final lignes = panier.lignes;

    if (lignes.isEmpty) {
      AppFeedback.error(context, 'Votre panier est vide.');
      return;
    }

    final frais = flow.modeConsommation == ModeConsommation.livraison ? flow.fraisLivraison : 0;
    final resto = restos.restaurantById(lignes.first.plat.restoId);

    setState(() => _isProcessing = true);
    await flow.setNumeroPaiement(phone);

    var synced = false;
    if (!_demoMode) {
      synced = await commandes.checkoutDepuisPanier(
        flow: flow,
        paiement: flow.paiementMethode,
        numeroPaiement: phone,
      );
    }

    if (!mounted) return;

    if (!synced && !_demoMode) {
      setState(() => _isProcessing = false);
      AppFeedback.error(
        context,
        'Paiement non confirme. Le panier est conserve, veuillez reessayer.',
      );
      return;
    }

    if (_demoMode) {
      await commandes.placerDepuisPanier(
        lignes: lignes,
        mode: flow.modeCommande,
        fraisLivraison: frais,
        restaurantId: resto.id,
        restaurantNom: resto.nom,
      );
    }

    await panier.vider();
    if (!mounted) return;

    setState(() => _isProcessing = false);
    context.go(AppRoutes.commandeConfirmee);
  }

  String _normalizePhone(String raw) {
    return raw.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<FlowProvider>();
    final panier = context.watch<PanierProvider>();
    final frais = flow.modeConsommation == ModeConsommation.livraison ? flow.fraisLivraison : 0;
    final total = panier.sousTotal + frais;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('Paiement'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RecapitulatifPaiement(panier: panier, frais: frais, total: total),
                  const SizedBox(height: 20),
                  const Text('Operateur Mobile Money', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _OperatorChoice(
                        label: 'MTN',
                        subtitle: 'Mobile Money',
                        color: AppColors.mtnMoMo,
                        selected: flow.paiementMethode == PaiementMethode.mtn,
                        onTap: () => context.read<FlowProvider>().setPaiement(PaiementMethode.mtn),
                      ),
                      const SizedBox(width: 10),
                      _OperatorChoice(
                        label: 'MOOV',
                        subtitle: 'Money',
                        color: AppColors.moovMoney,
                        selected: flow.paiementMethode == PaiementMethode.moov,
                        onTap: () => context.read<FlowProvider>().setPaiement(PaiementMethode.moov),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Numero a debiter', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text(
                    'Saisissez le numero correspondant a l\'operateur selectionne.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Ex. 22961000000',
                      prefixIcon: const Icon(Icons.phone_android_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SecurityNotice(demoMode: _demoMode),
                  SizedBox(height: keyboard > 0 ? keyboard : 8),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, keyboard > 0 ? 8 : 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isProcessing ? null : _confirmerPaiement,
                  child: _isProcessing
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text(
                          'Confirmer et payer - ${fcfa(total)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecapitulatifPaiement extends StatelessWidget {
  const _RecapitulatifPaiement({
    required this.panier,
    required this.frais,
    required this.total,
  });

  final PanierProvider panier;
  final int frais;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recapitulatif', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            ...panier.lignes.map(
              (l) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('${l.quantite} x ${l.plat.nom}', style: const TextStyle(fontSize: 13))),
                    Text(fcfa(l.total), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            if (frais > 0) ...[
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Frais de livraison', style: TextStyle(fontSize: 13)),
                  Text(fcfa(frais), style: const TextStyle(fontSize: 13)),
                ],
              ),
            ],
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL A PAYER', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                Text(fcfa(total), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 20)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OperatorChoice extends StatelessWidget {
  const _OperatorChoice({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.16) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? color : AppColors.border, width: selected ? 1.6 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(Icons.phone_android_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: selected ? color : AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityNotice extends StatelessWidget {
  const _SecurityNotice({required this.demoMode});

  final bool demoMode;

  @override
  Widget build(BuildContext context) {
    final color = demoMode ? const Color(0xFFF59E0B) : const Color(0xFF16A34A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(demoMode ? Icons.info_outline_rounded : Icons.lock_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              demoMode
                  ? 'Mode DEMO actif : aucune transaction reelle ne sera debitee.'
                  : 'Paiement securise via le backend FastEat. Validez la transaction sur votre telephone.',
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
