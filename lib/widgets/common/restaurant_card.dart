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
                  Text(restaurant.nom, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('${restaurant.cuisine} • ${restaurant.quartier}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled_rounded, color: AppColors.primary, size: 14),
                      Text(' ${restaurant.tempsEstime}'),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF7EE),
                          borderRadius: BorderRadius.circular(10),
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
