import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  /// 0: identité + téléphone, 1: OTP WhatsApp, 2: mot de passe
  int step = 0;
  bool hidePassword = true;
  bool hidePasswordConfirm = true;
  final nomCompletCtrl = TextEditingController();
  final phoneLocalCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final passConfirmCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpNodes = List.generate(6, (_) => FocusNode());

  static const _indicatif = '+229';

  @override
  void dispose() {
    nomCompletCtrl.dispose();
    phoneLocalCtrl.dispose();
    passCtrl.dispose();
    passConfirmCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final n in _otpNodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _fullPhone {
    final d = phoneLocalCtrl.text.replaceAll(RegExp(r'\s'), '');
    return '$_indicatif $d';
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
          if (step == 0) ..._stepIdentite(),
          if (step == 1) ..._stepOtpWhatsapp(),
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
                  child: Text(step == 0 ? 'Suivant' : step == 1 ? 'Verifier' : "S'inscrire"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _stepIdentite() {
    return [
      _LabelField(label: 'Nom complet', hint: 'Nom et prénom', controller: nomCompletCtrl),
      const SizedBox(height: 14),
      const Align(
        alignment: Alignment.centerLeft,
        child: Text('Numéro de téléphone', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ),
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
            child: const Text(_indicatif, style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: phoneLocalCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '90 00 00 00',
                hintStyle: TextStyle(color: Color(0xFF98A2B3), fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Text(
        'L’indicatif +229 est pré-rempli. Saisissez votre numéro sans le répéter.',
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    ];
  }

  List<Widget> _stepOtpWhatsapp() {
    return [
      const SizedBox(height: 8),
      CircleAvatar(
        radius: 28,
        backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.15),
        child: const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 30),
      ),
      const SizedBox(height: 12),
      const Text(
        'Vérification WhatsApp',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      Text(
        'Un code à 6 chiffres a été envoyé sur WhatsApp au numéro\n$_fullPhone',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSecondary, height: 1.35),
      ),
      const SizedBox(height: 18),
      Row(
        children: List.generate(
          6,
          (i) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: TextField(
                controller: _otpCtrls[i],
                focusNode: _otpNodes[i],
                textAlign: TextAlign.center,
                maxLength: 1,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                onChanged: (v) {
                  if (v.isNotEmpty && i < 5) {
                    _otpNodes[i + 1].requestFocus();
                  }
                },
                decoration: const InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      TextButton(
        onPressed: () => _showInfo('Renvoi simulé : un nouveau code serait envoyé sur WhatsApp.'),
        child: const Text('Renvoyer le code sur WhatsApp'),
      ),
    ];
  }

  List<Widget> _stepPassword() {
    return [
      const Text(
        'Choisissez votre mot de passe',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      const Text(
        'Sécurisez votre compte avec un mot de passe fort.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      const SizedBox(height: 16),
      _LabelField(
        label: 'Mot de passe',
        hint: 'Au moins 8 caractères',
        controller: passCtrl,
        obscureText: hidePassword,
        suffix: IconButton(
          onPressed: () => setState(() => hidePassword = !hidePassword),
          icon: Icon(hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
        ),
      ),
      const SizedBox(height: 10),
      _LabelField(
        label: 'Confirmer le mot de passe',
        hint: 'Répétez le mot de passe',
        controller: passConfirmCtrl,
        obscureText: hidePasswordConfirm,
        suffix: IconButton(
          onPressed: () => setState(() => hidePasswordConfirm = !hidePasswordConfirm),
          icon: Icon(hidePasswordConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
        ),
      ),
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
      final nom = nomCompletCtrl.text.trim();
      final digits = phoneLocalCtrl.text.replaceAll(RegExp(r'\s'), '');
      final isPhone = RegExp(r'^[0-9]{8,10}$').hasMatch(digits);
      if (nom.length < 3) {
        _showError('Veuillez saisir votre nom complet.');
        return;
      }
      if (!isPhone) {
        _showError('Numéro invalide : 8 à 10 chiffres après +229.');
        return;
      }
      setState(() => step = 1);
      // send OTP via WhatsApp (mock)
      final phone = _fullPhone;
      WidgetsBinding.instance.addPostFrameCallback((_) => _otpNodes.first.requestFocus());
      Future.microtask(() async {
        final ok = await context.read<AuthProvider>().sendOtpWhatsapp(phone);
        if (!ok) {
          _showError('Impossible d\'envoyer le code sur WhatsApp.');
        }
      });
      return;
    }

    if (step == 1) {
      final code = _otpCtrls.map((c) => c.text).join();
      if (code.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(code)) {
        _showError('Saisissez le code à 6 chiffres reçu sur WhatsApp.');
        return;
      }
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
    context.read<AuthProvider>().loginMock();
    context.go(AppRoutes.home);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showInfo(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
