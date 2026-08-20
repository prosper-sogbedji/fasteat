import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../core/session_sync.dart';
import '../../providers/auth_provider.dart';
import '../../providers/commandes_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/panier_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_feedback.dart';

import '../../widgets/common/country_picker.dart';

class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  /// 0: identité + téléphone, 1: vérification OTP WhatsApp/SMS
  int step = 0;
  final nomCompletCtrl = TextEditingController();
  final phoneLocalCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpNodes = List.generate(6, (_) => FocusNode());

  Country _selectedCountry = kDefaultCountry;
  bool _loadingDialogOpen = false;

  @override
  void dispose() {
    nomCompletCtrl.dispose();
    phoneLocalCtrl.dispose();
    for (final c in _otpCtrls) { c.dispose(); }
    for (final n in _otpNodes) { n.dispose(); }
    super.dispose();
  }

  String get _fullPhone {
    final d = phoneLocalCtrl.text.replaceAll(RegExp(r'\s'), '');
    return '${_selectedCountry.dialCode} $d';
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ---- Zone supérieure orange ----
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            height: step == 0 ? 300 : 210,
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
                      onTap: () {
                        if (step == 1) {
                          setState(() => step = 0);
                        } else {
                          context.go(AppRoutes.onboarding);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                    const Spacer(),
                    // Indicateur d'étape
                    Row(
                      children: List.generate(2, (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: step == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: step == index ? Colors.white : Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
                    ),
                  ],
                ),
                const Spacer(),
                if (step == 0) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Bienvenue 🎉', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 8),
                            Text('Créez votre compte\nen 2 minutes.', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15, height: 1.4)),
                          ],
                        ),
                      ),
                      const _ChefIllustration(),
                    ],
                  ),
                ] else ...[
                  const Text('Vérification 🛡️', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text('Saisissez le code reçu.', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15, height: 1.4)),
                ],
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
                  if (step == 0) ..._stepIdentite(),
                  if (step == 1) ..._stepOtpWhatsapp(),

                  const SizedBox(height: 24),

                  // Bouton principal
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.35),
                      ),
                      onPressed: _onPrimary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(step == 0 ? 'Suivant' : "Valider le code",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          const SizedBox(width: 8),
                          Icon(step == 0 ? Icons.arrow_forward_rounded : Icons.check_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  // Bouton Mode Démo
                  if (step == 0)
                    SizedBox(
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

                  if (step == 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Déjà un compte ? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.connexion),
                          child: const Text('Se connecter', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],

                  if (step == 1) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _showInfo('Un nouveau code vous sera envoyé sur WhatsApp.'),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Renvoyer le code'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _stepIdentite() {
    return [
      // Champ nom
      _buildLabel('Nom complet'),
      const SizedBox(height: 8),
      TextField(
        controller: nomCompletCtrl,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          hintText: 'Votre nom et prénom',
          prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
        ),
      ),
      const SizedBox(height: 20),

      // Champ téléphone
      _buildLabel('Numéro de téléphone'),
      const SizedBox(height: 8),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CountryPickerButton(
            country: _selectedCountry,
            onChanged: (c) => setState(() {
              _selectedCountry = c;
              phoneLocalCtrl.clear();
            }),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: phoneLocalCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: _selectedCountry.hint,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_selectedCountry.flag}  ${_selectedCountry.name}  •  ${_selectedCountry.dialCode}  •  ${_selectedCountry.minDigits} chiffres',
                style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _stepOtpWhatsapp() {
    return [
      Center(
        child: Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF25D366).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 32),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'Code envoyé sur WhatsApp au\n$_fullPhone',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 14),
      ),
      const SizedBox(height: 24),
      Row(
        children: List.generate(6, (i) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: TextField(
              controller: _otpCtrls[i],
              focusNode: _otpNodes[i],
              textAlign: TextAlign.center,
              maxLength: 1,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              onChanged: (v) {
                if (v.isNotEmpty && i < 5) _otpNodes[i + 1].requestFocus();
                if (v.isEmpty && i > 0) _otpNodes[i - 1].requestFocus();
              },
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
        )),
      ),
    ];
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary));
  }

  void _onPrimary() async {
    HapticFeedback.mediumImpact();
    final auth = context.read<AuthProvider>();

    if (step == 0) {
      final nom = nomCompletCtrl.text.trim();
      final digits = phoneLocalCtrl.text.replaceAll(RegExp(r'\s'), '');
      final len = digits.length;

      if (nom.length < 3) { _showError('Veuillez saisir votre nom complet (au moins 3 caractères).'); return; }
      if (len < _selectedCountry.minDigits || len > _selectedCountry.maxDigits) {
        _showError(
          'Numéro invalide pour ${_selectedCountry.name}.\n'
          '${_selectedCountry.minDigits == _selectedCountry.maxDigits ? "Entrez exactement ${_selectedCountry.minDigits} chiffres" : "Entrez ${_selectedCountry.minDigits}–${_selectedCountry.maxDigits} chiffres"} '
          '(ex: ${_selectedCountry.hint}).',
        );
        return;
      }

      _showLoadingDialog('Envoi du code en cours...');
      final ok = await auth.register(nom, _fullPhone);
      if (!mounted) return;
      _hideLoadingDialog();

      if (ok) {
        setState(() => step = 1);
        WidgetsBinding.instance.addPostFrameCallback((_) => _otpNodes.first.requestFocus());
      } else {
        _showError('Impossible de s\'inscrire. Vérifiez votre connexion ou ce numéro est déjà utilisé.');
      }
      return;
    }

    if (step == 1) {
      final code = _otpCtrls.map((c) => c.text).join();
      if (code.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(code)) {
        _showError('Saisissez le code à 6 chiffres reçu sur WhatsApp.');
        return;
      }

      _showLoadingDialog('Vérification en cours...');
      final ok = await auth.verifyOtp(_fullPhone, code);
      if (!mounted) return;
      _hideLoadingDialog();

      if (ok) {
        await syncClientSession(
          auth: auth,
          panier: context.read<PanierProvider>(),
          commandes: context.read<CommandesProvider>(),
          favorites: context.read<FavoritesProvider>(),
          notifications: context.read<NotificationsProvider>(),
        );
        if (!mounted) return;
        context.go(AppRoutes.home);
      } else {
        _showError('Code incorrect ou expiré. Réessayez.');
      }
    }
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

  void _showInfo(String msg) {
    AppFeedback.info(context, msg);
  }
}

/// Illustration cuisinier (image fournie par le user) — affichée dans la zone orange
class _ChefIllustration extends StatelessWidget {
  const _ChefIllustration();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/chef_illustration.png',
      height: 110,
      fit: BoxFit.contain,
    );
  }
}
