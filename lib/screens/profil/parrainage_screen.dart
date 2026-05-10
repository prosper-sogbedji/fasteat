import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../data/mock/mock_user.dart';
import '../../widgets/common/formatters.dart';
import '../../widgets/common/bottom_nav_bar.dart';

class ParrainageScreen extends StatelessWidget {
  const ParrainageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Programme de parrainage'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFC8102E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Gagnez des repas gratuits',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Parrainez vos amis et gagnez des credits.', style: TextStyle(fontSize: 15)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Expanded(child: Text('Code: FAST-2024', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18))),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.copy_rounded)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.share_rounded)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text('12', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
                        Text('Amis parraines'),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(fcfa(mockUser.soldeCredits), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                        Text('Credits cumules'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Comment ca marche ?', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _step(1, 'Partagez votre code', 'Envoyez votre code unique a vos amis via WhatsApp ou SMS.'),
          const SizedBox(height: 8),
          _step(2, 'Ils commandent', 'Vos amis reçoivent 1.000 FCFA de réduction sur leur première commande.'),
          const SizedBox(height: 8),
          _step(3, 'Vous gagnez', 'Vous recevez 1.500 FCFA de crédit dès que leur commande est livrée.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text('Partager mon code'),
          ),
        ],
      ),
      bottomNavigationBar: FastEatBottomNavBar(
        currentIndex: 3,
        onTap: (i) {
          if (i == 0) context.go(AppRoutes.home);
          if (i == 1) context.go(AppRoutes.favoris);
          if (i == 2) context.go(AppRoutes.historique);
        },
      ),
    );
  }

  Widget _step(int idx, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: const Color(0xFFC8102E),
          child: Text('$idx', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }
}
