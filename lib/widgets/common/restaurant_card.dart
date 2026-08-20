import 'package:flutter/material.dart';

import '../../models/restaurant.dart';
import '../../theme/app_theme.dart';
import 'badge_certifie.dart';
import 'image_fallback.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key, required this.restaurant, required this.onTap});

  final Restaurant restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                const SizedBox(
                  height: 150,
                  width: double.infinity,
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: ImageFallback(
                    path: restaurant.image,
                    label: restaurant.nom,
                    height: 150,
                    radius: 0,
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                        const SizedBox(width: 2),
                        Text('${restaurant.note}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                if (restaurant.certifie)
                  const Positioned(
                    right: 8,
                    top: 8,
                    child: BadgeCertifie(),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.nom,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.accent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.note}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '• ${restaurant.cuisine}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: AppColors.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.tempsEstime,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF7EE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          restaurant.livraison ? 'Livraison' : 'Sur place',
                          style: const TextStyle(color: Color(0xFF1F8A42), fontWeight: FontWeight.w700, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
