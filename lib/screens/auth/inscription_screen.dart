import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_routes.dart';
import '../../theme/app_theme.dart';

class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  int step = 0;
  bool hidePassword = true;
  bool hidePasswordConfirm = true;
  final nomCtrl = TextEditingController();
  final prenomCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final passConfirmCtrl = TextEditingController();
  String sexe = 'Masculin';

  @override
  void dispose() {
    nomCtrl.dispose();
    prenomCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    passConfirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
        children: [
          const Text(
            'Bienvenus!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Container(
            height: 42,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => context.go(AppRoutes.connexion),
                    child: const Center(
                      child: Text('Connexion', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('Inscription', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (step == 0) ..._stepInfos(),
          if (step == 1) ..._stepImageProfil(),
          if (step == 2) ..._stepPassword(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dot(0),
              const SizedBox(width: 8),
              _dot(1),
              const SizedBox(width: 8),
              _dot(2),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: step == 0 ? () => context.go(AppRoutes.connexion) : () => setState(() => step--),
                  child: Text(step == 0 ? 'Annuler' : 'Retour'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _onPrimary,
                  child: Text(step == 0 ? 'Suivant' : step == 1 ? 'Ignorer' : "S'inscrire"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Other sign in options',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialIcon(icon: Icons.facebook, color: Color(0xFF1877F2)),
              SizedBox(width: 12),
              _SocialIcon(icon: Icons.g_mobiledata_rounded, color: Color(0xFFEA4335)),
              SizedBox(width: 12),
              _SocialIcon(icon: Icons.apple, color: Colors.black),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _stepInfos() {
    return [
      _LabelField(label: 'Nom', hint: 'Entrez votre nom', controller: nomCtrl),
      const SizedBox(height: 10),
      _LabelField(label: 'Prenoms', hint: 'Entrez vos prenoms', controller: prenomCtrl),
      const SizedBox(height: 10),
      const Align(alignment: Alignment.centerLeft, child: Text('Sexe', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        initialValue: sexe,
        items: const [
          DropdownMenuItem(value: 'Masculin', child: Text('Masculin')),
          DropdownMenuItem(value: 'Feminin', child: Text('Feminin')),
        ],
        onChanged: (v) => setState(() => sexe = v ?? 'Masculin'),
        decoration: const InputDecoration(hintText: 'Choisir le sexe'),
      ),
      const SizedBox(height: 10),
      _LabelField(label: 'Adresse mail', hint: 'nomprenom@gmail.com', controller: emailCtrl),
      const SizedBox(height: 10),
      _LabelField(label: 'Telephone', hint: 'Entrez votre numero de telephone', controller: phoneCtrl),
    ];
  }

  List<Widget> _stepImageProfil() {
    return const [
      SizedBox(height: 20),
      Center(
        child: CircleAvatar(
          radius: 68,
          backgroundColor: Color(0xFFE8F0FF),
          child: Icon(Icons.add_photo_alternate_outlined, size: 44, color: Color(0xFF246BFD)),
        ),
      ),
      SizedBox(height: 16),
      Text(
        'Importez une image de profil',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475467)),
      ),
      SizedBox(height: 44),
    ];
  }

  List<Widget> _stepPassword() {
    return [
      _LabelField(
        label: 'Mot de passe',
        hint: 'Entrez votre mot de passe',
        controller: passCtrl,
        obscureText: hidePassword,
        suffix: IconButton(
          onPressed: () => setState(() => hidePassword = !hidePassword),
          icon: Icon(hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
        ),
      ),
      const SizedBox(height: 10),
      _LabelField(
        label: 'Confirmer mot de passe',
        hint: 'Entrez votre mot de passe',
        controller: passConfirmCtrl,
        obscureText: hidePasswordConfirm,
        suffix: IconButton(
          onPressed: () => setState(() => hidePasswordConfirm = !hidePasswordConfirm),
          icon: Icon(hidePasswordConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
        ),
      ),
      const SizedBox(height: 40),
    ];
  }

  Widget _dot(int i) {
    final active = i == step;
    return Container(
      width: active ? 24 : 14,
      height: 4,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF246BFD) : const Color(0xFFE4E7EC),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _onPrimary() {
    if (step == 0) {
      final nom = nomCtrl.text.trim();
      final prenom = prenomCtrl.text.trim();
      final phone = phoneCtrl.text.trim();
      final email = emailCtrl.text.trim();
      final isEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
      final isPhone = RegExp(r'^[0-9+\s]{8,}$').hasMatch(phone);
      if ([nom, prenom, phone, email].any((e) => e.isEmpty)) {
        _showError('Veuillez remplir tous les champs.');
        return;
      }
      if (!isPhone) {
        _showError('Numero de telephone invalide.');
        return;
      }
      if (!isEmail) {
        _showError('Adresse email invalide.');
        return;
      }
      setState(() => step = 1);
      return;
    }

    if (step == 1) {
      setState(() => step = 2);
      return;
    }

    final pass = passCtrl.text;
    final confirm = passConfirmCtrl.text;
    if (pass.length < 8) {
      _showError('Le mot de passe doit contenir au moins 8 caracteres.');
      return;
    }
    if (pass != confirm) {
      _showError('Les mots de passe ne correspondent pas.');
      return;
    }
    context.go(AppRoutes.otp);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}

class _LabelField extends StatelessWidget {
  const _LabelField({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.suffix,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, size: 19, color: color),
    );
  }
}
