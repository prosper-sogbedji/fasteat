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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = bottomInset > 0 ? bottomInset + 12.0 : 24.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Laisser un avis')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(Icons.restaurant)),
                      title: Text('Attiéké poisson braisé'),
                      subtitle: Text('Vendu par « Saveurs du Littoral »'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Quelle note donneriez-vous ?', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(
                      5,
                      (i) => IconButton(
                        onPressed: () => setState(() => note = i + 1),
                        icon: Icon(
                          i < note ? Icons.star_rounded : Icons.star_border_rounded,
                          color: const Color(0xFFFF6B00),
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    note >= 4 ? 'Excellent' : note == 3 ? 'Bien' : 'À améliorer',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: avisCtrl,
                    maxLines: 5,
                    minLines: 3,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Partagez votre expérience...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('${avisCtrl.text.length} / 500', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Ajouter une photo du plat'),
                  ),
                  SizedBox(height: bottomPad),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset > 0 ? 8 : 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Publier mon avis'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
