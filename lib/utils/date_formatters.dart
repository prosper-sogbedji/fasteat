import 'package:intl/intl.dart';

/// Formate une date ISO en libellé relatif (« Il y a 5 min »).
String formatRelativeTime(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return 'Récemment';
  try {
    final date = DateTime.parse(isoDate).toLocal();
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return DateFormat('dd/MM/yyyy').format(date);
  } catch (_) {
    return 'Récemment';
  }
}

/// Parse « jj/mm/aaaa » vers ISO 8601 UTC.
String? parseFrenchDateToIso(String input, {bool endOfDay = false}) {
  final parts = input.trim().split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  try {
    final dt = DateTime(year, month, day, endOfDay ? 23 : 0, endOfDay ? 59 : 0);
    return dt.toUtc().toIso8601String();
  } catch (_) {
    return null;
  }
}
