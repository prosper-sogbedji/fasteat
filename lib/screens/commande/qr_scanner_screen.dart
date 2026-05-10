import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/flow_provider.dart';
import '../../theme/app_theme.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final ctrl = TextEditingController(text: 'TABLE-3');

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Scanner QR'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.flashlight_on)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.qr_code_2_rounded, color: Colors.white70, size: 120),
                  ),
                ),
              ),
            ),
            const Text('Scannez le QR code FastEat sur votre table', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Entrer un code manuellement',
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Color(0xFF2A2A2A),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () {
                context.read<FlowProvider>().setCodeTable(ctrl.text.trim());
                context.push('/panier/qr');
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}
