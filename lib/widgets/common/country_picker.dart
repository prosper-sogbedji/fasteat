  import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Modèle représentant un pays avec son indicatif et son drapeau.
class Country {
  const Country({
    required this.name,
    required this.flag,
    required this.dialCode,
    required this.isoCode,
    this.minDigits = 7,
    this.maxDigits = 9,
    this.hint = 'Numéro local',
    this.localPrefix = '',
  });

  final String name;
  final String flag;
  final String dialCode;
  final String isoCode;
  final int minDigits;
  final int maxDigits;
  /// Placeholder affiché dans le champ numéro
  final String hint;
  /// Préfixe local (ex: "01 " pour le Bénin)
  final String localPrefix;
}

const kDefaultCountry = Country(
  name: 'Bénin',
  flag: '🇧🇯',
  dialCode: '+229',
  isoCode: 'BJ',
  minDigits: 10,
  maxDigits: 10,
  hint: '01 90 00 00 00',
  localPrefix: '01 ',
);

const _countries = <Country>[
  // Afrique de l'Ouest (prioritaires)
  Country(name: 'Bénin',        flag: '🇧🇯', dialCode: '+229', isoCode: 'BJ', minDigits: 10, maxDigits: 10, hint: '01 90 00 00 00', localPrefix: '01 '),
  Country(name: 'Sénégal',      flag: '🇸🇳', dialCode: '+221', isoCode: 'SN', minDigits: 9,  maxDigits: 9,  hint: '77 000 00 00'),
  Country(name: 'Togo',         flag: '🇹🇬', dialCode: '+228', isoCode: 'TG', minDigits: 8,  maxDigits: 8,  hint: '90 00 00 00'),
  Country(name: "Côte d'Ivoire",flag: '🇨🇮', dialCode: '+225', isoCode: 'CI', minDigits: 10, maxDigits: 10, hint: '07 00 00 00 00'),
  Country(name: 'Ghana',        flag: '🇬🇭', dialCode: '+233', isoCode: 'GH', minDigits: 9,  maxDigits: 9,  hint: '024 000 0000'),
  Country(name: 'Nigeria',      flag: '🇳🇬', dialCode: '+234', isoCode: 'NG', minDigits: 10, maxDigits: 10, hint: '080 0000 0000'),
  Country(name: 'Burkina Faso', flag: '🇧🇫', dialCode: '+226', isoCode: 'BF', minDigits: 8,  maxDigits: 8,  hint: '70 00 00 00'),
  Country(name: 'Mali',         flag: '🇲🇱', dialCode: '+223', isoCode: 'ML', minDigits: 8,  maxDigits: 8,  hint: '70 00 00 00'),
  Country(name: 'Niger',        flag: '🇳🇪', dialCode: '+227', isoCode: 'NE', minDigits: 8,  maxDigits: 8,  hint: '90 00 00 00'),
  Country(name: 'Guinée',       flag: '🇬🇳', dialCode: '+224', isoCode: 'GN', minDigits: 9,  maxDigits: 9,  hint: '620 00 00 00'),
  Country(name: 'Cameroun',     flag: '🇨🇲', dialCode: '+237', isoCode: 'CM', minDigits: 9,  maxDigits: 9,  hint: '670 00 00 00'),
  Country(name: 'Gabon',        flag: '🇬🇦', dialCode: '+241', isoCode: 'GA', minDigits: 7,  maxDigits: 8,  hint: '06 00 00 00'),
  Country(name: 'Congo',        flag: '🇨🇬', dialCode: '+242', isoCode: 'CG', minDigits: 9,  maxDigits: 9,  hint: '06 000 0000'),
  Country(name: 'RD Congo',     flag: '🇨🇩', dialCode: '+243', isoCode: 'CD', minDigits: 9,  maxDigits: 9,  hint: '081 000 0000'),
  // Europe / Diaspora
  Country(name: 'France',       flag: '🇫🇷', dialCode: '+33',  isoCode: 'FR', minDigits: 9,  maxDigits: 9,  hint: '06 00 00 00 00'),
  Country(name: 'Belgique',     flag: '🇧🇪', dialCode: '+32',  isoCode: 'BE', minDigits: 9,  maxDigits: 9,  hint: '0470 00 00 00'),
  Country(name: 'Suisse',       flag: '🇨🇭', dialCode: '+41',  isoCode: 'CH', minDigits: 9,  maxDigits: 9,  hint: '078 000 00 00'),
  Country(name: 'Canada',       flag: '🇨🇦', dialCode: '+1',   isoCode: 'CA', minDigits: 10, maxDigits: 10, hint: '514 000 0000'),
  Country(name: 'États-Unis',   flag: '🇺🇸', dialCode: '+1',   isoCode: 'US', minDigits: 10, maxDigits: 10, hint: '555 000 0000'),
];

/// Widget bouton qui affiche le drapeau + indicatif et ouvre la bottom sheet.
class CountryPickerButton extends StatelessWidget {
  const CountryPickerButton({
    super.key,
    required this.country,
    required this.onChanged,
  });

  final Country country;
  final ValueChanged<Country> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openSheet(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(country.flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 6),
            Text(
              country.dialCode,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountrySheet(selected: country),
    );
    if (selected != null) onChanged(selected);
  }
}

class _CountrySheet extends StatefulWidget {
  const _CountrySheet({required this.selected});
  final Country selected;

  @override
  State<_CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<_CountrySheet> {
  final _searchCtrl = TextEditingController();
  List<Country> _filtered = _countries;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    final query = q.toLowerCase();
    setState(() {
      _filtered = _countries
          .where((c) =>
              c.name.toLowerCase().contains(query) ||
              c.dialCode.contains(query) ||
              c.isoCode.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.75;
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
          ),
          const Text('Choisir un pays', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Rechercher un pays ou indicatif...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () { _searchCtrl.clear(); _onSearch(''); },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('Aucun pays trouvé', style: TextStyle(color: AppColors.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final c = _filtered[index];
                      final isSelected = c.isoCode == widget.selected.isoCode;
                      return ListTile(
                        onTap: () => Navigator.of(context).pop(c),
                        leading: Text(c.flag, style: const TextStyle(fontSize: 26)),
                        title: Text(
                          c.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          c.hint,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            c.dialCode,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: AppColors.primary.withValues(alpha: 0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      );
                    },
                  ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
