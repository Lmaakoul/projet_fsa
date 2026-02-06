import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsChart extends StatelessWidget {
  final Map<String, double> stats;

  const StatsChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            enabled: true,
            touchCallback: (FlTouchEvent event, pieTouchResponse) {},
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 5,
          centerSpaceRadius: 80, // Créer un "trou" au milieu = donut
          sections: _createSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> _createSections() {
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      const Color(0xFF4CAF50), // Vert
      const Color(0xFFF44336), // Rouge
    ];

    var i = 0;
    for (var entry in stats.entries) {
      final value = entry.value;
      final title = entry.key;

      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: value,
          title: '$value%',
          radius: 70,
          titleStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          badgeWidget: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          badgePositionPercentageOffset: .98,
        ),
      );
      i++;
    }

    return sections;
  }
}