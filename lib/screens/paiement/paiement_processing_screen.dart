import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app_routes.dart';
import '../../models/commande.dart';
import '../../providers/commandes_provider.dart';
import '../../providers/flow_provider.dart';
import '../../providers/panier_provider.dart';

import '../../theme/app_theme.dart';

class PaiementProcessingScreen extends StatefulWidget {
  const PaiementProcessingScreen({super.key});

  @override
  State<PaiementProcessingScreen> createState() => _PaiementProcessingScreenState();
}

class _PaiementProcessingScreenState extends State<PaiementProcessingScreen> {
  bool _processed = false;

  @override
  void initState() {
    super.initState();
    _processThenNavigate();
  }

  Future<void> _processThenNavigate() async {
    if (_processed) return;
    _processed = true;
    final panier = context.read<PanierProvider>();
    final flow = context.read<FlowProvider>();
    final commandes = context.read<CommandesProvider>();

    final lignes = panier.lignes;
    DateTime? heureSouhaitee;
    if (flow.modeCommande == ModeCommande.programmee) {
      final parts = flow.heureRecuperation.split(':');
      if (parts.length == 2) {
        final now = DateTime.now();
        final hh = int.tryParse(parts[0]);
        final mm = int.tryParse(parts[1]);
        if (hh != null && mm != null) {
          heureSouhaitee = DateTime(now.year, now.month, now.day, hh, mm);
        }
      }
    }
    await commandes.placerDepuisPanier(
      lignes: lignes,
      mode: flow.modeCommande,
      fraisLivraison: flow.modeCommande == ModeCommande.livraison ? flow.fraisLivraison : 0,
      heureRecuperationSouhaitee: heureSouhaitee,
    );
    await panier.vider();

    Timer(const Duration(seconds: 2), () {
      if (mounted) context.go(AppRoutes.commandeConfirmee);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FASTEAT BENIN'),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () => context.go(AppRoutes.home), icon: const Icon(Icons.close_rounded)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _square(const Color(0xFFFACC15), Icons.phone_android_rounded),
                const SizedBox(width: 10),
                _square(const Color(0xFF1D4ED8), Icons.account_balance_wallet_outlined),
              ],
            ),
            const SizedBox(height: 36),
            const SizedBox(width: 44, height: 44, child: CircularProgressIndicator(strokeWidth: 3)),
            const SizedBox(height: 18),
            const Text('Validation Mobile Money en cours...', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 21), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
              child: const Text(
                'Veuillez valider la transaction sur votre telephone',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const Spacer(),
            const Icon(Icons.phone_iphone_rounded, size: 84, color: Color(0xFFD1D5DB)),
            const SizedBox(height: 12),
            const Text('PAIEMENT SECURISE', style: TextStyle(letterSpacing: 1, fontSize: 11, color: Colors.black45)),
            const SizedBox(height: 8),
            const Text(
              'Ne fermez pas cette fenetre avant la fin de la validation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _square(Color c, IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }
}
