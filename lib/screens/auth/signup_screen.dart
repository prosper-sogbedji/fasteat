import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/api/auth_service.dart';
import '../../widgets/common/auth_left_panel.dart';

// ─── Constantes de couleurs (Communes avec Login) ─────────────────────────────
const _kDarkBg = Color(0xFF0F1923);
const _kDarkMid = Color(0xFF132130);
const _kTeal = Color(0xFFFF7700);
const _kTealLight = Color(0xFFFF8A00);
const _kTealGlow = Color(0xFFFF7700);
const _kAccent = Color(0xFFFF9100);
const _kWhite = Colors.white;
const _kFormBg = Color(0xFFF7F7F7);

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _referralCodeController = TextEditingController();

  bool _isLoading = false;
  bool _acceptCharte = false;

  final _focusNodes = <String, FocusNode>{};
  final _focusStates = <String, bool>{};

  @override
  void initState() {
    super.initState();
    final fields = ['fullName', 'phone', 'referralCode'];
    for (final f in fields) {
      final fn = FocusNode();
      _focusNodes[f] = fn;
      _focusStates[f] = false;
      fn.addListener(() => setState(() => _focusStates[f] = fn.hasFocus));
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _referralCodeController.dispose();
    for (final fn in _focusNodes.values) fn.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptCharte) {
      _showError('Veuillez accepter les conditions d\'utilisation.');
      return;
    }
    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final result = await authService.register({
        'fullName': _fullNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'referralCode': _referralCodeController.text.trim(),
      });

      if (!mounted) return;

      if (result.success) {
        _showOtpDialog(_phoneController.text.trim());
      } else {
        _showError(result.errorMessage ?? "Erreur lors de l'inscription");
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Erreur : $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showOtpDialog(String phoneNumber) {
    final otpController = TextEditingController();
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Vérification par SMS',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Un code a été envoyé au $phoneNumber. Veuillez le saisir ci-dessous.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Code OTP',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isVerifying ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                FilledButton(
                  onPressed: isVerifying
                      ? null
                      : () async {
                          if (otpController.text.isEmpty) return;
                          setDialogState(() => isVerifying = true);

                          final result = await AuthService().verifyOtp(
                            phoneNumber,
                            otpController.text,
                          );

                          if (!mounted) return;
                          setDialogState(() => isVerifying = false);

                          if (result.success) {
                            Navigator.pop(context); // fermer dialog
                            // Si pas de resto rattaché, direction creation resto
                            if (result.restaurantId == null ||
                                result.restaurantId!.isEmpty) {
                              context.go('/create-restaurant');
                            } else {
                              context.go('/');
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result.errorMessage ?? 'Code invalide',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: isVerifying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Vérifier'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFEF4444)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    return Scaffold(
      backgroundColor: _kDarkBg,
      body: isDesktop ? _buildDesktop(size) : _buildMobile(size),
    );
  }

  Widget _buildDesktop(Size size) {
    return Row(
      children: [
        Expanded(flex: 6, child: _buildLeftPanel(size)),
        Expanded(flex: 4, child: _buildRightPanel()),
      ],
    );
  }

  Widget _buildMobile(Size size) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kDarkBg, _kDarkMid],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.restaurant_menu_rounded,
                    color: _kAccent,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'FastEat',
                    style: TextStyle(
                      color: _kWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: _kWhite,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildFormCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPanel(Size size) {
    return const AuthLeftPanel(
      title: 'Rejoignez\nle mouvement.',
      subtitle: 'Ouvrez votre compte partenaire et gérez vos commandes en toute simplicité.',
    );
  }

  Widget _buildRightPanel() {
    return Container(
      color: _kFormBg,
      child: Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 8 * (1 - value)),
                child: child,
              ),
            );
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: _buildFormCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Créer un compte',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Inscrivez-vous rapidement.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 36),

        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                controller: _fullNameController,
                nodeKey: 'fullName',
                label: 'Nom complet',
                icon: Icons.person_outline_rounded,
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _phoneController,
                nodeKey: 'phone',
                label: 'Numéro de téléphone (+229...)',
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _referralCodeController,
                nodeKey: 'referralCode',
                label: 'Code de parrainage (Optionnel)',
                icon: Icons.card_giftcard_rounded,
                validator: null,
              ),
              const SizedBox(height: 24),

              // Checkbox
              InkWell(
                onTap: () => setState(() => _acceptCharte = !_acceptCharte),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 150),
                      tween: Tween<double>(begin: 0.8, end: _acceptCharte ? 1.0 : 0.8),
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Checkbox(
                        value: _acceptCharte,
                        onChanged: (v) =>
                            setState(() => _acceptCharte = v ?? false),
                        activeColor: _kTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'J\'accepte les conditions d\'utilisation et la politique de confidentialité.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Bouton
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isLoading ? null : _handleSignup,
                  style: FilledButton.styleFrom(
                    backgroundColor: _kTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'S\'INSCRIRE',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // Lien connexion
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Déjà partenaire ?',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      style: TextButton.styleFrom(
                        foregroundColor: _kTeal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text(
                        'Connectez-vous',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String nodeKey,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    final isFocused = _focusStates[nodeKey] ?? false;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFocused ? _kTeal : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: _kTeal.withOpacity(0.15),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: _focusNodes[nodeKey],
        validator: validator,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isFocused ? _kTeal : const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
            fontSize: 12,
            letterSpacing: 0.02,
          ),
          prefixIcon: Icon(
            icon,
            color: isFocused ? _kTeal : const Color(0xFF94A3B8),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
