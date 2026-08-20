import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/adresse.dart';
import '../../providers/adresses_provider.dart';
import '../../theme/app_theme.dart';

class AdressesScreen extends StatelessWidget {
  const AdressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdressesProvider>();
    final adresses = provider.adresses;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Adresses', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: adresses.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on_rounded, size: 40, color: AppColors.primary),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Aucune adresse',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ajoutez une adresse pour faciliter vos prochaines commandes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: adresses.length,
              itemBuilder: (context, index) {
                final a = adresses[index];
                return _AdresseCard(adresse: a);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAdresseDialog(context, null),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Ajouter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _showAdresseDialog(BuildContext context, Adresse? adresse) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AdresseFormSheet(adresse: adresse),
    );
  }
}

class _AdresseCard extends StatelessWidget {
  const _AdresseCard({required this.adresse});

  final Adresse adresse;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: adresse.isDefault ? AppColors.primary.withValues(alpha: 0.5) : AppColors.border,
          width: adresse.isDefault ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.lightImpact();
          context.read<AdressesProvider>().setDefault(adresse.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _getIconForTitre(adresse.titre),
                color: adresse.isDefault ? AppColors.primary : AppColors.textSecondary,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          adresse.titre,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                        ),
                        if (adresse.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Par défaut',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      adresse.adresse,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                    ),
                    if (adresse.complement.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Complément: ${adresse.complement}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      adresse.telephone,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (val) {
                  if (val == 'edit') {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => _AdresseFormSheet(adresse: adresse),
                    );
                  } else if (val == 'delete') {
                    context.read<AdressesProvider>().removeAdresse(adresse.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 20),
                        SizedBox(width: 10),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                        SizedBox(width: 10),
                        Text('Supprimer', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForTitre(String titre) {
    final t = titre.toLowerCase();
    if (t.contains('maison') || t.contains('domicile') || t.contains('home')) return Icons.home_rounded;
    if (t.contains('bureau') || t.contains('travail') || t.contains('work')) return Icons.work_rounded;
    return Icons.location_on_rounded;
  }
}

class _AdresseFormSheet extends StatefulWidget {
  const _AdresseFormSheet({this.adresse});

  final Adresse? adresse;

  @override
  State<_AdresseFormSheet> createState() => _AdresseFormSheetState();
}

class _AdresseFormSheetState extends State<_AdresseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titreController;
  late TextEditingController _adresseController;
  late TextEditingController _complementController;
  late TextEditingController _telephoneController;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final a = widget.adresse;
    _titreController = TextEditingController(text: a?.titre ?? '');
    _adresseController = TextEditingController(text: a?.adresse ?? '');
    _complementController = TextEditingController(text: a?.complement ?? '');
    _telephoneController = TextEditingController(text: a?.telephone ?? '');
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _titreController.dispose();
    _adresseController.dispose();
    _complementController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newAdresse = Adresse(
        id: widget.adresse?.id,
        titre: _titreController.text.trim(),
        adresse: _adresseController.text.trim(),
        complement: _complementController.text.trim(),
        telephone: _telephoneController.text.trim(),
        isDefault: _isDefault,
      );

      if (widget.adresse == null) {
        context.read<AdressesProvider>().addAdresse(newAdresse);
      } else {
        context.read<AdressesProvider>().updateAdresse(newAdresse.id, newAdresse);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.adresse != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEdit ? 'Modifier l\'adresse' : 'Nouvelle adresse',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titreController,
              decoration: const InputDecoration(
                labelText: 'Titre (ex: Maison, Bureau)',
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _adresseController,
              decoration: const InputDecoration(
                labelText: 'Adresse complète',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _complementController,
              decoration: const InputDecoration(
                labelText: 'Complément (bâtiment, code...)',
                prefixIcon: Icon(Icons.apartment_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telephoneController,
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
              validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Définir comme adresse par défaut', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primary,
              value: _isDefault,
              onChanged: (val) {
                setState(() => _isDefault = val);
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
