import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class BadgeCertifie extends StatelessWidget {
  const BadgeCertifie({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'Certifie FastEat',
        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
