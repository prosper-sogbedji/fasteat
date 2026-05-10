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
  final identifiantCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  void dispose() {
    identifiantCtrl.dispose();
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
                    const Text('Numéro de téléphone ou Email', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: identifiantCtrl,
                      decoration: InputDecoration(
                        hintText: '01 00 00 00 00 ou email@exemple.com',
                        prefixIcon: Icon(Icons.person_outline, size: 18),
                      ),
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
                        final identifiant = identifiantCtrl.text.trim();
                        final pass = passwordCtrl.text.trim();
                        final isEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(identifiant);
                        final isPhone = RegExp(r'^[0-9+\s]{8,}$').hasMatch(identifiant);
                        if (!isEmail && !isPhone) {
                          _showError('Veuillez saisir un email ou numero valide.');
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
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('OU', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black54)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.g_mobiledata_rounded, color: Color(0xFFEA4335)),
                            label: const Text('Google'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1877F2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {},
                            icon: const Icon(Icons.facebook, size: 16),
                            label: const Text('Facebook'),
                          ),
                        ),
                      ],
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
