import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/formatters.dart';

class CommandeConfirmeeScreen extends StatefulWidget {
  const CommandeConfirmeeScreen({super.key});

  @override
  State<CommandeConfirmeeScreen> createState() => _CommandeConfirmeeScreenState();
}

class _CommandeConfirmeeScreenState extends State<CommandeConfirmeeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Lire les paramètres passés en queryString depuis le router
  String _param(BuildContext ctx, String key, String fallback) {
    final uri = Uri.tryParse(GoRouterState.of(ctx).uri.toString());
    return uri?.queryParameters[key] ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final txId = _param(context, 'txId', '');
    final restoNom = Uri.decodeComponent(_param(context, 'resto', 'Le restaurant'));
    final totalStr = _param(context, 'total', '0');
    final total = int.tryParse(totalStr) ?? 0;

    // Générer un numéro de commande lisible s'il n'y a pas de txId
    final commandeRef = txId.isNotEmpty
        ? txId.substring(0, txId.length.clamp(0, 8)).toUpperCase()
        : '#FE-${DateTime.now().millisecondsSinceEpoch % 10000}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text('FASTEAT BÉNIN'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Icône ✓ animée
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7EE),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF2ECC71).withValues(alpha: 0.25), blurRadius: 20, spreadRadius: 4),
                  ],
                ),
                child: const Icon(Icons.check_rounded, size: 52, color: Color(0xFF2ECC71)),
              ),
            ),

            const SizedBox(height: 20),

            FadeTransition(
              opacity: _fade,
              child: Column(
                children: [
                  const Text(
                    'Commande confirmée !',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1D2939)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Votre commande est transmise à $restoNom.',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Numéro de commande
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFCE8EC), Color(0xFFFFF0F1)]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        const Text('Référence de commande', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          commandeRef,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Détails
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      children: [
                        _detailTile(Icons.restaurant_rounded, 'Restaurant', restoNom),
                        const Divider(height: 1, indent: 56),
                        _detailTile(Icons.payments_rounded, 'Montant payé', fcfa(total), valueStyle: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 16)),
                        if (txId.isNotEmpty) ...[
                          const Divider(height: 1, indent: 56),
                          _detailTile(Icons.receipt_long_rounded, 'ID Transaction', txId.length > 16 ? '${txId.substring(0, 16)}…' : txId),
                        ],
                        const Divider(height: 1, indent: 56),
                        _detailTile(Icons.verified_rounded, 'Statut', 'Paiement validé ✓', valueStyle: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Boutons d'action
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context.go(AppRoutes.activite),
                      icon: const Icon(Icons.track_changes_rounded),
                      label: const Text('Suivre ma commande', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go(AppRoutes.home),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Retour à l'accueil"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                Text(value, style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
