import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/reservation.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../theme/app_theme.dart';

/// Résultat retourné par le bottom sheet de réservation.
class ReservationResult {
  const ReservationResult({required this.reservation});
  final Reservation reservation;
}

/// Ouvre le formulaire de réservation en bottom sheet.
/// Retourne un [ReservationResult] si confirmée, null si annulée.
Future<ReservationResult?> showReservationBottomSheet(
  BuildContext context, {
  required String restaurantId,
  required String restaurantNom,
  String? restaurantImage,
}) {
  return showModalBottomSheet<ReservationResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ReservationSheet(
      restaurantId: restaurantId,
      restaurantNom: restaurantNom,
      restaurantImage: restaurantImage,
    ),
  );
}

// ─── Créneaux horaires ─────────────────────────────────────────────────────────
List<TimeOfDay> _buildCreneaux() {
  final list = <TimeOfDay>[];
  for (int h = 8; h <= 21; h++) {
    list.add(TimeOfDay(hour: h, minute: 0));
    list.add(TimeOfDay(hour: h, minute: 30));
  }
  list.add(const TimeOfDay(hour: 22, minute: 0));
  return list;
}

// ─── Widget principal ─────────────────────────────────────────────────────────
class _ReservationSheet extends StatefulWidget {
  const _ReservationSheet({
    required this.restaurantId,
    required this.restaurantNom,
    this.restaurantImage,
  });

  final String restaurantId;
  final String restaurantNom;
  final String? restaurantImage;

  @override
  State<_ReservationSheet> createState() => _ReservationSheetState();
}

class _ReservationSheetState extends State<_ReservationSheet> {
  final _commentaireCtrl = TextEditingController();
  final _creneaux = _buildCreneaux();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _nombrePersonnes = 2;
  bool _submitting = false;
  bool _success = false;
  Reservation? _createdReservation;

  @override
  void dispose() {
    _commentaireCtrl.dispose();
    super.dispose();
  }

