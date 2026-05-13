import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class ConnexionScreen extends StatefulWidget {
  const ConnexionScreen({super.key});

  @override
  State<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  bool hide = true;
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  void dispose() {
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(title: const Text('Connexion')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE8EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 8),
                const Text('FASTEAT BÉNIN', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
              ],
            ),
            Card(
              margin: const EdgeInsets.only(top: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bon retour parmi nous',
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, height: 1),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Connectez-vous pour commander vos plats preferes en un clic.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 18),
                    const Text('Numéro de téléphone', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text('+229', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: '90 00 00 00',
                              prefixIcon: Icon(Icons.phone_android_rounded, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Mot de passe', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: passwordCtrl,
                      obscureText: hide,
                      decoration: InputDecoration(
                        hintText: '********',
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => hide = !hide),
                          icon: Icon(hide ? Icons.visibility_off : Icons.visibility, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push(AppRoutes.otp),
                        child: const Text('Mot de passe oublié ?'),
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final digits = phoneCtrl.text.replaceAll(RegExp(r'\s'), '');
                        final pass = passwordCtrl.text.trim();
                        final isPhone = RegExp(r'^[0-9]{8,10}$').hasMatch(digits);
                        if (!isPhone) {
                          _showError('Veuillez saisir un numéro valide (8 à 10 chiffres après +229).');
                          return;
                        }
                        if (pass.length < 6) {
                          _showError('Le mot de passe doit contenir au moins 6 caracteres.');
                          return;
                        }
                        context.read<AuthProvider>().loginMock();
                        context.go(AppRoutes.home);
                      },
                      child: const Text('Se connecter'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Nouveau sur FastEat ?'),
                TextButton(onPressed: () => context.push(AppRoutes.inscription), child: const Text('Créer un compte')),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Aide', style: TextStyle(fontSize: 12, color: Colors.black54)),
                Text('Confidentialité', style: TextStyle(fontSize: 12, color: Colors.black54)),
                Text('Conditions', style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
