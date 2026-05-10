import 'package:flutter/material.dart';

class MesInfosScreen extends StatefulWidget {
  const MesInfosScreen({super.key});

  @override
  State<MesInfosScreen> createState() => _MesInfosScreenState();
}

class _MesInfosScreenState extends State<MesInfosScreen> {
  final nomCtrl = TextEditingController(text: 'Koffi Mensah');
  final telCtrl = TextEditingController(text: '+229 90 00 00 00');
  final emailCtrl = TextEditingController(text: 'koffi.mensah@email.com');

  @override
  void dispose() {
    nomCtrl.dispose();
    telCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes infos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom complet')),
          const SizedBox(height: 12),
          TextField(controller: telCtrl, decoration: const InputDecoration(labelText: 'Telephone')),
          const SizedBox(height: 12),
          TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Informations enregistrees (simulation).')),
              );
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
