import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../core/session_sync.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../theme/app_theme.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 10, AppSpacing.xl, AppSpacing.xl),
        children: [
          // ---- Carte utilisateur ----
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: AppSizes.avatarMd,
                    height: AppSizes.avatarMd,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6F3F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 22,
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
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, height: 1),
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ---- Section Compte ----
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
              (icon: Icons.person_outline_rounded, label: 'Mon profil', route: AppRoutes.mesInfos),
              (icon: Icons.location_on_outlined, label: 'Mes adresses', route: AppRoutes.adresses),
            ]),
          ),
          const SizedBox(height: 12),

          // ---- Section Préférences ----
          const Text(
            'Préférences',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _sectionCard(
            children: _sectionItems(context, [
              (icon: Icons.settings_outlined, label: 'Paramètres', route: AppRoutes.parametres),
              (icon: Icons.help_outline_rounded, label: "Centre d'aide", route: AppRoutes.aide),
            ]),
          ),
          const SizedBox(height: 14),

          // ---- Bouton déconnexion ----
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
            child: const Text('Déconnexion'),
          ),
          const SizedBox(height: 16),

          // ---- Version (discrète) ----
          const Center(
            child: Text(
              'FastEat v1.0.1',
              style: TextStyle(fontSize: 11, color: Colors.black26, letterSpacing: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Card(
      margin: EdgeInsets.zero,
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
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Divider(height: 1),
        );
      }
      final item = items[index ~/ 2];
      return _item(context, item.icon, item.label, item.route);
    });
  }

  Widget _item(BuildContext context, IconData icon, String t, String route) {
    return ListTile(
      leading: Icon(icon, size: 21, color: const Color(0xFF465153)),
      title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(route),
    );
  }
}
