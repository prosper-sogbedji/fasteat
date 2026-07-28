import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/country_picker.dart';

class ConnexionScreen extends StatefulWidget {
  const ConnexionScreen({super.key});

  @override
  State<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  Country _selectedCountry = kDefaultCountry;
  final phoneCtrl = TextEditingController();
  bool _loadingDialogOpen = false;

  @override
  void dispose() {
    phoneCtrl.dispose();
    super.dispose();
  }

  String get _fullPhone {
    final digits = phoneCtrl.text.replaceAll(RegExp(r'\s'), '');
    return '${_selectedCountry.dialCode}$digits';
  }

  Future<void> _sendOtp() async {
    HapticFeedback.mediumImpact();
    final digits = phoneCtrl.text.replaceAll(RegExp(r'\s'), '');
    final len = digits.length;
    if (len < _selectedCountry.minDigits || len > _selectedCountry.maxDigits) {
      _showError(
        'Numéro invalide. Pour ${_selectedCountry.name}, '
        'entrez ${_selectedCountry.minDigits == _selectedCountry.maxDigits ? "${_selectedCountry.minDigits} chiffres" : "${_selectedCountry.minDigits}–${_selectedCountry.maxDigits} chiffres"} '
        '(ex: ${_selectedCountry.hint}).',
      );
      return;
    }
    _showLoadingDialog('Envoi du code OTP...');
    final ok = await context.read<AuthProvider>().sendOtpWhatsapp(_fullPhone);
    if (!mounted) return;
    _hideLoadingDialog();
    if (ok) {
      context.push('${AppRoutes.otp}?phone=${Uri.encodeComponent(_fullPhone)}');
      return;
    }
    _showError('Impossible d\'envoyer le code OTP. Vérifiez le numéro ou réessayez.');
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ---- Zone supérieure orange ----
          Container(
            height: 300,
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 24, right: 24, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barre haut
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.onboarding),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bon retour 👋', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 8),
                          Text('Connectez-vous pour\ncontinuer.', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15, height: 1.4)),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/images/chef_illustration.png',
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ---- Contenu (Formulaire) ----
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 32, 24, bottom > 0 ? bottom + 16 : 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Entrez votre numéro pour recevoir\nun code OTP par WhatsApp.',
                    style: TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 14),
                  ),

                  const SizedBox(height: 36),

                      // Card champ téléphone
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Numéro de téléphone',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CountryPickerButton(
                                  country: _selectedCountry,
                                  onChanged: (c) => setState(() {
                                    _selectedCountry = c;
                                    phoneCtrl.clear();
                                  }),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: _selectedCountry.hint,
                                      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, size: 13, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${_selectedCountry.flag}  ${_selectedCountry.name}  •  ${_selectedCountry.dialCode}  •  ex: ${_selectedCountry.hint}',
                                    style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Bouton OTP
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: _sendOtp,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_rounded, size: 18),
                              SizedBox(width: 10),
                              Text(
                                'Recevoir le code OTP',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Bouton Mode Démo
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () async {
                            await context.read<AuthProvider>().loginDemo();
                            if (!context.mounted) return;
                            context.go(AppRoutes.home);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.rocket_launch_rounded, size: 18, color: AppColors.primary),
                              SizedBox(width: 10),
                              Text(
                                'Mode Démo',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Bas de page
                      Column(
                        children: [
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Nouveau sur FastEat ? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              GestureDetector(
                                onTap: () => context.push(AppRoutes.inscription),
                                child: const Text(
                                  'Créer un compte',
                                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Aide', style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 11)),
                              Text('Confidentialité', style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 11)),
                              Text('Conditions', style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }


  void _showLoadingDialog(String msg) {
    if (_loadingDialogOpen) return;
    _loadingDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Row(
            children: [
              CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
              const SizedBox(width: 20),
              Expanded(child: Text(msg, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
            ],
          ),
        ),
      ),
    ).then((_) => _loadingDialogOpen = false);
  }

  void _hideLoadingDialog() {
    if (!_loadingDialogOpen) return;
    Navigator.of(context, rootNavigator: true).pop();
    _loadingDialogOpen = false;
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.warning_amber_rounded, color: AppColors.primary, size: 40),
        title: const Text('Attention', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(msg, textAlign: TextAlign.center),
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
  }
}
