import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key});

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  int _mobileViewIndex = 0; // 0 = Chat List, 1 = Chat Area, 2 = Order Details

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final List<Map<String, dynamic>> _chatMessages = [
    {
      'text': 'Bonjour, j\'ai passé commande il y a 45 minutes mais je ne vois toujours pas le livreur sur la carte.',
      'time': '14:20',
      'isMe': false
    },
    {
      'text': 'Où est ma commande #FE-2024 ?',
      'time': '14:25',
      'isMe': false
    },
    {
      'text': 'Bonjour M. Mensah, je vérifie immédiatement avec notre livreur Sekou. Veuillez m\'excuser pour ce délai.',
      'time': '14:28',
      'isMe': true
    },
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _envoyerMessage(String text) {
    final txt = text.trim();
    if (txt.isEmpty) return;

    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    setState(() {
      _chatMessages.add({
        'text': txt,
        'time': timeStr,
        'isMe': true,
      });
    });

    _textController.clear();

    // Défilement automatique fluide vers le bas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildChatList(isDesktop)),
            Container(width: 1, color: Colors.grey.withOpacity(0.1)),
            Expanded(flex: 5, child: _buildChatArea(isDesktop)),
            Container(width: 1, color: Colors.grey.withOpacity(0.1)),
            Expanded(flex: 3, child: _buildOrderDetails(isDesktop)),
          ],
        ),
      );
    }

    // Mobile/Tablet View routing
    Widget activeWidget;
    switch (_mobileViewIndex) {
      case 0:
        activeWidget = _buildChatList(isDesktop);
        break;
      case 1:
        activeWidget = _buildChatArea(isDesktop);
        break;
      case 2:
        activeWidget = _buildOrderDetails(isDesktop);
        break;
      default:
        activeWidget = _buildChatList(isDesktop);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(child: activeWidget),
    );
  }

  Widget _buildChatList(bool isDesktop) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                  hintText: 'Rechercher un client...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Expanded(
            child: ListView(
              children: [
                _chatTile('Koffi Mensah', 'Où est ma commande #FE-2024 ?', '14:25', true, 'assets/images/resto_real_1.jpg', () {
                  if (!isDesktop) {
                    setState(() => _mobileViewIndex = 1);
                  }
                }),
                _chatTile('Abla Gnonlonfoun', 'Merci pour le piment supplémentaire !', '12:10', false, 'assets/images/resto_real_2.jpg', () {
                  if (!isDesktop) {
                    setState(() => _mobileViewIndex = 1);
                  }
                }),
                _chatTile('Sébastien Zinsou', 'Livraison très rapide, bravo.', 'Hier', false, 'assets/images/resto_real_1.jpg', () {
                  if (!isDesktop) {
                    setState(() => _mobileViewIndex = 1);
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatTile(String name, String message, String time, bool isActive, String img, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isActive ? AppColors.primary.withOpacity(0.05) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            CircleAvatar(backgroundImage: AssetImage(img), radius: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: TextStyle(
                          fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                          color: isActive ? AppColors.primary : const Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: isActive ? AppColors.primary : const Color(0xFF64748B),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea(bool isDesktop) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (!isDesktop) ...[
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF64748B)),
                          onPressed: () => setState(() => _mobileViewIndex = 0),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Stack(
                        children: [
                          const CircleAvatar(backgroundImage: AssetImage('assets/images/resto_real_1.jpg'), radius: 24),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Koffi Mensah',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text('En ligne', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B)),
                      onPressed: () {
                        if (!isDesktop) {
                          setState(() => _mobileViewIndex = 2);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: _chatMessages.length + 1,
              itemBuilder: (context, index) {
                if (index == _chatMessages.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'LIVREUR EN ROUTE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                        ),
                      ),
                    ),
                  );
                }

                final msg = _chatMessages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _messageBubble(
                    msg['text'] as String,
                    msg['time'] as String,
                    msg['isMe'] as bool,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _quickReply('Votre livreur arrive', () => _envoyerMessage('Votre livreur arrive M. Mensah.')),
                  _quickReply('Désolé pour le retard', () => _envoyerMessage('Toutes nos excuses pour le retard, nous faisons au plus vite.')),
                  _quickReply('Commande validée', () => _envoyerMessage('Votre commande #FE-2024 a bien été validée en cuisine !')),
                  _quickReply('Bon appétit', () => _envoyerMessage('FastEat vous souhaite un excellent appétit !')),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.add_circle_outline, color: Color(0xFF94A3B8)), onPressed: () {}),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: _envoyerMessage,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Écrivez votre message...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _envoyerMessage(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(String text, String time, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe ? const Radius.circular(0) : null,
            bottomLeft: !isMe ? const Radius.circular(0) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : const Color(0xFF0F172A),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: TextStyle(
                color: isMe ? Colors.white70 : const Color(0xFF94A3B8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickReply(String text, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetails(bool isDesktop) {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (!isDesktop) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
                  onPressed: () => setState(() => _mobileViewIndex = 1),
                ),
                const SizedBox(width: 8),
              ],
              const Expanded(
                child: Text(
                  'Détails de la Commande',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('RÉFÉRENCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                                  SizedBox(height: 4),
                                  Text(
                                    '#FE-2024',
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(20)),
                              child: const Text('EN CUISINE', style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w900, fontSize: 10)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: const [
                            Expanded(
                              child: Text(
                                '2x Atassi Spécial',
                                style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('5.000 CFA', style: TextStyle(color: Color(0xFF94A3B8))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: const [
                            Expanded(
                              child: Text(
                                '1x Jus de Bissap',
                                style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('500 CFA', style: TextStyle(color: Color(0xFF94A3B8))),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(),
                        ),
                        Row(
                          children: const [
                            Expanded(
                              child: Text(
                                'Total',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('5.500 CFA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('LIVREUR ASSIGNÉ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(backgroundImage: AssetImage('assets/images/resto_real_2.jpg'), radius: 20),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Sekou Diallo', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                              Text('Moto • BJ-7291', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('PAIEMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(color: const Color(0xFFFFCC00), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'MTN MoMo',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: const Text('PAYÉ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {},
              child: const Text('Annuler la commande', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
