import 'package:flutter/material.dart';
import 'package:fast_eat/widgets/common/app_feedback.dart';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../theme/app_theme.dart';

/// Screen for creating a new reservation.
/// Can be pre-filled with a restaurant id/nom when coming from a restaurant page.
class NouvelleReservationScreen extends StatefulWidget {
  const NouvelleReservationScreen({
    super.key,
    this.restaurantId,
    this.restaurantNom,
    this.restaurantImage,
  });

  final String? restaurantId;
  final String? restaurantNom;
  final String? restaurantImage;

  @override
  State<NouvelleReservationScreen> createState() => _NouvelleReservationScreenState();
}

class _NouvelleReservationScreenState extends State<NouvelleReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentaireCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _nombrePersonnes = 2;
  bool _submitting = false;

  // Créneaux de 30 min entre 8h et 22h
  static final List<TimeOfDay> _creneaux = [
    for (int h = 8; h <= 21; h++)
      ...[TimeOfDay(hour: h, minute: 0), TimeOfDay(hour: h, minute: 30)],
    const TimeOfDay(hour: 22, minute: 0),
  ];

  @override
  void dispose() {
    _commentaireCtrl.dispose();
    super.dispose();
  }

  String _heureLabel(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _dateLabel(DateTime d) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const months = ['jan', 'fév', 'mar', 'avr', 'mai', 'juin', 'juil', 'août', 'sep', 'oct', 'nov', 'déc'];
    return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      helpText: 'Sélectionnez une date',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showError('Veuillez choisir une date.');
      return;
    }
    if (_selectedTime == null) {
      _showError('Veuillez choisir un créneau horaire.');
      return;
    }
    final auth = context.read<AuthProvider>();
    if (!auth.isConnected) {
      _showError('Vous devez être connecté pour réserver.');
      return;
    }

    setState(() => _submitting = true);
    HapticFeedback.mediumImpact();

    final prov = context.read<ReservationsProvider>();
    final res = await prov.creer(
      restaurantId: widget.restaurantId ?? '',
      restaurantNom: widget.restaurantNom ?? 'Restaurant',
      restaurantImage: widget.restaurantImage,
      date: _selectedDate!,
      heure: _heureLabel(_selectedTime!),
      nombrePersonnes: _nombrePersonnes,
      commentaire: _commentaireCtrl.text.trim().isEmpty ? null : _commentaireCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (res != null) {
      HapticFeedback.heavyImpact();
      _showSuccess(prov.backendAvailable);
    } else {
      _showError(prov.lastError ?? 'Une erreur est survenue.');
    }
  }

  void _showError(String msg) {
    AppFeedback.error(context, msg);
  }

  void _showSuccess(bool backendOk) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Réservation envoyée !',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              backendOk
                  ? 'Votre demande a été transmise au restaurant. Vous serez notifié(e) dès confirmation.'
                  : 'Votre réservation est enregistrée. Elle sera envoyée au restaurant dès que la connexion sera rétablie.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(c);
                context.pop(true);
              },
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Réserver une table', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          children: [
            // En-tête restaurant
            if (widget.restaurantNom != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withValues(alpha: 0.08), AppColors.primary.withValues(alpha: 0.04)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Réservation pour', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            widget.restaurantNom!,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Nombre de personnes
            _sectionTitle('Nombre de personnes'),
            const SizedBox(height: 12),
            Container(
              decoration: _cardDeco(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.people_outline_rounded, color: AppColors.primary, size: 22),
                      SizedBox(width: 10),
                      Text('Convives', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    ],
                  ),
                  Row(
                    children: [
                      _stepperBtn(Icons.remove_rounded, () {
                        if (_nombrePersonnes > 1) setState(() => _nombrePersonnes--);
                        HapticFeedback.selectionClick();
                      }),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 36,
                        child: Text(
                          '$_nombrePersonnes',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _stepperBtn(Icons.add_rounded, () {
                        if (_nombrePersonnes < 30) setState(() => _nombrePersonnes++);
                        HapticFeedback.selectionClick();
                      }),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Date
            _sectionTitle('Date'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                decoration: _cardDeco(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null ? 'Choisir une date' : _dateLabel(_selectedDate!),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: _selectedDate == null ? AppColors.textSecondary : AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Heure
            _sectionTitle('Heure'),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _creneaux.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final t = _creneaux[i];
                  final selected = _selectedTime == t;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedTime = t);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _heureLabel(t),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: selected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Commentaire
            _sectionTitle('Commentaire (optionnel)'),
            const SizedBox(height: 12),
            TextField(
              controller: _commentaireCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ex: Anniversaire, allergie, besoin d\'une chaise bébé...',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.comment_outlined, size: 20),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Bouton soumettre
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 18),
                          SizedBox(width: 10),
                          Text('Envoyer la demande', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Le restaurant confirmera votre demande dans les plus brefs délais.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
    );
  }

  BoxDecoration _cardDeco() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
      ],
    );
  }

  Widget _stepperBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }
}
