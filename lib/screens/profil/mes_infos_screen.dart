import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class MesInfosScreen extends StatefulWidget {
  const MesInfosScreen({super.key});

  @override
  State<MesInfosScreen> createState() => _MesInfosScreenState();
}

class _MesInfosScreenState extends State<MesInfosScreen> {
  late final TextEditingController nomCtrl;
  late final TextEditingController telCtrl;
  late final TextEditingController emailCtrl;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final user = context.read<AuthProvider>().currentUser;
    nomCtrl = TextEditingController(text: user.nom);
    telCtrl = TextEditingController(text: user.telephone);
    emailCtrl = TextEditingController(text: user.email);
  }

  @override
  void dispose() {
    if (_initialized) {
      nomCtrl.dispose();
      telCtrl.dispose();
      emailCtrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes infos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!auth.isConnected)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Connectez-vous pour synchroniser vos informations avec le serveur.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom complet')),
          const SizedBox(height: 12),
          TextField(
            controller: telCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Téléphone',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final nom = nomCtrl.text.trim();
              if (nom.length < 3) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    icon: const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF7700), size: 40),
                    title: const Text('Nom invalide', style: TextStyle(fontWeight: FontWeight.w800)),
                    content: const Text('Votre nom doit contenir au moins 3 caractères.', textAlign: TextAlign.center),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: [
                      FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: FilledButton.styleFrom(minimumSize: const Size(120, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                return;
              }
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 40),
                  title: const Text('Enregistré !', style: TextStyle(fontWeight: FontWeight.w800)),
                  content: const Text('Vos préférences ont été sauvegardées.', textAlign: TextAlign.center),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: FilledButton.styleFrom(minimumSize: const Size(120, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Enregistrer les modifications'),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // Action déconnexion
              context.read<AuthProvider>().logout();
              Navigator.of(context).pop();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // Action suppression de compte
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Supprimer mon compte', style: TextStyle(fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
