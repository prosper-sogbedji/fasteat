import 'package:flutter/material.dart';

import '../../widgets/common/image_fallback.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saveurs de Cotonou', style: TextStyle(fontSize: 15)),
            Text('En ligne', style: TextStyle(fontSize: 11, color: Colors.green)),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.call_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text('AUJOURD\'HUI', style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w700)),
                  ),
                ),
                _Bubble(left: true, text: 'Bonjour, votre commande est en preparation.'),
                _Bubble(left: false, text: 'Super, merci !'),
                _Bubble(left: true, text: 'Elle sera prete dans 10 minutes.'),
                _ImageBubble(),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline)),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(hintText: 'Ecrire un message...'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    onPressed: () {},
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageBubble extends StatelessWidget {
  const _ImageBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 220,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: const ImageFallback(
          path: 'assets/images/mockup_home_restaurant.png',
          label: 'Photo du plat en preparation',
          height: 130,
          radius: 14,
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.left, required this.text});

  final bool left;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: left ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: left ? const Color(0xFFF1F1F1) : const Color(0xFFE63946),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: TextStyle(color: left ? Colors.black87 : Colors.white)),
            const SizedBox(height: 4),
            Text('12:45', style: TextStyle(fontSize: 10, color: left ? Colors.black45 : Colors.white70)),
          ],
        ),
      ),
    );
  }
}
