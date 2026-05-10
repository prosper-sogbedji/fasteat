import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_routes.dart';
import '../../providers/panier_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/formatters.dart';

class CommandeConfirmeeScreen extends StatefulWidget {
  const CommandeConfirmeeScreen({super.key});

  @override
  State<CommandeConfirmeeScreen> createState() => _CommandeConfirmeeScreenState();
}

class _CommandeConfirmeeScreenState extends State<CommandeConfirmeeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = context.watch<PanierProvider>().sousTotal;
    return Scaffold(
      appBar: AppBar(title: const Text('FASTEAT BENIN'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ScaleTransition(
                  scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
                  child: const CircleAvatar(
                    radius: 46,
                    backgroundColor: Color(0xFFEAF7EE),
                    child: Icon(Icons.check_rounded, size: 50, color: Color(0xFF2ECC71)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Commande envoyee', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text(
                  'Votre commande est transmise au restaurant pour validation.',
                  style: TextStyle(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(10)),
                  child: const Text('#FE-2047', style: TextStyle(fontFamily: 'monospace', fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFC8102E))),
                ),
                const SizedBox(height: 16),
                const ListTile(leading: Icon(Icons.restaurant), title: Text('Restaurant'), subtitle: Text('Saveurs du Benin - Akpakpa')),
                const ListTile(leading: Icon(Icons.schedule), title: Text('Heure prevue'), subtitle: Text('12:45 - 13:00 (Aujourd\'hui)')),
                const ListTile(leading: Icon(Icons.delivery_dining), title: Text('Mode'), subtitle: Text('Livraison Express')),
                const SizedBox(height: 8),
                FilledButton(onPressed: () => context.go(AppRoutes.suivi), child: const Text('Suivre ma commande')),
                TextButton(onPressed: () => context.go(AppRoutes.home), child: const Text("Retour a l'accueil")),
                const SizedBox(height: 10),
                Text('Paye avec MoMo  ${fcfa(total)}', style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: FastEatBottomNavBar(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) context.go(AppRoutes.home);
          if (i == 1) context.go(AppRoutes.favoris);
          if (i == 3) context.go(AppRoutes.profil);
        },
      ),
    );
  }
}
