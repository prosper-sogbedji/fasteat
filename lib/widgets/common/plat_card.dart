import 'package:flutter/material.dart';

import '../../models/plat.dart';
import '../../theme/app_theme.dart';

class PlatCard extends StatelessWidget {
  const PlatCard({
    super.key,
    required this.plat,
    required this.onAdd,
    this.onTap,
  });

  final Plat plat;
  final VoidCallback onAdd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(10),
        leading: SizedBox(
          width: 72,
          height: 72,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              plat.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFFFE6D5),
                alignment: Alignment.center,
                child: Text(plat.nom, maxLines: 2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.primaryDark)),
              ),
            ),
          ),
        ),
        title: Text(plat.nom),
        subtitle: Text(plat.description, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${plat.prix} FCFA', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            IconButton(
              onPressed: onAdd,
              icon: const CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.add, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
