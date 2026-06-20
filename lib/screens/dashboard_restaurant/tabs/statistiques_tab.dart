import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../providers/restaurant_dashboard_provider.dart';
import '../../../providers/restaurant_menu_provider.dart';
import '../../../theme/app_theme.dart';

class StatistiquesTab extends StatefulWidget {
  const StatistiquesTab({super.key});

  @override
  State<StatistiquesTab> createState() => _StatistiquesTabState();
}

class _StatistiquesTabState extends State<StatistiquesTab> {
  String _selectedCellFeedback = "Cliquez sur une case pour analyser l'affluence en temps réel";
  int _selectedDayIndex = -1;
  int _selectedHourIndex = -1;

  final List<String> _days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  final List<String> _daysShort = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  final List<String> _hours = ['11h', '12h', '13h', '14h', '18h', '19h', '20h', '21h'];

  // Matrice d'intensité (7 jours x 8 heures)
  // 0: Calme, 1: Modéré, 2: Intense, 3: Rush
  final List<List<int>> _heatmapData = [
    [0, 2, 2, 1, 0, 1, 2, 1], // Lun
    [0, 1, 2, 1, 0, 1, 2, 1], // Mar
    [0, 2, 2, 1, 0, 1, 2, 1], // Mer
    [0, 2, 2, 1, 1, 2, 2, 1], // Jeu
    [1, 3, 3, 2, 1, 2, 3, 3], // Ven (rush du week-end !)
    [1, 3, 3, 2, 1, 3, 3, 3], // Sam (forte affluence)
    [1, 2, 2, 1, 1, 2, 2, 1], // Dim
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantDashboardProvider>().loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            isDesktop ? _buildDesktopStats() : _buildMobileStats(),
            const SizedBox(height: 24),
            _buildChartsRow(isDesktop),
            const SizedBox(height: 24),
            _buildBottomRow(isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Analytiques Performance',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              const Text('Derniers 30 jours', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDesktopStats() {
    final menuProvider = context.watch<RestaurantMenuProvider>();
    final dashProvider = context.watch<RestaurantDashboardProvider>();
    final isMock = menuProvider.isMock;
    final revenue = dashProvider.analyticsInt('totalRevenue', fallback: isMock ? 1240500 : 0);
    final prepTime = dashProvider.analyticsInt('averagePrepMinutes', fallback: isMock ? 18 : 0);
    final rating = dashProvider.analyticsDouble('averageRating', fallback: isMock ? 4.7 : 0);
    final cancelRate = dashProvider.analyticsDouble('cancellationRate', fallback: isMock ? 1.2 : 0);

    return Row(
      children: [
        Expanded(child: _buildStatCard('Chiffre d\'Affaires', '$revenue FCFA', isMock ? '+12%' : '0%', Icons.payments_rounded, true)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Temps Prep. Moyen', '$prepTime min', isMock ? '-2m' : '0m', Icons.timer_rounded, true)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Satisfaction Client', '${rating.toStringAsFixed(1)} /5', '', Icons.star_rounded, true, isRating: true)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Taux d\'Annulation', '${cancelRate.toStringAsFixed(1)}%', isMock ? '-0.5%' : '0%', Icons.cancel_rounded, false)),
      ],
    );
  }

  Widget _buildMobileStats() {
    final menuProvider = context.watch<RestaurantMenuProvider>();
    final isMock = menuProvider.isMock;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Chiffre d\'Affaires', isMock ? '1.240.500 FCFA' : '0 FCFA', isMock ? '+12%' : '0%', Icons.payments_rounded, true)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Temps Prep. Moyen', isMock ? '18 min' : '0 min', isMock ? '-2m' : '0m', Icons.timer_rounded, true)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Satisfaction Client', isMock ? '4.7 /5' : '0 /5', '', Icons.star_rounded, true, isRating: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Taux d\'Annulation', isMock ? '1.2%' : '0%', isMock ? '-0.5%' : '0%', Icons.cancel_rounded, false)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String change, IconData icon, bool positiveChange, {bool isRating = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              if (change.isNotEmpty)
                Row(
                  children: [
                    Icon(positiveChange ? Icons.trending_up : Icons.trending_down, 
                         color: positiveChange ? Colors.green : Colors.red, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      change,
                      style: TextStyle(color: positiveChange ? Colors.green : Colors.red, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A))),
              if (isRating)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 14),
                      Icon(Icons.star, color: Colors.orange, size: 14),
                      Icon(Icons.star, color: Colors.orange, size: 14),
                      Icon(Icons.star, color: Colors.orange, size: 14),
                      Icon(Icons.star_half, color: Colors.orange, size: 14),
                    ],
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsRow(bool isDesktop) {
    final chartWidget = _buildBarChartCard();
    final rightWidget = _buildCAMensuelCard();

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: chartWidget),
          const SizedBox(width: 24),
          Expanded(flex: 1, child: rightWidget),
        ],
      );
    } else {
      return Column(
        children: [
          chartWidget,
          const SizedBox(height: 24),
          rightWidget,
        ],
      );
    }
  }

  Widget _buildBarChartCard() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Évolution des Commandes', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const Text('Volume quotidien des 30 derniers jours', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10);
                        Widget text;
                        switch (value.toInt()) {
                          case 0: text = const Text('01 OCT', style: style); break;
                          case 2: text = const Text('08 OCT', style: style); break;
                          case 4: text = const Text('15 OCT', style: style); break;
                          case 6: text = const Text('22 OCT', style: style); break;
                          case 8: text = const Text('29 OCT', style: style); break;
                          default: text = const Text('', style: style); break;
                        }
                        return SideTitleWidget(meta: meta, child: text);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroupData(0, 40),
                  _makeGroupData(1, 55),
                  _makeGroupData(2, 80),
                  _makeGroupData(3, 45),
                  _makeGroupData(4, 100, isHighlight: true),
                  _makeGroupData(5, 70),
                  _makeGroupData(6, 40),
                  _makeGroupData(7, 85),
                  _makeGroupData(8, 65),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, {bool isHighlight = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isHighlight ? AppColors.primary : AppColors.primary.withOpacity(0.3),
          width: 24,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildCAMensuelCard() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CA Mensuel', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const Text('Comparaison sur 6 mois', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 32),
          _buildProgressRow('OCTOBRE', 0.9, '1.2M FCFA'),
          _buildProgressRow('SEPTEMBRE', 0.7, '1.1M FCFA'),
          _buildProgressRow('AOÛT', 0.4, '0.6M FCFA'),
          _buildProgressRow('JUILLET', 0.85, '1.2M FCFA'),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String month, double progress, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(month, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.grey)),
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade100,
            color: AppColors.primary.withOpacity(progress > 0.8 ? 1.0 : (progress > 0.5 ? 0.6 : 0.3)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRow(bool isDesktop) {
    final top5 = _buildTop5Plats();
    final heatmap = _buildHeatmapBox();

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: top5),
          const SizedBox(width: 24),
          Expanded(flex: 2, child: heatmap),
        ],
      );
    } else {
      return Column(
        children: [
          top5,
          const SizedBox(height: 24),
          heatmap,
        ],
      );
    }
  }

  Widget _buildTop5Plats() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Top 5 des Plats', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          _buildTopPlatItem('assets/images/plat_real_2.jpg', 'Poulet Bicyclette...', '320 ventes ce mois', '4.500'),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          _buildTopPlatItem('assets/images/plat_real_1.jpg', 'Riz au Gras Royal', '285 ventes ce mois', '3.500'),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          _buildTopPlatItem('assets/images/plat_real_2.jpg', 'Salade Tropicale', '190 ventes ce mois', '2.000'),
        ],
      ),
    );
  }

  Widget _buildTopPlatItem(String img, String title, String subtitle, String price) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            img,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 48,
                height: 48,
                color: const Color(0xFFF1F5F9),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(price, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 13)),
            const Text('FCFA / UNITÉ', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.w800)),
          ],
        )
      ],
    );
  }

  Color _getHeatmapColor(int intensity, bool isSelected) {
    Color baseColor = switch (intensity) {
      0 => const Color(0xFFF1F5F9), // Calme (Slate 100)
      1 => AppColors.primary.withOpacity(0.15), // Modéré
      2 => AppColors.primary.withOpacity(0.5),  // Intense
      3 => AppColors.primary,                   // Rush (Bordeaux)
      _ => const Color(0xFFF1F5F9),
    };
    return baseColor;
  }

  Widget _buildHeatmapBox() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Heatmap des Heures de Pointe', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
          const Text('Concentration des commandes par heure et par jour', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 24),
          
          // Grille Heatmap défilante horizontalement sur mobile
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. En-tête des tranches horaires
                Row(
                  children: [
                    const SizedBox(width: 45), // Décalage pour aligner avec les labels des jours
                    ...List.generate(_hours.length, (idx) {
                      return SizedBox(
                        width: 38,
                        child: Center(
                          child: Text(
                            _hours[idx],
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                
                // 2. Grille des jours et des cases de rushs
                ...List.generate(_daysShort.length, (dayIdx) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        // Label du Jour
                        SizedBox(
                          width: 45,
                          child: Text(
                            _daysShort[dayIdx],
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                          ),
                        ),
                        // Cellules d'heures
                        ...List.generate(_hours.length, (hourIdx) {
                          final intensity = _heatmapData[dayIdx][hourIdx];
                          final bool isSelected = _selectedDayIndex == dayIdx && _selectedHourIndex == hourIdx;
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDayIndex = dayIdx;
                                _selectedHourIndex = hourIdx;
                                
                                final String dayName = _days[dayIdx];
                                final String hourLabel = _hours[hourIdx];
                                final String status = switch (intensity) {
                                  0 => 'Calme',
                                  1 => 'Modérée',
                                  2 => 'Intense',
                                  3 => 'Rush de rushs !',
                                  _ => 'Inconnu',
                                };
                                final String avg = switch (intensity) {
                                  0 => '5 commandes/heure',
                                  1 => '18 commandes/heure',
                                  2 => '32 commandes/heure',
                                  3 => '55 commandes/heure (Forte charge)',
                                  _ => '0',
                                };
                                
                                _selectedCellFeedback = '$dayName à $hourLabel : Affluence $status ($avg en moyenne)';
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: _getHeatmapColor(intensity, isSelected),
                                borderRadius: BorderRadius.circular(6),
                                border: isSelected 
                                    ? Border.all(color: Colors.black, width: 2) 
                                    : Border.all(color: Colors.white, width: 1),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          // 3. Légende explicative
          Row(
            children: [
              const Text('Légende : ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
              const SizedBox(width: 8),
              _legendItem('Calme', _getHeatmapColor(0, false)),
              const SizedBox(width: 8),
              _legendItem('Modéré', _getHeatmapColor(1, false)),
              const SizedBox(width: 8),
              _legendItem('Intense', _getHeatmapColor(2, false)),
              const SizedBox(width: 8),
              _legendItem('Rush', _getHeatmapColor(3, false)),
            ],
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          
          // 4. Zone d'affichage des détails réactifs au clic
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: _selectedDayIndex != -1 ? AppColors.primary : const Color(0xFF94A3B8),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedCellFeedback,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _selectedDayIndex != -1 ? AppColors.primary : const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}
