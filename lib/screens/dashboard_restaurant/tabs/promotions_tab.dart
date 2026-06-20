import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/restaurant_menu_provider.dart';
import '../../../providers/restaurant_dashboard_provider.dart';
import '../../../utils/date_formatters.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;

    // Suppression de tout ce qui n'est pas un chiffre
    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limiter à 8 chiffres (JJ MM AAAA)
    if (text.length > 8) {
      text = text.substring(0, 8);
    }

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) {
        formatted += '/';
      }
      formatted += text[i];
    }

    // Gestion du curseur
    int selectionIndex = newValue.selection.end;
    if (formatted.length > oldValue.text.length) {
      if (formatted.endsWith('/')) {
        selectionIndex += 1;
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex > formatted.length ? formatted.length : selectionIndex),
    );
  }
}

class PromotionsTab extends StatefulWidget {
  const PromotionsTab({super.key});

  @override
  State<PromotionsTab> createState() => _PromotionsTabState();
}

class _PromotionsTabState extends State<PromotionsTab> {
  final TextEditingController _promoNameController = TextEditingController();
  String _selectedReductionType = 'Réduction en Pourcentage (%)';
  final TextEditingController _promoValueController = TextEditingController();
  final TextEditingController _promoDescController = TextEditingController();

  final List<String> _selectedCategories = ['Boissons', 'Grillades'];
  final TextEditingController _dateDebutController = TextEditingController();
  final TextEditingController _dateFinController = TextEditingController();
  bool _isCreatingPromo = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantDashboardProvider>().loadPromotions();
    });
  }
  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;
    final double padding = isDesktop ? 32.0 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDesktop),
            const SizedBox(height: 24),
            _buildStatsGrid(isDesktop),
            const SizedBox(height: 24),
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isCreatingPromo) Expanded(flex: 4, child: _buildNewOfferForm()),
                      if (_isCreatingPromo) const SizedBox(width: 24),
                      Expanded(
                        flex: _isCreatingPromo ? 7 : 11,
                        child: _buildActiveOffersList(isDesktop),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      if (_isCreatingPromo) _buildNewOfferForm(),
                      if (_isCreatingPromo) const SizedBox(height: 24),
                      _buildActiveOffersList(isDesktop),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    final Widget headerText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Gestion des Promotions',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 26,
            color: Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Boostez vos ventes avec des offres stratégiques sur le marché béninois.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    final Widget actionButton = FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFA80F2A), // Deep red/burgundy
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      onPressed: () {
        setState(() {
          _isCreatingPromo = !_isCreatingPromo;
        });
      },
      icon: Icon(_isCreatingPromo ? Icons.close_rounded : Icons.add_circle_outline_rounded, size: 18),
      label: Text(
        _isCreatingPromo ? 'ANNULER' : 'AJOUTER UNE PROMOTION',
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: headerText),
          const SizedBox(width: 16),
          actionButton,
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerText,
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: actionButton),
        ],
      );
    }
  }

  Widget _buildStatsGrid(bool isDesktop) {
    final menuProvider = context.watch<RestaurantMenuProvider>();
    final isMock = menuProvider.isMock;
    
    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'VENTES PROMO',
              isMock ? '450.000 FCFA' : '0 FCFA',
              isMock ? '+12%' : '0%',
              const Color(0xFFDCFCE7),
              const Color(0xFF15803D),
              Icons.trending_up_rounded,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'COUPONS UTILISÉS',
              isMock ? '1,284' : '0',
              'Actif',
              const Color(0xFFFEF3C7),
              const Color(0xFFB45309),
              Icons.confirmation_number_outlined,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'NOUVEAUX CLIENTS',
              isMock ? '89' : '0',
              'Nouveau',
              const Color(0xFFE0F2FE),
              const Color(0xFF0369A1),
              Icons.people_outline_rounded,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'DURÉE DE CAMPAGNE',
              isMock ? '4.2 Jours' : '0 Jours',
              'Moyenne',
              const Color(0xFFFFEDD5),
              const Color(0xFFC2410C),
              Icons.hourglass_empty_rounded,
            ),
          ),
        ],
      );
    } else {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.0,
        children: [
          _buildStatCard(
            'VENTES PROMO',
            isMock ? '450.000 FCFA' : '0 FCFA',
            isMock ? '+12%' : '0%',
            const Color(0xFFDCFCE7),
            const Color(0xFF15803D),
            Icons.trending_up_rounded,
          ),
          _buildStatCard(
            'COUPONS UTILISÉS',
            isMock ? '1,284' : '0',
            'Actif',
            const Color(0xFFFEF3C7),
            const Color(0xFFB45309),
            Icons.confirmation_number_outlined,
          ),
          _buildStatCard(
            'NOUVEAUX CLIENTS',
            isMock ? '89' : '0',
            'Nouveau',
            const Color(0xFFE0F2FE),
            const Color(0xFF0369A1),
            Icons.people_outline_rounded,
          ),
          _buildStatCard(
            'DURÉE DE CAMPAGNE',
            isMock ? '4.2 Jours' : '0 Jours',
            'Moyenne',
            const Color(0xFFFFEDD5),
            const Color(0xFFC2410C),
            Icons.hourglass_empty_rounded,
          ),
        ],
      );
    }
  }

  Widget _buildStatCard(
    String title,
    String value,
    String badgeText,
    Color badgeBg,
    Color badgeTextColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF64748B), size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNewOfferForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFA80F2A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.adjust_rounded,
                  color: Color(0xFFA80F2A),
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Nouvelle Offre',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'NOM DE LA PROMOTION',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          _buildTextField(_promoNameController, 'ex: Weekend Spécial Aloco'),
          const SizedBox(height: 16),
          const Text(
            'TYPE DE RÉDUCTION',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          _buildDropdown(),
          const SizedBox(height: 16),
          const Text(
            'VALEUR / DÉTAIL',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _buildTextField(_promoValueController, '15')),
              const SizedBox(width: 8),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '%',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'PLATS CONCERNÉS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._selectedCategories.map((cat) => _buildChip(cat, true)),
              _buildAddChip(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DÉBUT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildDateField(_dateDebutController, 'jj/mm/aaaa'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FIN',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildDateField(_dateFinController, 'jj/mm/aaaa'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A), // Slate 900
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSubmitting ? null : () => _submitPromotion(context),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text(
                      'PUBLIER LA PROMOTION',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String placeholder) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String hint) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [DateInputFormatter()],
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const Icon(
            Icons.calendar_today_rounded,
            color: Color(0xFF94A3B8),
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedReductionType,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF64748B),
          ),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Color(0xFF0F172A),
          ),
          items:
              <String>[
                'Réduction en Pourcentage (%)',
                'Réduction Fixe (FCFA)',
                'Offre Groupée (Combo)',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedReductionType = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFA80F2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () {
              setState(() {
                _selectedCategories.remove(label);
              });
            },
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddChip() {
    return InkWell(
      onTap: () {
        setState(() {
          if (!_selectedCategories.contains('Bissap')) {
            _selectedCategories.add('Bissap');
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add_rounded, color: Color(0xFF64748B), size: 12),
            SizedBox(width: 4),
            Text(
              'Ajouter',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPromotion(BuildContext context) async {
    final title = _promoNameController.text.trim();
    final value = double.tryParse(_promoValueController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final startsAt = parseFrenchDateToIso(_dateDebutController.text);
    final endsAt = parseFrenchDateToIso(_dateFinController.text, endOfDay: true);

    if (title.length < 3 || value <= 0 || startsAt == null || endsAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir le nom, la valeur et les dates (jj/mm/aaaa).')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final provider = context.read<RestaurantDashboardProvider>();
    final discountType = _selectedReductionType.contains('FCFA') ? 'amount' : 'percentage';
    final ok = await provider.createPromotion(
      title: title,
      description: _promoDescController.text.trim().isNotEmpty
          ? _promoDescController.text.trim()
          : _selectedReductionType,
      discountType: discountType,
      discountValue: value,
      startsAt: startsAt,
      endsAt: endsAt,
    );
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      if (ok) _isCreatingPromo = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Promotion créée avec succès.' : 'Erreur : ${provider.error ?? "inconnue"}')),
    );
  }

  Widget _buildActiveOffersList(bool isDesktop) {
    final dashProvider = context.watch<RestaurantDashboardProvider>();
    final promotions = dashProvider.promotions;

    if (dashProvider.isLoadingPromotions && promotions.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
    }

    if (promotions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: Text('Aucune promotion active.', style: TextStyle(color: Color(0xFF64748B)))),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFA80F2A).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.style_outlined,
                color: Color(0xFFA80F2A),
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Offres en cours & Performance',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...promotions.map((p) {
          final isActive = p['status'] == 'ACTIF';
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildOfferCard(
              p['title']?.toString() ?? 'Promotion',
              p['description']?.toString() ?? '',
              p['status']?.toString() ?? 'ACTIF',
              isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5),
              isActive ? const Color(0xFF15803D) : const Color(0xFFC2410C),
              isActive ? const Color(0xFF10B981) : const Color(0xFFF97316),
              '${p['uses'] ?? 0}',
              '${p['revenue'] ?? 0} F',
              p['remaining']?.toString() ?? '—',
              isActive,
              isDesktop,
            ),
          );
        }),
        const SizedBox(height: 24),
        _buildBottomBanner(),
      ],
    );
  }

  Widget _buildOfferCard(
    String title,
    String description,
    String status,
    Color statusBg,
    Color statusTextColor,
    Color leftBorderColor,
    String utilises,
    String revenu,
    String restant,
    bool isActive,
    bool isDesktop,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: leftBorderColor, width: 4)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Color(0xFFA80F2A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOfferCounter('UTILISÉS', utilises),
              _buildOfferCounter('REVENU', revenu),
              _buildOfferCounter('RESTANT', restant),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isActive
                  ? SizedBox(
                      width: 48,
                      height: 24,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFFE2E8F0),
                              child: const Text(
                                'KA',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFFCBD5E1),
                              child: const Text(
                                'MT',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 24,
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Color(0xFFA80F2A),
                              child: Text(
                                '+18',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              isActive
                  ? TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text(
                        'Gérer',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981), // Emerald 500
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: const Text(
                        'RÉACTIVER',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
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

  Widget _buildOfferCounter(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w800,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.add_business_rounded,
            color: Color(0xFF94A3B8),
            size: 28,
          ),
          const SizedBox(height: 12),
          const Text(
            'Étendre votre visibilité',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ajouter une offre "Happy Hour" pour attirer plus de clients entre 15h et 18h.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Création d\'une offre groupée...'),
                ),
              );
            },
            child: const Text(
              '+ CRÉER UNE OFFRE GROUPÉE',
              style: TextStyle(
                color: Color(0xFFA80F2A),
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
