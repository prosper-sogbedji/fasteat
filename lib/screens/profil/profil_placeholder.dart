import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../core/session_sync.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../theme/app_theme.dart';

class ProfilPlaceholderScreen extends StatelessWidget {
  const ProfilPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6F3F2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            user.initials,
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.nom,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 28, height: 1),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.telephone,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5D8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: Color(0xFF6D5C2E),
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5D8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_rounded, size: 16, color: Color(0xFF8A6D1D)),
                        SizedBox(width: 8),
                        Text(
                          'Compte verifie',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF6D5C2E)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Compte',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _sectionCard(
            children: _sectionItems(context, [
              (icon: Icons.location_on_outlined, label: 'Mes adresses', route: AppRoutes.adresses),
              (icon: Icons.reviews_outlined, label: 'Mes avis', route: AppRoutes.avis),
            ]),
          ),
          const SizedBox(height: 12),
          const Text(
            'Paiement et preferences',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _sectionCard(
            children: _sectionItems(context, [
              (icon: Icons.credit_card_rounded, label: 'Mode de paiement', route: AppRoutes.paiementChoix),
              (icon: Icons.person_outline_rounded, label: 'Mes infos', route: AppRoutes.mesInfos),
              (icon: Icons.settings_outlined, label: 'Paramètres', route: AppRoutes.parametres),
            ]),
          ),
          const SizedBox(height: 12),
          const Text(
            'Assistance',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _sectionCard(
            children: _sectionItems(context, [
              (icon: Icons.help_outline_rounded, label: 'Centre d\'Aide', route: AppRoutes.aide),
            ]),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () async {
              final favorites = context.read<FavoritesProvider>();
              final notifications = context.read<NotificationsProvider>();
              await context.read<AuthProvider>().logout();
              clearClientSessionData(favorites: favorites, notifications: notifications);
              if (context.mounted) context.go(AppRoutes.connexion);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFB42318),
              side: const BorderSide(color: Color(0xFFF3D5D2)),
            ),
            child: const Text('Deconnexion'),
          ),
          const SizedBox(height: 10),
          const Center(child: Text('Version 1.0.1+build 001', style: TextStyle(fontSize: 11, color: Colors.black45))),
        ],
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Card(
      child: Column(children: children),
    );
  }

  List<Widget> _sectionItems(
    BuildContext context,
    List<({IconData icon, String label, String route})> items,
  ) {
    return List.generate(items.length * 2 - 1, (index) {
      if (index.isOdd) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Divider(height: 1),
        );
      }
      final item = items[index ~/ 2];
      return _item(context, item.icon, item.label, item.route);
    });
  }

  Widget _item(BuildContext context, IconData icon, String t, String route) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      minVerticalPadding: 8,
      leading: Icon(icon, size: 21, color: const Color(0xFF465153)),
      title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(route),
    );
  }
}
