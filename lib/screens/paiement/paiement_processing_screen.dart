import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app_routes.dart';
import '../../models/commande.dart';
import '../../providers/auth_provider.dart';
import '../../providers/commandes_provider.dart';
import '../../providers/flow_provider.dart';
import '../../providers/panier_provider.dart';
import '../../providers/restaurants_provider.dart';
import '../../theme/app_theme.dart';

class PaiementProcessingScreen extends StatefulWidget {
  const PaiementProcessingScreen({super.key});

  @override
  State<PaiementProcessingScreen> createState() => _PaiementProcessingScreenState();
}

class _PaiementProcessingScreenState extends State<PaiementProcessingScreen> {
  bool _processed = false;
  String? _error;

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
    final auth = context.read<AuthProvider>();
    final restos = context.read<RestaurantsProvider>();

    final lignes = panier.lignes;
    if (lignes.isEmpty) {
      setState(() => _error = 'Votre panier est vide.');
      return;
    }

    final first = lignes.first.plat;
    final resto = restos.restaurantById(first.restoId);

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

    var success = false;
    if (auth.isConnected) {
      success = await commandes.checkoutDepuisPanier(
        flow: flow,
        paiement: flow.paiementMethode,
        numeroPaiement: flow.numeroPaiement,
      );
    }

    if (!success) {
      await commandes.placerDepuisPanier(
        lignes: lignes,
        mode: flow.modeCommande,
        fraisLivraison: flow.modeCommande == ModeCommande.livraison ? flow.fraisLivraison : 0,
        restaurantId: resto.id,
        restaurantNom: resto.nom,
        heureRecuperationSouhaitee: heureSouhaitee,
      );
      if (auth.isConnected && mounted) {
        setState(() => _error = 'Paiement enregistré en local. Vérifiez votre connexion réseau.');
      }
    }

    await panier.vider();
    if (!mounted) return;

    Timer(const Duration(seconds: 2), () {
      if (mounted) context.go(AppRoutes.commandeConfirmee);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FASTEAT BENIN'),
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
            const Text(
              'Validation Mobile Money en cours...',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 21),
              textAlign: TextAlign.center,
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
              child: const Text(
                'Veuillez valider la transaction sur votre téléphone',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const Spacer(),
            const Icon(Icons.phone_iphone_rounded, size: 84, color: Color(0xFFD1D5DB)),
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
