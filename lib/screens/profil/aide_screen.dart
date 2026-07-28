import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_feedback.dart';

class AideScreen extends StatelessWidget {
  const AideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Centre d\'Aide', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Contactez-nous', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ContactCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Chat',
                  subtitle: 'Réponse rapide',
                  onTap: () => context.push(AppRoutes.chat),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ContactCard(
                  icon: Icons.phone_outlined,
                  title: 'Appeler',
                  subtitle: 'Assistance directe',
                  onTap: () => AppFeedback.info(context, 'Appel support indisponible pour le moment. Utilisez le chat.'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Questions fréquentes (FAQ)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const _FaqItem(
            question: 'Comment annuler ma commande ?',
            answer: 'Vous pouvez annuler votre commande dans les 5 minutes suivant sa validation depuis l\'écran de suivi.',
          ),
          const _FaqItem(
            question: 'Je n\'ai pas reçu ma commande, que faire ?',
            answer: 'Vérifiez d\'abord l\'état de la commande dans le suivi. Si le statut est livré, contactez le support via le chat ou par téléphone.',
          ),
          const _FaqItem(
            question: 'Comment utiliser un code promo ?',
            answer: 'Lors de la validation de votre panier, vous verrez un champ "Code promo". Entrez votre code et cliquez sur "Appliquer".',
          ),
          const _FaqItem(
            question: 'Les livreurs ont-ils la monnaie ?',
            answer: 'Oui, nos livreurs disposent d\'un fonds de caisse limité. Cependant, nous vous encourageons à faire l\'appoint ou à payer par Mobile Money.',
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textSecondary,
        shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.transparent)),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          Text(answer, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
        ],
      ),
    );
  }
}
