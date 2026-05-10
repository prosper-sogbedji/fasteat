import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundColor: Color(0xFFFCE8EC),
                child: Icon(Icons.sms_outlined, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 14),
              const Text('Verification du numero', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800, height: 1)),
              const SizedBox(height: 6),
              const Text('Code envoye au +229 XX XX XX XX', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Row(
                children: List.generate(
                  6,
                  (i) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _nodes[i],
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                        onChanged: (v) {
                          if (v.isNotEmpty && i < 5) {
                            _nodes[i + 1].requestFocus();
                          }
                        },
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text("Vous n'avez pas recu de code ?", style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              const Text('00:54  •  Renvoyer le code', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () {
                  context.read<AuthProvider>().loginMock();
                  context.go(AppRoutes.home);
                },
                child: const Text('Verifier'),
              ),
              const Spacer(),
              _buildKeypad(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    Widget cell(String text) {
      return Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54)),
      );
    }

    return Column(
      children: [
        Row(children: [Expanded(child: cell('1')), const SizedBox(width: 8), Expanded(child: cell('2')), const SizedBox(width: 8), Expanded(child: cell('3'))]),
        const SizedBox(height: 8),
        Row(children: [Expanded(child: cell('4')), const SizedBox(width: 8), Expanded(child: cell('5')), const SizedBox(width: 8), Expanded(child: cell('6'))]),
        const SizedBox(height: 8),
        Row(children: [Expanded(child: cell('7')), const SizedBox(width: 8), Expanded(child: cell('8')), const SizedBox(width: 8), Expanded(child: cell('9'))]),
        const SizedBox(height: 8),
        Row(children: [Expanded(child: Container()), const SizedBox(width: 8), Expanded(child: cell('0')), const SizedBox(width: 8), Expanded(child: cell('X'))]),
      ],
    );
  }
}
