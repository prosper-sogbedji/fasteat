import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../core/app_mode.dart';
import '../../providers/restaurants_provider.dart';
import '../../theme/app_theme.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  bool notifCommandes = true;
  bool notifPromos = false;
  bool modeSombre = false;
  bool geolocalisation = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paramètres', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Suivi de commande', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Préparation, livraison, annulations', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  value: notifCommandes,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setState(() => notifCommandes = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Offres et promotions', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Bons plans et réductions exclusives', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  value: notifPromos,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setState(() => notifPromos = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Préférences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Mode sombre', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: modeSombre,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setState(() => modeSombre = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Géolocalisation', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Pour trouver les restaurants à proximité', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  value: geolocalisation,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setState(() => geolocalisation = v),
                ),
              ],
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 24),
            const Text('Développement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Mode Démo', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Utiliser des données mockées au lieu de l\'API', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    value: AppMode.isDemoMode,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) {
                      AppMode.setDemoMode(enabled: v);
                      context.read<RestaurantsProvider>().reloadMode();
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
