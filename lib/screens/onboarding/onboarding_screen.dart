import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/image_fallback.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  final _slides = const [
    (
      title: "Commandez a l'avance depuis votre bureau",
      subtitle: "Gagnez du temps et evitez les files d'attente. Votre repas est pret des votre arrivee.",
      image: 'assets/images/onboard_1.png',
      cta: 'Suivant'
    ),
    (
      title: 'Payez avec assurance',
      subtitle: 'Reglez vos commandes en un clic via MTN MoMo ou Moov Money. Simple, rapide et 100% securise.',
      image: 'assets/images/onboard_2.png',
      cta: 'Suivant'
    ),
    (
      title: "Repas pret a l'heure choisie",
      subtitle: 'Programmez vos commandes et recuperez vos plats preferes sans faire la queue. Gagnez du temps precieux au quotidien.',
      image: 'assets/images/onboard_3.png',
      cta: 'COMMENCER'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final compact = screenHeight < 760;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: compact ? 4 : 8),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (v) => setState(() => _index = v),
                itemBuilder: (context, i) {
                  final slide = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final localCompact = constraints.maxHeight < 680;
                          final imageHeight = localCompact ? 180.0 : 300.0;
                          final titleSize = _index == 2
                              ? (localCompact ? 26.0 : 32.0)
                              : (localCompact ? 34.0 : 42.0);
                          final subtitleSize = localCompact ? 13.0 : 15.0;

                          return SingleChildScrollView(
                            padding: EdgeInsets.only(bottom: localCompact ? 8 : 0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                                    child: Row(
                                      children: [
                                        const Spacer(),
                                        if (_index < 2)
                                          TextButton(
                                            onPressed: () => context.go(AppRoutes.connexion),
                                            child: const Text(
                                              'PASSER',
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    child: ImageFallback(
                                      path: slide.image,
                                      label: slide.title,
                                      height: imageHeight,
                                      radius: 0,
                                    ),
                                  ),
                                  SizedBox(height: localCompact ? 10 : 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 18),
                                    child: Text(
                                      slide.title,
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: titleSize,
                                        fontWeight: FontWeight.w800,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: localCompact ? 6 : 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 18),
                                    child: Text(
                                      slide.subtitle,
                                      textAlign: TextAlign.center,
                                      maxLines: localCompact ? 3 : 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: subtitleSize,
                                      ),
                                    ),
                                  ),
                                  if (_index == 1)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: localCompact ? 58 : 72,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFACC15),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Center(
                                                child: Text('MTN MOMO', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Container(
                                              height: localCompact ? 58 : 72,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF0EA5E9),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  'MOOV MONEY',
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  SizedBox(height: localCompact ? 12 : 18),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      _slides.length,
                                      (dot) => AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        height: 6,
                                        width: dot == _index ? 24 : 8,
                                        decoration: BoxDecoration(
                                          color: dot == _index ? AppColors.primary : const Color(0xFFD1D5DB),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size.fromHeight(54),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () {
                                        if (_index < _slides.length - 1) {
                                          _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
                                        } else {
                                          context.go(AppRoutes.connexion);
                                        }
                                      },
                                      child: Text(slide.cta),
                                    ),
                                  ),
                                  if (_index == 2)
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 12),
                                      child: Text(
                                        'ETAPE FINALE COMPLETEE',
                                        style: TextStyle(letterSpacing: 2, color: AppColors.textSecondary, fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: compact ? 2 : 6),
            const Text(
              'FASTEAT BENIN',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 1),
            const Text(
              'LE MOTEUR DE VOS SAVEURS',
              style: TextStyle(letterSpacing: 2, color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: compact ? 2 : 6),
          ],
        ),
      ),
    );
  }
}
