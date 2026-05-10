import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class MtnButton extends StatelessWidget {
  const MtnButton({super.key, required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.mtnMoMo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.textPrimary : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet_rounded),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MTN Mobile Money', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text('Payer avec MTN MoMo', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle_rounded),
          ],
        ),
      ),
    );
  }
}
