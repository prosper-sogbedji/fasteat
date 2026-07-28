import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _navigateWhenReady();
    });
  }

  Future<void> _navigateWhenReady() async {
    final auth = context.read<AuthProvider>();
    while (!auth.isReady && mounted) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    if (!mounted) return;
    final target = auth.isConnected ? AppRoutes.home : AppRoutes.onboarding;
    context.go(target);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F8F8), Colors.white],
          ),
        ),
        child: const Center(child: _SplashBody()),
      ),
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        CircleAvatar(
          radius: 42,
          backgroundColor: Color(0xFFFCE8EC),
          child: Icon(Icons.restaurant_menu_rounded, color: AppColors.primary, size: 42),
        ),
        SizedBox(height: 14),
        Text(
          'FASTEAT BENIN',
          style: TextStyle(
            letterSpacing: 1.2,
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8),
        Text('Commandez. Programmez. Savourez.', style: TextStyle(color: AppColors.textSecondary)),
        SizedBox(height: 26),
        SizedBox(
          width: 180,
          child: LinearProgressIndicator(
            minHeight: 5,
            backgroundColor: Color(0xFFF1CCD4),
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
