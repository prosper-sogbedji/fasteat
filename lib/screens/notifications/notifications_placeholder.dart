import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

class NotificationsPlaceholderScreen extends StatelessWidget {
  const NotificationsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        title: 'Nouvel appartement',
        subtitle: "Meat Lovers is filled with toppings of sliced beef, saus age, minced beef and meats that are many",
        unread: true
      ),
      (
        title: 'Nouvel appartement',
        subtitle: "Meat Lovers is filled with toppings of sliced beef, saus age, minced beef and meats that are many",
        unread: true
      ),
      (
        title: 'Nouvel appartement',
        subtitle: "Meat Lovers is filled with toppings of sliced beef, saus age, minced beef and meats that are many",
        unread: false
      ),
      (
        title: 'Nouvel appartement',
        subtitle: "Meat Lovers is filled with toppings of sliced beef, saus age, minced beef and meats that are many",
        unread: false
      ),
      (
        title: 'Nouvel appartement',
        subtitle: "Meat Lovers is filled with toppings of sliced beef, saus age, minced beef and meats that are many",
        unread: false
      ),
      (
        title: 'Nouvel appartement',
        subtitle: "Meat Lovers is filled with toppings of sliced beef, saus age, minced beef and meats that are many",
        unread: false
      ),
    ];

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
                      'Notification',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final it = items[i];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            it.unread ? Icons.notifications_rounded : Icons.notifications_none_rounded,
                            size: 16,
                            color: it.unread ? const Color(0xFF246BFD) : const Color(0xFF98A2B3),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                it.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D2939),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                it.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  height: 1.3,
                                  color: Color(0xFF98A2B3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
