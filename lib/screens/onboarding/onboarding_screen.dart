import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_routes.dart';
import '../../theme/app_theme.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _slides = <({
    String title,
    String subtitle,
    String image,
    String cta,
  })>[
    (
      title: "Commandez à l'avance depuis votre bureau",
      subtitle: "Gagnez du temps et évitez les files d'attente. Votre repas est prêt dès votre arrivée.",
      image: 'assets/images/onboard_1.png',
      cta: 'Suivant',
    ),
    (
      title: 'Payez avec assurance',
      subtitle: 'Réglez vos commandes en un clic via MTN MoMo ou Moov Money. Simple, rapide et 100 % sécurisé.',
      image: 'assets/images/onboard_2.png',
      cta: 'Suivant',
    ),
    (
      title: "Repas prêt à l'heure choisie",
      subtitle: 'Programmez vos commandes et récupérez vos plats préférés sans faire la queue. Gagnez du temps précieux au quotidien.',
      image: 'assets/images/onboard_3.png',
      cta: 'Commencer',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  const Spacer(),
                  if (_index < 2)
                    TextButton(
                      onPressed: () => context.go(AppRoutes.connexion),
                      child: const Text(
                        'Passer',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (v) => setState(() => _index = v),
                itemBuilder: (context, i) {
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _index == i ? 1.0 : 0.4,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Image.asset(
                          _slides[i].image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Material(
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 12 + bottomInset),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      slide.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      slide.subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    if (_index == 1) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFACC15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text('MTN MOMO', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0EA5E9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'MOOV MONEY',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          if (_index < _slides.length - 1) {
                            _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                          } else {
                            context.go(AppRoutes.connexion);
                          }
                        },
                        child: Text(slide.cta, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (_index == 2) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'ÉTAPE FINALE COMPLÉTÉE',
                        style: TextStyle(letterSpacing: 1.2, color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
