import 'package:flutter/material.dart';

class LaisserAvisScreen extends StatefulWidget {
  const LaisserAvisScreen({super.key});

  @override
  State<LaisserAvisScreen> createState() => _LaisserAvisScreenState();
}

class _LaisserAvisScreenState extends State<LaisserAvisScreen> {
  int note = 4;
  final avisCtrl = TextEditingController();

  @override
  void dispose() {
    avisCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laisser un avis')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              child: ListTile(
                leading: CircleAvatar(child: Icon(Icons.restaurant)),
                title: Text('Attieke Poisson Braise'),
                subtitle: Text('Vendu par "Saveurs du Littoral"'),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Quelle note donneriez-vous ?', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Row(
              children: List.generate(
                5,
                (i) => IconButton(
                  onPressed: () => setState(() => note = i + 1),
                  icon: Icon(i < note ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFFF6B00)),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              note >= 4 ? 'Excellent' : note == 3 ? 'Bien' : 'A ameliorer',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: avisCtrl,
              maxLines: 5,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'Partagez votre experience...'),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text('${avisCtrl.text.length} / 500', style: const TextStyle(fontSize: 11, color: Colors.black54)),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.camera_alt_outlined), label: const Text('Ajouter une photo du plat')),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Publier mon avis'),
            ),
          ],
        ),
      ),
    );
  }
}