  String _heureLabel(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _dateLabel(DateTime d) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc',
    ];
    return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  // ── Sélecteur de date personnalisé ──────────────────────────────────────────
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      // Aujourd'hui comme date minimale (pas demain)
      initialDate: _selectedDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
      helpText: 'Choisir une date',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
            outline: Colors.grey.shade300,
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 8,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _selectedDate = picked);
  }

  // ── Soumission ────────────────────────────────────────────────────────────
  Future<void> _submit() async {
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

    // Afficher le spinner seulement si l'appel prend du temps
    // (on lance l'appel sans bloquer l'UI immédiatement)
    HapticFeedback.mediumImpact();
    setState(() => _submitting = true);

    final prov = context.read<ReservationsProvider>();
    final res = await prov.creer(
      restaurantId: widget.restaurantId,
      restaurantNom: widget.restaurantNom,
      restaurantImage: widget.restaurantImage,
      date: _selectedDate!,
      heure: _heureLabel(_selectedTime!),
      nombrePersonnes: _nombrePersonnes,
      commentaire: _commentaireCtrl.text.trim().isEmpty
          ? null
          : _commentaireCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    // Le provider renvoie toujours un résultat (local ou API)
    if (res != null) {
      HapticFeedback.heavyImpact();
      setState(() {
        _success = true;
        _createdReservation = res;
      });
    } else {
      _showError(prov.lastError ?? 'Une erreur est survenue.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      maxChildSize: 0.95,
      minChildSize: 0.45,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            // ── Drag handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: 36,
                height: 3.5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            // ── En-tête
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 6, 10),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.table_restaurant_rounded,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Réserver une table',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.black87),
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: Colors.black54),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade100),
            // ── Corps
            Expanded(
              child: _success ? _buildSuccess() : _buildForm(scrollCtrl),
            ),
          ],
        ),
      ),
    );
  }

  // ── Vue succès ───────────────────────────────────────────────────────────
  Widget _buildSuccess() {
    final r = _createdReservation!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Icône succès
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                size: 34, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          const Text(
            'Table réservée !',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 19,
                color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Votre demande a été transmise. Le restaurant vous confirmera dans les meilleurs délais.',
            style: TextStyle(
                color: Colors.grey.shade500, fontSize: 12.5, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // ── Carte récap
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _recapRow(Icons.storefront_rounded, 'Restaurant',
                    r.restaurantNom),
                _divider(),
                _recapRow(Icons.calendar_month_rounded, 'Date',
                    _dateLabel(r.date)),
                _divider(),
                _recapRow(Icons.access_time_rounded, 'Heure', r.heure),
                _divider(),
                _recapRow(
                  Icons.people_outline_rounded,
                  'Convives',
                  '${r.nombrePersonnes} personne${r.nombrePersonnes > 1 ? 's' : ''}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // ── Bouton retour
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(ReservationResult(reservation: r)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)),
                elevation: 0,
              ),
              child: const Text(
                'Continuer ma commande',
                style:
                    TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _recapRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: Colors.black87)),
          ],
        ),
      );

  Widget _divider() =>
      Divider(height: 1, color: Colors.grey.shade200);

  // ── Formulaire ───────────────────────────────────────────────────────────
  Widget _buildForm(ScrollController scrollCtrl) {
    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 36),
      children: [
        // Restaurant
        _restaurantBadge(),
        const SizedBox(height: 18),

        // ── Nombre de personnes
        _label('Nombre de convives'),
        const SizedBox(height: 8),
        _personnesStepper(),
        const SizedBox(height: 18),

        // ── Date
        _label('Date'),
        const SizedBox(height: 8),
        _datePicker(),
        const SizedBox(height: 18),

        // ── Créneau horaire
        _label('Heure'),
        const SizedBox(height: 8),
        _creneauxGrid(),
        const SizedBox(height: 18),

        // ── Commentaire
        _label('Note (optionnel)'),
        const SizedBox(height: 8),
        _commentField(),
        const SizedBox(height: 22),

        // ── Bouton
        _submitButton(),
        const SizedBox(height: 8),
        Text(
          'Le restaurant confirmera votre demande rapidement.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  Widget _restaurantBadge() => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(11),
          border:
              Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(Icons.storefront_rounded,
                color: AppColors.primary, size: 17),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.restaurantNom,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: Colors.black87),
              ),
            ),
          ],
        ),
      );

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
            color: Colors.black87,
            letterSpacing: 0.2),
      );

  Widget _personnesStepper() => Container(
        decoration: _cardDeco(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.people_outline_rounded,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            const Text('Convives',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: Colors.black87)),
            const Spacer(),
            _stepBtn(Icons.remove_rounded, () {
              if (_nombrePersonnes > 1) {
                setState(() => _nombrePersonnes--);
                HapticFeedback.selectionClick();
              }
            }),
            SizedBox(
              width: 32,
              child: Text(
                '$_nombrePersonnes',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary),
              ),
            ),
            _stepBtn(Icons.add_rounded, () {
              if (_nombrePersonnes < 30) {
                setState(() => _nombrePersonnes++);
                HapticFeedback.selectionClick();
              }
            }),
          ],
        ),
      );

  Widget _stepBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
      );

  Widget _datePicker() => GestureDetector(
        onTap: _pickDate,
        child: Container(
          decoration: _cardDeco(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.calendar_month_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _selectedDate == null
                      ? 'Sélectionner une date'
                      : _dateLabel(_selectedDate!),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: _selectedDate == null
                        ? Colors.grey.shade400
                        : Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400, size: 18),
            ],
          ),
        ),
      );

  Widget _creneauxGrid() {
    // Afficher les créneaux en grille de 4 colonnes — plus propre
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: _creneaux.map((t) {
        final sel = _selectedTime != null &&
            _selectedTime!.hour == t.hour &&
            _selectedTime!.minute == t.minute;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedTime = t);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: sel ? AppColors.primary : Colors.grey.shade200,
                width: sel ? 1.5 : 1.2,
              ),
              boxShadow: sel
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              _heureLabel(t),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: sel ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _commentField() => TextField(
        controller: _commentaireCtrl,
        maxLines: 2,
        style: const TextStyle(fontSize: 13),
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: 'Ex : anniversaire, allergie, chaise bébé…',
          hintStyle:
              TextStyle(fontSize: 12.5, color: Colors.grey.shade400),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          filled: true,
          fillColor: const Color(0xFFF8F8F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      );

  Widget _submitButton() => SizedBox(
        height: 48,
        child: FilledButton(
          onPressed: _submitting ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13)),
            elevation: 0,
          ),
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'Réserver la table',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15),
                ),
        ),
      );

  BoxDecoration _cardDeco() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      );
}
