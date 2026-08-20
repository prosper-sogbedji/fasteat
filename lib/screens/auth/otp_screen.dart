import 'package:flutter/material.dart';
import 'package:fast_eat/widgets/common/app_feedback.dart';

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

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, this.phone});

  final String? phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  bool _loadingDialogOpen = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  String get _phone {
    final fromRoute = widget.phone?.trim();
    if (fromRoute != null && fromRoute.isNotEmpty) return fromRoute;
    return context.read<AuthProvider>().pendingPhone ?? '';
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
              Expanded(
                child: Text(msg, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
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

  Future<void> _verify() async {
    final phone = _phone;
    if (phone.isEmpty) {
      _showError('Numéro manquant. Reprenez l\'inscription.');
      return;
    }
    if (_code.length != 6) {
      _showError('Saisissez le code à 6 chiffres.');
      return;
    }
    _showLoadingDialog('Vérification en cours...');
    final ok = await context.read<AuthProvider>().verifyOtp(phone, _code);
    if (!mounted) return;
    _hideLoadingDialog();
    if (ok) {
      await syncClientSession(
        auth: context.read<AuthProvider>(),
        panier: context.read<PanierProvider>(),
        commandes: context.read<CommandesProvider>(),
        favorites: context.read<FavoritesProvider>(),
        notifications: context.read<NotificationsProvider>(),
      );
      if (!mounted) return;
      context.go(AppRoutes.home);
      return;
    }
    _showError('Code invalide ou expiré.');
  }

  Future<void> _resend() async {
    final phone = _phone;
    if (phone.isEmpty) return;
    final ok = await context.read<AuthProvider>().sendOtpWhatsapp(phone);
    if (!mounted) return;
    AppFeedback.error(context, ok ? 'Code renvoyé.' : 'Impossible de renvoyer le code.');
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
            style: FilledButton.styleFrom(
              minimumSize: const Size(120, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification du numero'),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                'FASTEAT',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Entrez le code recu',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _phone.isEmpty ? 'Complétez votre inscription' : 'Envoyé au $_phone',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (i) {
                          return SizedBox(
                            width: 48,
                            child: TextField(
                              controller: _controllers[i],
                              focusNode: _nodes[i],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                              ),
                              onChanged: (v) {
                                if (v.isNotEmpty && i < 5) {
                                  _nodes[i + 1].requestFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                      const Text("Vous n'avez pas recu de code ?", style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      TextButton(
                        onPressed: _resend,
                        child: const Text('Renvoyer le code', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: _verify,
                        child: const Text('Verifier'),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
