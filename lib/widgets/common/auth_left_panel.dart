import 'package:flutter/material.dart';

const _kDarkBg = Color(0xFF0F1923);
const _kDarkMid = Color(0xFF132130);
const _kTeal = Color(0xFFFF7700);
const _kAccent = Color(0xFFFF9100);
const _kTealGlow = Color(0xFFFF7700);
const _kWhite = Colors.white;

class AuthLeftPanel extends StatefulWidget {
  final String title;
  final String subtitle;

  const AuthLeftPanel({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  State<AuthLeftPanel> createState() => _AuthLeftPanelState();
}

class _AuthLeftPanelState extends State<AuthLeftPanel> with TickerProviderStateMixin {
  late final AnimationController _orbCtrl;
  late final AnimationController _cardCtrl;
  late final Animation<double> _cardFloat;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _cardFloat = Tween<double>(
      begin: 0,
      end: 12,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kDarkBg, _kDarkMid, Color(0xFF0A3038)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          _buildOrbs(),
          _buildGrid(),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 52,
                  vertical: 44,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 88,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLogo(),
                        const Spacer(),
                        _buildHeadline(),
                        const SizedBox(height: 40),
                        _buildFloatingCard(),
                        const SizedBox(height: 40),
                        _buildFeaturePills(),
                        const Spacer(),
                        _buildMetrics(),
                        const SizedBox(height: 24),
                        _buildCopyright(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrbs() {
    return AnimatedBuilder(
      animation: _orbCtrl,
      builder: (context, child) {
        final t = _orbCtrl.value;
        return Stack(
          children: [
            Positioned(
              top: -80 + t * 40,
              right: -60 + t * 30,
              child: _orb(320, _kTealGlow.withValues(alpha: 0.12)),
            ),
            Positioned(
              bottom: 60 + t * 50,
              left: -100 + t * 20,
              child: _orb(280, _kAccent.withValues(alpha: 0.07)),
            ),
            Positioned(
              top: 200 - t * 30,
              left: 180 + t * 20,
              child: _orb(120, _kTeal.withValues(alpha: 0.15)),
            ),
          ],
        );
      },
    );
  }

  Widget _orb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color, blurRadius: size * 0.7, spreadRadius: 0),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return CustomPaint(painter: _GridPainter(), child: const SizedBox.expand());
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_kTeal, _kAccent]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.restaurant_rounded, color: _kWhite, size: 20),
        ),
        const SizedBox(width: 12),
        const Text(
          'FASTEAT',
          style: TextStyle(
            color: _kWhite,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _kTeal.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kTeal.withValues(alpha: 0.4)),
          ),
          child: const Text(
            'BÉNIN',
            style: TextStyle(
              color: _kAccent,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeadline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_kWhite, Color(0xFFB2D8D8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            widget.title,
            style: const TextStyle(
              color: _kWhite,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.subtitle,
          style: TextStyle(
            color: _kWhite.withValues(alpha: 0.55),
            fontSize: 15,
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingCard() {
    return AnimatedBuilder(
      animation: _cardFloat,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -_cardFloat.value),
        child: _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4ADE80),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tableau de bord en direct',
                    style: TextStyle(
                      color: _kWhite.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Aujourd\'hui',
                    style: TextStyle(
                      color: _kWhite.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _miniStat(
                    '12',
                    'Commandes',
                    Icons.receipt_long_rounded,
                    const Color(0xFF4ADE80),
                  ),
                  _vDivider(),
                  _miniStat('87 500', 'FCFA', Icons.payments_rounded, _kAccent),
                  _vDivider(),
                  _miniStat(
                    '24',
                    'Plats actifs',
                    Icons.restaurant_menu_rounded,
                    const Color(0xFFFBBF24),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _miniChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kWhite.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kWhite.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: _kTeal.withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _miniStat(String val, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            val,
            style: const TextStyle(
              color: _kWhite,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: _kWhite.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() {
    return Container(
      width: 1,
      height: 50,
      color: _kWhite.withValues(alpha: 0.08),
    );
  }

  Widget _miniChart() {
    final values = [
      0.3, 0.5, 0.4, 0.7, 0.6, 0.8, 0.9, 0.75, 0.85, 1.0, 0.9, 0.95,
    ];
    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values
            .map(
              (v) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  height: 40 * v,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        _kTeal.withValues(alpha: 0.8),
                        _kAccent.withValues(alpha: 0.4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildFeaturePills() {
    final features = [
      (Icons.bolt_rounded, 'Commandes temps réel'),
      (Icons.bar_chart_rounded, 'Analytiques avancées'),
      (Icons.tune_rounded, 'Menu simplifié'),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: features
          .map(
            (f) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _kWhite.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _kWhite.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(f.$1, color: _kAccent, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    f.$2,
                    style: TextStyle(
                      color: _kWhite.withValues(alpha: 0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMetrics() {
    return Row(
      children: [
        _metricBadge('1 200+', 'Commandes/mois'),
        const SizedBox(width: 16),
        _metricBadge('98%', 'Satisfaction'),
        const SizedBox(width: 16),
        _metricBadge('50+', 'Restaurants'),
      ],
    );
  }

  Widget _metricBadge(String val, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          val,
          style: const TextStyle(
            color: _kWhite,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: _kWhite.withValues(alpha: 0.45),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCopyright() {
    return Text(
      '© 2026 FastEat Bénin — Tous droits réservés.',
      style: TextStyle(
        color: _kWhite.withValues(alpha: 0.25),
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 0.5;
    const spacing = 50.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.06);
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
