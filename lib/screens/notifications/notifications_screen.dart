import 'package:flutter/material.dart';
import 'package:fast_eat/widgets/common/app_feedback.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/offline_banner.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final notifs = context.watch<NotificationsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, size: 20),
                  ),
                  const Expanded(
                    child: Text(
                      'Notifications',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828),
                      ),
                    ),
                  ),
                  if (auth.isConnected && notifs.items.isNotEmpty)
                    TextButton(
                      onPressed: notifs.isLoading
                          ? null
                          : () async {
                              final ok = await notifs.markAllAsRead();
                              if (!context.mounted) return;
                              AppFeedback.error(context, ok ? 'Toutes les notifications sont lues.' : 'Échec de la mise à jour.');
                            },
                      child: const Text('Tout lire'),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(child: _buildBody(context, auth, notifs)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AuthProvider auth, NotificationsProvider notifs) {
    if (!auth.isConnected) {
      return const EmptyState(
        title: 'Connexion requise',
        subtitle: 'Connectez-vous pour recevoir les alertes commandes et offres.',
        icon: Icons.notifications_off_outlined,
      );
    }

    if (notifs.isLoading && notifs.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifs.lastError != null && notifs.items.isEmpty) {
      return EmptyState(
        title: 'Impossible de charger',
        subtitle: notifs.lastError,
        actionLabel: 'Réessayer',
        onAction: () => notifs.refresh(),
      );
    }

    if (notifs.items.isEmpty) {
      return const EmptyState(
        title: 'Aucune notification',
        subtitle: 'Vous serez alerté ici pour vos commandes et promotions.',
        icon: Icons.notifications_none_rounded,
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifs.refresh(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: notifs.items.length,
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final it = notifs.items[i];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                if (!it.isRead) {
                  await notifs.markAsRead(it.id);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: it.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: it.isRead ? const Color(0xFFF7F8FA) : const Color(0xFFEAF4F4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        it.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                        size: 20,
                        color: it.isRead ? const Color(0xFF98A2B3) : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            it.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: it.isRead ? FontWeight.w600 : FontWeight.w800,
                              color: const Color(0xFF1D2939),
                              height: 1.2,
                            ),
                          ),
                          if (it.body.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              it.body,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.35,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          if (it.createdAt != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              _formatDate(it.createdAt!),
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!it.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}
