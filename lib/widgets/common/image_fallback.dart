import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class ImageFallback extends StatelessWidget {
  const ImageFallback({
    super.key,
    required this.path,
    required this.label,
    this.height = 120,
    this.width = double.infinity,
    this.radius = 12,
    this.fit = BoxFit.cover,
  });

  final String path;
  final String label;
  final double height;
  final double width;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: width,
        child: Image.asset(
          path,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFFFFE6D5),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
