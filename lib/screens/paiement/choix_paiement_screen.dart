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
  static const bool _demoMode = bool.fromEnvironment(
    'FASTEAT_DEMO',
    defaultValue: false,
  );

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
      AppFeedback.info(
        context,
        'Veuillez saisir un numéro de téléphone valide.',
      );
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

    final frais = flow.modeConsommation == ModeConsommation.livraison
        ? flow.fraisLivraison
        : 0;
    final resto = restos.restaurantById(lignes.first.plat.restoId);

    setState(() => _isProcessing = true);
    await flow.setNumeroPaiement(phone);

    var synced = false;
    if (!_demoMode) {
      synced = await commandes.checkoutDepuisPanier(
        flow: flow,
        paiement:
            flow.paiementMethode, // La détection auto se fera côté backend
        numeroPaiement: phone,
      );
    }

    if (!mounted) return;

    if (!synced && !_demoMode) {
      setState(() => _isProcessing = false);
      AppFeedback.error(
        context,
        'Paiement non confirmé. Le panier est conservé, veuillez réessayer.',
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
    final frais = flow.modeConsommation == ModeConsommation.livraison
        ? flow.fraisLivraison
        : 0;
    final total = panier.sousTotal + frais;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Paiement',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RecapitulatifPaiement(
                    panier: panier,
                    frais: frais,
                    total: total,
                  ),
                  const SizedBox(height: 24),

                  // Titre de section propre
                  const Text(
                    'Numéro de facturation',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    ' ',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Champ numéro premium
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ex: 22961000000',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: const Icon(
                          Icons.phone_android_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Si mode démo actif, on affiche uniquement le notice de démo
                  if (_demoMode) ...[
                    const SizedBox(height: 24),
                    _SecurityNotice(demoMode: true),
                  ],

                  SizedBox(height: keyboard > 0 ? keyboard : 24),
                ],
              ),
            ),
          ),

          // Bouton payer en bas de l'écran
          SafeArea(
            top: false,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, keyboard > 0 ? 12 : 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isProcessing ? null : _confirmerPaiement,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Confirmer et payer — ${fcfa(total)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Récapitulatif',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...panier.lignes.map(
            (l) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${l.quantite}x',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.plat.nom,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    fcfa(l.total),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (frais > 0) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Frais de livraison',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  fcfa(frais),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total à payer',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              Text(
                fcfa(total),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecurityNotice extends StatelessWidget {
  const _SecurityNotice({required this.demoMode});

  final bool demoMode;

  @override
  Widget build(BuildContext context) {
    if (!demoMode) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mode DEMO actif : aucune transaction ne sera débitée.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFD97706),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
