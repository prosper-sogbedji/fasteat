import 'package:flutter/material.dart';
import 'package:fast_eat/widgets/common/app_feedback.dart';

import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../providers/flow_provider.dart';
import '../../providers/panier_provider.dart';
import '../../theme/app_theme.dart';

/// Format du QR code attendu : fasteat://resto?id=r1&table=5
///
/// Le scanner détecte ce code, extrait le restoId et le numéro de table,
/// puis redirige automatiquement vers le menu du restaurant.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _ctrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool _scanned = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Parse le QR code et retourne (restoId, table) ou null si invalide.
  ({String restoId, String table})? _parse(String raw) {
    try {
      final uri = Uri.parse(raw);
      // Format : fasteat://resto?id=r1&table=5
      if (uri.scheme == 'fasteat' && uri.host == 'resto') {
        final id = uri.queryParameters['id'];
        final table = uri.queryParameters['table'];
        if (id != null && id.isNotEmpty && table != null && table.isNotEmpty) {
          return (restoId: id, table: table);
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned || !mounted) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;

    final parsed = _parse(code);
    if (parsed == null) {
      // Code scanné mais format non reconnu : on le signale visuellement
      if (mounted) {
        AppFeedback.error(context, 'QR code non reconnu. Utilisez un code FastEat.');
      }
      return;
    }

    setState(() => _scanned = true);
    await _ctrl.stop();

    // Enregistrer le resto + table, forcer mode "Sur place"
    if (!mounted) return;
    final flow = context.read<FlowProvider>();
    final panier = context.read<PanierProvider>();
    await flow.setTableQr(parsed.restoId, parsed.table);

    // Vider le panier si le restaurant est différent
    final lignes = panier.lignes;
    final diffResto = lignes.isNotEmpty && lignes.first.plat.restoId != parsed.restoId;
    if (diffResto) await panier.vider();

    if (!mounted) return;

    // Afficher une confirmation et rediriger vers le restaurant
    AppFeedback.success(context, 'Table ${parsed.table} détectée ✓  Bienvenue !');

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) context.go('/restaurant/${parsed.restoId}');
  }

  // Saisie manuelle (utile pour les tests ou si caméra indisponible)
  void _showManualEntry() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saisie manuelle', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text(
                'Format : fasteat://resto?id=r1&table=5',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'fasteat://resto?id=r1&table=5',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    final fake = BarcodeCapture(
                      raw: '',
                      barcodes: [
                        Barcode(rawValue: ctrl.text.trim()),
                      ],
                    );
                    _onDetect(fake);
                  },
                  child: const Text('Valider'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Scanner la table', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: () async {
              await _ctrl.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
            icon: Icon(
              _torchOn ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
              color: _torchOn ? Colors.yellow : Colors.white,
            ),
          ),
          IconButton(
            onPressed: _showManualEntry,
            icon: const Icon(Icons.keyboard_rounded, color: Colors.white),
            tooltip: 'Saisie manuelle',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fond caméra plein écran
          MobileScanner(
            controller: _ctrl,
            onDetect: _onDetect,
          ),

          // Overlay de guidage
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ScanOverlayPainter(),
          ),

          // Instructions en bas
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_scanned)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        SizedBox(width: 14),
                        Text('Table reconnue, redirection...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    )
                  else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Pointez vers le QR code sur votre table',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _showManualEntry,
                      icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 16),
                      label: const Text('Saisir le code manuellement', style: TextStyle(color: Colors.white70, fontSize: 12)),
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
}

/// Dessine le cadre de visée semi-transparent avec les coins colorés.
class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double boxW = 260;
    const double boxH = 260;
    final cx = size.width / 2;
    final cy = size.height / 2;

    final left = cx - boxW / 2;
    final top = cy - boxH / 2;
    final right = cx + boxW / 2;
    final bottom = cy + boxH / 2;

    // Fond sombre autour du cadre
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final holeRect = Rect.fromLTRB(left, top, right, bottom);
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(holeRect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, bgPaint);

    // Coins colorés
    const double cLen = 28;
    const double cThick = 4;
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = cThick
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Coin haut-gauche
    canvas.drawPath(
      Path()
        ..moveTo(left + cLen, top + cThick / 2)
        ..lineTo(left + cThick / 2, top + cThick / 2)
        ..lineTo(left + cThick / 2, top + cLen),
      cornerPaint,
    );
    // Coin haut-droit
    canvas.drawPath(
      Path()
        ..moveTo(right - cLen, top + cThick / 2)
        ..lineTo(right - cThick / 2, top + cThick / 2)
        ..lineTo(right - cThick / 2, top + cLen),
      cornerPaint,
    );
    // Coin bas-gauche
    canvas.drawPath(
      Path()
        ..moveTo(left + cLen, bottom - cThick / 2)
        ..lineTo(left + cThick / 2, bottom - cThick / 2)
        ..lineTo(left + cThick / 2, bottom - cLen),
      cornerPaint,
    );
    // Coin bas-droit
    canvas.drawPath(
      Path()
        ..moveTo(right - cLen, bottom - cThick / 2)
        ..lineTo(right - cThick / 2, bottom - cThick / 2)
        ..lineTo(right - cThick / 2, bottom - cLen),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
