import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      icon: Icons.receipt_long_rounded,
      title: 'Commandes en direct',
      description:
          'Recevez les commandes de vos clients en temps réel, gérez les préparations et suivez les livreurs à la trace pour garantir un service ultra-rapide.',
      gradientStart: const Color(0xFFFF8A00),
      gradientEnd: const Color(0xFFFF7700),
    ),
    OnboardingSlideData(
      icon: Icons.restaurant_menu_rounded,
      title: 'Gestion de votre carte',
      description:
          'Ajoutez, modifiez ou suspendez vos plats en un clin d’œil grâce à un assistant intelligent de création de plats conçu pour les gérants débordés.',
      gradientStart: const Color(0xFF0F1923),
      gradientEnd: const Color(0xFF132130),
    ),
    OnboardingSlideData(
      icon: Icons.bar_chart_rounded,
      title: 'Suivez vos rushs',
      description:
          'Optimisez vos stocks et vos équipes grâce à une heatmap d’affluence horaire qui cartographie les périodes les plus chargées de votre semaine.',
      gradientStart: const Color(0xFFFF9100),
      gradientEnd: const Color(0xFFFF7700),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
    } catch (_) {}
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 500 : double.infinity,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // Bouton Passer (Skip) en haut
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text(
                      'PASSER',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                // Contenu défilant (PageView)
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemCount: _slides.length,
                    itemBuilder: (context, idx) {
                      final slide = _slides[idx];
                      return _buildSlide(context, slide);
                    },
                  ),
                ),
                // Pied de page : Indicateurs + Bouton CTA
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Indicateurs de page (Pilules)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _slides.length,
                        (idx) => _buildIndicator(idx == _currentPage),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Bouton Suivant ou Commencer
                    FilledButton(
                      onPressed: () {
                        if (_currentPage < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _slides.length - 1
                            ? 'COMMENCER L\'EXPÉRIENCE'
                            : 'SUIVANT',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(BuildContext context, OnboardingSlideData slide) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Carte d'illustration
        Container(
          height: 240,
          width: 240,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [slide.gradientStart, slide.gradientEnd],
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: slide.gradientStart.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(child: Icon(slide.icon, color: Colors.white, size: 80)),
        ),
        const SizedBox(height: 48),
        // Titre principal
        Text(
          slide.title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Description détaillée
        Text(
          slide.description,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingSlideData {
  const OnboardingSlideData({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color gradientStart;
  final Color gradientEnd;
}
