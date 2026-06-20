import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../theme/app_theme.dart';

class AdminStatsTab extends StatefulWidget {
  const AdminStatsTab({super.key});

  @override
  State<AdminStatsTab> createState() => _AdminStatsTabState();
}

class _AdminStatsTabState extends State<AdminStatsTab> {
  String _periode = '30 jours';

  String _formatFcfa(int amount) {
    if (amount >= 1000000) {
      final m = (amount / 1000000).toStringAsFixed(1);
      return '$m M FCFA';
    }
    final s = amount.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      b.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) b.write(' ');
    }
    return '${b.toString()} FCFA';
  }

  // Données mock - revenus plateforme (en FCFA, en milliers)
  final List<double> _revenusJours = [
    420,
    380,
    510,
    490,
    630,
    720,
    680,
    540,
    490,
    580,
    620,
    710,
    760,
    800,
    750,
    690,
    710,
    780,
    820,
    860,
    900,
    880,
    820,
    760,
    780,
    810,
    850,
    890,
    920,
    960,
  ];

  final List<double> _commandesJours = [
    42,
    38,
    51,
    49,
    63,
    72,
    68,
    54,
    49,
    58,
    62,
    71,
    76,
    80,
    75,
    69,
    71,
    78,
    82,
    86,
    90,
    88,
    82,
    76,
    78,
    81,
    85,
    89,
    92,
    96,
  ];

  // Répartition par catégorie
  final List<_PieData> _pieData = [
    _PieData('Cuisine Béninoise', 38, const Color(0xFFFF7700)),
    _PieData('Fast Food', 24, const Color(0xFFF4B400)),
    _PieData('Cuisine Africaine', 18, const Color(0xFF7C3AED)),
    _PieData('Grillades', 12, const Color(0xFF0891B2)),
    _PieData('Autres', 8, const Color(0xFF94A3B8)),
  ];

  // Top restaurants
  final List<_TopResto> _topRestos = [
    _TopResto('Restaurant Saveurs du Bénin', 4850000, 1248, 4.8),
    _TopResto('Délices d\'Afrique', 3200000, 876, 4.6),
    _TopResto('Le Grill de Porto-Novo', 2900000, 743, 4.5),
    _TopResto('La Terrasse du Lac', 720000, 198, 4.1),
    _TopResto('Fast & Fresh Burgers', 1650000, 512, 3.2),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1000;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildKPIs(),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildRevenusChart()),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: _buildCommandesChart()),
              ],
            )
          else ...[
            _buildRevenusChart(),
            const SizedBox(height: 20),
            _buildCommandesChart(),
          ],
          const SizedBox(height: 20),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildTopRestaurants()),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: _buildPieChart()),
              ],
            )
          else ...[
            _buildTopRestaurants(),
            const SizedBox(height: 20),
            _buildPieChart(),
          ],
          const SizedBox(height: 20),
          _buildVillesStats(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vue Globale & Statistiques',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Performances de toute la plateforme FastEat',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEDF2F3)),
          ),
          child: Row(
            children: ['7 jours', '30 jours', '90 jours'].map((p) {
              final sel = _periode == p;
              return GestureDetector(
                onTap: () => setState(() => _periode = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    p,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildKPIs() {
    final totalCA = 13320000;
    final totalCmds = 3577;
    final nbRestos = 6;
    final nbClients = 2841;

    return Row(
      children: [
        _kpiCard(
          'Revenus Plateforme',
          _formatFcfa(totalCA),
          '+18.4%',
          Icons.payments_rounded,
          const Color(0xFF7C3AED),
          const Color(0xFFF5F3FF),
          true,
        ),
        const SizedBox(width: 16),
        _kpiCard(
          'Commandes totales',
          totalCmds.toString(),
          '+12.1%',
          Icons.receipt_long_rounded,
          AppColors.primary,
          const Color(0xFFE6F3F3),
          true,
        ),
        const SizedBox(width: 16),
        _kpiCard(
          'Restaurants actifs',
          nbRestos.toString(),
          '+2',
          Icons.storefront_rounded,
          const Color(0xFF0891B2),
          const Color(0xFFE0F7FA),
          true,
        ),
        const SizedBox(width: 16),
        _kpiCard(
          'Clients inscrits',
          nbClients.toString(),
          '+341',
          Icons.people_alt_rounded,
          const Color(0xFF16A34A),
          const Color(0xFFDCFCE7),
          true,
        ),
      ],
    );
  }

  Widget _kpiCard(
    String label,
    String value,
    String delta,
    IconData icon,
    Color color,
    Color bg,
    bool isPositive,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDF2F3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_upward_rounded,
                        size: 10,
                        color: Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        delta,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenusChart() {
    final spots = _revenusJours
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    return _chartCard(
      'Revenus de la plateforme',
      'Commission FastEat sur 30 jours (en milliers FCFA)',
      Icons.trending_up_rounded,
      const Color(0xFF7C3AED),
      SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 200,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                  getTitlesWidget: (v, _) => Text(
                    '${v.toInt()}k',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 7,
                  getTitlesWidget: (v, _) => Text(
                    'J${v.toInt() + 1}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: const Color(0xFF7C3AED),
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF7C3AED).withValues(alpha: 0.15),
                      const Color(0xFF7C3AED).withValues(alpha: 0.01),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommandesChart() {
    final data = _commandesJours.takeLast(7).toList();
    final jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return _chartCard(
      'Commandes / jour (7 derniers jours)',
      'Volume de commandes par jour',
      Icons.bar_chart_rounded,
      AppColors.primary,
      SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 30,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    return Text(
                      i < jours.length ? jours[i] : '',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (v, _) => Text(
                    '${v.toInt()}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: data
                .asMap()
                .entries
                .map(
                  (e) => BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value,
                        color: AppColors.primary,
                        width: 22,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTopRestaurants() {
    final sorted = List<_TopResto>.from(_topRestos)
      ..sort((a, b) => b.ca.compareTo(a.ca));
    return _chartCard(
      'Top Restaurants',
      'Classement par chiffre d\'affaires',
      Icons.emoji_events_rounded,
      const Color(0xFFD97706),
      Column(
        children: sorted.asMap().entries.map((e) {
          final rank = e.key + 1;
          final r = e.value;
          final pct = (r.ca / sorted.first.ca * 100).toInt();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: rank == 1
                        ? const Color(0xFFFEF3C7)
                        : rank == 2
                        ? const Color(0xFFF3F4F6)
                        : const Color(0xFFFFF7ED),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: rank == 1
                            ? const Color(0xFFD97706)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.nom,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: pct / 100,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          rank == 1
                              ? const Color(0xFFD97706)
                              : AppColors.primary,
                        ),
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatFcfa(r.ca),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${r.commandes} cmds',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart() {
    return _chartCard(
      'Répartition par catégorie',
      'Part des commandes par type de cuisine',
      Icons.pie_chart_rounded,
      const Color(0xFF0891B2),
      Column(
        children: [
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sections: _pieData
                    .map(
                      (d) => PieChartSectionData(
                        value: d.pct.toDouble(),
                        color: d.color,
                        radius: 55,
                        title: '${d.pct}%',
                        titleStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    )
                    .toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...(_pieData.map(
            (d) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: d.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      d.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  Text(
                    '${d.pct}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildVillesStats() {
    final villes = [
      ('Cotonou', 72, 9580000),
      ('Porto-Novo', 18, 2900000),
      ('Abomey-Calavi', 6, 620000),
      ('Parakou', 4, 220000),
    ];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF2F3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_city_rounded,
                  color: Color(0xFF0891B2),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activité par ville',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Répartition géographique des commandes',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...villes.map(
            (v) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      v.$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: v.$2 / 100,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${v.$2}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 120,
                    child: Text(
                      _formatFcfa(v.$3),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.right,
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

  Widget _chartCard(
    String titre,
    String sousTitre,
    IconData icon,
    Color color,
    Widget chart,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF2F3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      sousTitre,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          chart,
        ],
      ),
    );
  }
}

class _PieData {
  final String label;
  final int pct;
  final Color color;
  const _PieData(this.label, this.pct, this.color);
}

class _TopResto {
  final String nom;
  final int ca;
  final int commandes;
  final double note;
  const _TopResto(this.nom, this.ca, this.commandes, this.note);
}

extension on List<double> {
  List<double> takeLast(int n) => length <= n ? this : sublist(length - n);
}
