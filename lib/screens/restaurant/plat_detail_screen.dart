import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/plat.dart';
import '../../providers/panier_provider.dart';
import '../../providers/restaurants_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/formatters.dart';
import '../../widgets/common/image_fallback.dart';

class PlatDetailScreen extends StatefulWidget {
  const PlatDetailScreen({super.key, required this.platId});
  final String platId;

  @override
  State<PlatDetailScreen> createState() => _PlatDetailScreenState();
}

class _PlatDetailScreenState extends State<PlatDetailScreen> {
  int qte = 1;
  String accompaniment = 'Atassi Traditionnel';

  @override
  Widget build(BuildContext context) {
    final plat = context.watch<RestaurantsProvider>().platParId(widget.platId);

    if (plat == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail du plat'), centerTitle: true),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'Ce plat est indisponible pour le moment.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final total = plat.prix * qte;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail du plat'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          Stack(
            children: [
              ImageFallback(path: plat.image, label: plat.nom, height: 250, radius: 12),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Text(fcfa(plat.prix), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(plat.nom, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(plat.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.35)),
          const SizedBox(height: 16),
          const Text('Choisir l\'accompagnement', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _accompagnementItem('Atassi Traditionnel'),
          const SizedBox(height: 8),
          _accompagnementItem('Aloko (Plantain)'),
          const SizedBox(height: 8),
          _accompagnementItem('Riz Blanc Parfume'),
          const SizedBox(height: 16),
          const Text('Quantite', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(onPressed: qte > 1 ? () => setState(() => qte--) : null, icon: const Icon(Icons.remove)),
                    Text('$qte', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    IconButton(onPressed: () => setState(() => qte++), icon: const Icon(Icons.add)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              final panier = context.read<PanierProvider>();
              try {
                for (int i = 0; i < qte; i++) {
                  await panier.ajouterPlat(plat);
                }
                if (context.mounted) Navigator.pop(context);
              } on CrossRestaurantException catch (_) {
                if (context.mounted) {
                  _showCrossRestaurantDialog(context, panier, plat);
                }
              }
            },
            child: Text('Ajouter au panier - ${fcfa(total)}'),
          ),
        ],
      ),
    );
  }

  Widget _accompagnementItem(String label) {
    final isSelected = label == accompaniment;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => accompaniment = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showCrossRestaurantDialog(BuildContext context, PanierProvider panier, Plat plat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vider le panier ?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Vous avez déjà des articles d\'un autre restaurant. Voulez-vous vider votre panier actuel pour commander ici ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await panier.vider();
              for (int i = 0; i < qte; i++) {
                await panier.ajouterPlat(plat);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Vider et Ajouter'),
          ),
        ],
      ),
    );
  }
}

