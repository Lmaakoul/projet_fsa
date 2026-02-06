import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final double present;
  final double absent;

  const PieChartWidget({
    Key? key,
    required this.present,
    required this.absent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(enabled: false), // Désactive l'interaction si non nécessaire
          borderData: FlBorderData(show: false),
          sectionsSpace: 0,
          centerSpaceRadius: 0, // ⬅️ Cercle plein (rempli entièrement)
          sections: _buildSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return [
      PieChartSectionData(
        color: Color.fromARGB(255, 127, 172, 129).withOpacity(0.9), // Opacité subtile
        value: present,
        title: "$present%",
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Color.fromARGB(255, 212, 98, 98).withOpacity(0.9), // Opacité similaire
        value: absent,
        title: "$absent%",
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }
}