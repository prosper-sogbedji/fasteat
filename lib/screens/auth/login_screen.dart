import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/api/auth_service.dart';
import '../../widgets/common/auth_left_panel.dart';

// ─── Constantes de couleurs ────────────────────────────────────────────────────
const _kDarkBg = Color(0xFF0F1923);
const _kDarkMid = Color(0xFF132130);
const _kTeal = Color(0xFFFF7700);
const _kTealLight = Color(0xFFFF8A00);
const _kTealGlow = Color(0xFFFF7700);
const _kAccent = Color(0xFFFF9100);
const _kWhite = Colors.white;
const _kFormBg = Color(0xFFF7F7F7);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _phoneFocused = false;
  String? _serverWarning;

  // Animations
  late final AnimationController _shimmerCtrl;

  final _phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _phoneFocus.addListener(
      () => setState(() => _phoneFocused = _phoneFocus.hasFocus),
    );
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _serverWarning = null;
    });

    final result = await _authService.login(_phoneCtrl.text.trim());

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      if (result.token?.startsWith('mock_jwt_') == true) {
        setState(
          () => _serverWarning =
              'Serveur indisponible — mode démonstration activé.',
        );
      }
      _showOtpDialog(_phoneCtrl.text.trim());
    } else {
      if (result.isServerUnavailable) {
        setState(
          () => _serverWarning =
              'Serveur temporairement indisponible. Réessayez dans quelques secondes.',
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: _kWhite, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.errorMessage ?? 'Une erreur est survenue.',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
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

                          final result = await _authService.verifyOtp(
                            phoneNumber,
                            otpController.text,
                          );

                          if (!mounted) return;
                          setDialogState(() => isVerifying = false);

                          if (result.success) {
                            Navigator.pop(context);
                            if (result.role == 'super_admin') {
                              context.go('/admin');
                            } else {
                              try {
                                final resData = await _authService.getOwnedRestaurants();
                                final hasRestaurants = resData['hasRestaurants'] ?? false;
                                final nextAction = resData['nextAction'];
                                
                                if (hasRestaurants == false || nextAction == 'create_restaurant') {
                                  context.go('/create-restaurant');
                                } else {
                                  context.go('/');
                                }
                              } catch (e) {
                                // Fallback if API fails
                                if (result.restaurantId == null || result.restaurantId!.isEmpty) {
                                  context.go('/create-restaurant');
                                } else {
                                  context.go('/');
                                }
                              }
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: _kDarkBg,
      body: isDesktop ? _buildDesktop(size) : _buildMobile(size),
    );
  }

  // ─── LAYOUT DESKTOP ────────────────────────────────────────────────────────

  Widget _buildDesktop(Size size) {
    return Row(
      children: [
        // Panel gauche — dark immersif
        Expanded(flex: 6, child: _buildLeftPanel(size)),
        // Panel droit — formulaire épuré
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
              const SizedBox(height: 20),
              _buildLogoMobile(),
              const SizedBox(height: 48),
              _buildFormCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── PANEL GAUCHE ──────────────────────────────────────────────────────────

  Widget _buildLeftPanel(Size size) {
    return const AuthLeftPanel(
      title: 'Gérez votre\nrestaurant.\nGrandissez avec\nFastEat.',
      subtitle: 'La plateforme tout-en-un pour les restaurateurs béninois ambitieux.',
    );
  }

  // ─── PANEL DROIT — FORMULAIRE ───────────────────────────────────────────────

  Widget _buildRightPanel() {
    return Container(
      color: _kFormBg,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: _buildFormCard(),
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
        // En-tête
        const Text(
          'Connexion',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Accédez à votre espace partenaire FastEat.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 36),

        // Bandeau avertissement serveur
        if (_serverWarning != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFD97706),
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _serverWarning!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9A3412),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Formulaire
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Champ Téléphone
              _buildField(
                controller: _phoneCtrl,
                focusNode: _phoneFocus,
                isFocused: _phoneFocused,
                label: 'Numéro de téléphone',
                icon: Icons.phone_iphone_rounded,
                keyboard: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Veuillez saisir votre numéro.';
                  if (v.length < 8) return 'Numéro invalide.';
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // Bouton connexion
              _buildLoginButton(),
              const SizedBox(height: 28),

              // Séparateur
              Row(
                children: [
                  Expanded(
                    child: Container(height: 1, color: const Color(0xFFE5E7EB)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'ou',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(height: 1, color: const Color(0xFFE5E7EB)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Lien inscription
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nouveau partenaire ?',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/signup'),
                    style: TextButton.styleFrom(
                      foregroundColor: _kTeal,
                      padding: const EdgeInsets.only(left: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Créer un compte →',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Badges de sécurité
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _securityBadge(Icons.lock_rounded, 'Connexion sécurisée'),
            const SizedBox(width: 20),
            _securityBadge(Icons.verified_user_rounded, 'Données protégées'),
          ],
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
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
        focusNode: focusNode,
        obscureText: obscure,
        keyboardType: keyboard,
        validator: validator,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isFocused ? _kTeal : const Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.02,
          ),
          prefixIcon: Icon(
            icon,
            color: isFocused ? _kTeal : Colors.grey[400],
            size: 18,
          ),
          suffixIcon: suffix,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          errorStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _isLoading ? const Color(0xFF4B5563) : _kTeal,
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: _kTeal.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(_kWhite),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SE CONNECTER',
                      style: TextStyle(
                        color: _kWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: _kWhite, size: 18),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _securityBadge(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey[400]),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[400],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoMobile() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kTeal, Color(0xFFFF9100)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _kTeal.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.restaurant_rounded, color: _kWhite, size: 32),
        ),
        const SizedBox(height: 16),
        const Text(
          'FASTEAT BÉNIN',
          style: TextStyle(
            color: _kWhite,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Espace Partenaire',
          style: TextStyle(
            color: _kWhite.withValues(alpha: 0.5),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
