import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../model/seance_stats.dart';

class BarChartWidget extends StatelessWidget {
  final List<SeanceStats> stats;

  const BarChartWidget({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 16, height: 16, color: Colors.green),
            Text(" Présent "),
            Container(width: 16, height: 16, color: Colors.red),
            Text(" Absent "),
          ],
        ),
        SizedBox(height: 10),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.7,
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final titles = stats.map((s) => s.nomSeance).toList();
                        int index = value.toInt();
                        if (index >= 0 && index < titles.length) {
                          return Text(titles[index]);
                        } else {
                          return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        return Text("${value.toInt()}%");
                      },
                    ),
                  ),
                ),
                barGroups: stats.map((data) {
                  return BarChartGroupData(
                    x: stats.indexOf(data),
                    barRods: [
                      BarChartRodData(
                        toY: data.present,
                        color: Colors.green,
                        width: 18,
                      ),
                      BarChartRodData(
                        toY: data.absent,
                        color: Colors.red,
                        width: 18,
                      ),
                    ],
                    groupVertically: true,
                    barsSpace: 4,
                  );
                }).toList(),
                maxY: 100,
              ),
            ),
          ),
        ),
      ],
    );
  }
}