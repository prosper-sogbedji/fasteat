import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class MesInfosScreen extends StatefulWidget {
  const MesInfosScreen({super.key});

  @override
  State<MesInfosScreen> createState() => _MesInfosScreenState();
}

class _MesInfosScreenState extends State<MesInfosScreen> {
  final nomCtrl = TextEditingController(text: 'Koffi Mensah');
  final telCtrl = TextEditingController(text: '+229 90 00 00 00');
  bool notifCommandes = true;
  bool notifPromos = false;
  bool livraisonSilencieuse = false;
  bool darkMode = false;

  @override
  void dispose() {
    nomCtrl.dispose();
    telCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes infos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom complet')),
          const SizedBox(height: 12),
          TextField(
            controller: telCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Téléphone'),
          ),
          const SizedBox(height: 28),
          const Text('Paramètres', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
            'Gérez les notifications, préférences de paiement et confidentialité.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Notifications commandes'),
                  subtitle: const Text('Statut de préparation, livraison, annulations'),
                  value: notifCommandes,
                  onChanged: (v) => setState(() => notifCommandes = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Offres et promotions'),
                  subtitle: const Text('Réductions partenaires et codes promo'),
                  value: notifPromos,
                  onChanged: (v) => setState(() => notifPromos = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Mode discret livraison'),
                  subtitle: const Text('Masquer le nom du restaurant sur l’écran de suivi (mock)'),
                  value: livraisonSilencieuse,
                  onChanged: (v) => setState(() => livraisonSilencieuse = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Mode sombre'),
                  subtitle: const Text('Activer le thème sombre (mock)'),
                  value: darkMode,
                  onChanged: (v) => setState(() => darkMode = v),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Langue de l’application'),
                  subtitle: const Text('Français'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Choix de langue : bientôt disponible.')),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Confidentialité et données'),
                  subtitle: const Text('Politique, export des données (mock)'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 120),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Informations enregistrées (simulation).')),
              );
            },
            child: const Text('Enregistrer'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
