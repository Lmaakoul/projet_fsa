// المسار: lib/features/3_professor_role/prof/screen/stats/groupe_stats_page.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // 🛑 Requires fl_chart dependency in pubspec.yaml
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// --- Simple Model for Session Statistics ---
// Note: This model should be defined in your model folder (e.g., seance_stats.dart)
class SeanceStats {
  final String nomSeance;
  final double present; // Percentage
  final double absent;  // Percentage
  SeanceStats({required this.nomSeance, required this.present, required this.absent});
}

// --- Group Detail Model (API container) ---
class GroupDetailStats {
  final double overallPresence;
  final List<SeanceStats> seanceDetails;

  GroupDetailStats({required this.overallPresence, required this.seanceDetails});
}
// ----------------------------------------------------

class GroupeStatsPage extends StatefulWidget {
  final int profId;
  final int groupId;
  final String groupName;
  final String moduleName;
  final int moduleId; // ✅ Required ID

  const GroupeStatsPage({
    super.key,
    required this.profId,
    required this.groupId,
    required this.groupName,
    required this.moduleName,
    required this.moduleId, // ✅ Now required
  });

  @override
  _GroupeStatsPageState createState() => _GroupeStatsPageState();
}

class _GroupeStatsPageState extends State<GroupeStatsPage> {
  // final ProfService _profService = ProfService(); // Uncomment for real API
  late Future<GroupDetailStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    // Start fetching detailed stats upon initialization
    _statsFuture = _fetchDetailedStats(widget.groupId, widget.moduleId);
  }

  // --- 1. Fetch Detailed Stats (Mock Implementation) ---
  Future<GroupDetailStats> _fetchDetailedStats(int groupId, int moduleId) async {
    // ⚠️ Real API Call: _profService.fetchGroupDetailedStats(groupId, moduleId);

    await Future.delayed(const Duration(seconds: 1));

    // Mock Data based on Group/Module IDs
    final List<SeanceStats> mockSeances = [
      SeanceStats(nomSeance: 'S1 - Cours', present: 88, absent: 12),
      SeanceStats(nomSeance: 'S2 - TD', present: 75, absent: 25),
      SeanceStats(nomSeance: 'S3 - TP', present: 95, absent: 5),
      SeanceStats(nomSeance: 'S4 - Final', present: 82, absent: 18),
    ];

    double totalPresent = 0;
    double totalAbsent = 0;

    for (var s in mockSeances) {
      totalPresent += s.present;
      totalAbsent += s.absent;
    }

    final overallAvg = (totalPresent / mockSeances.length); // Simple average of percentages

    return GroupDetailStats(
      overallPresence: overallAvg,
      seanceDetails: mockSeances,
    );
  }

  // --- 2. Pie Chart Widget Builder ---
  Widget _buildPieChart(double presence) {
    final absent = 100 - presence;
    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            // Presence Section
            PieChartSectionData(
              color: Colors.green.shade600,
              value: presence,
              title: '${presence.toStringAsFixed(1)}%',
              radius: 60,
              titleStyle: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            // Absence Section
            PieChartSectionData(
              color: Colors.red.shade600,
              value: absent,
              title: '${absent.toStringAsFixed(1)}%',
              radius: 60,
              titleStyle: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. Legend Item Builder ---
  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(title, style: GoogleFonts.lato(fontSize: 14)),
      ],
    );
  }

  // --- 4. Detail Table Builder ---
  Widget _buildDetailTable(List<SeanceStats> details, Color primaryColor) {
    // Calculate max presence percentage for highlighting
    final maxPresence = details.map((s) => s.present).fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DataTable(
        columnSpacing: 15,
        dataRowHeight: 45,
        headingRowColor: MaterialStateProperty.resolveWith((states) => primaryColor.withOpacity(0.1)),
        columns: [
          DataColumn(label: Text('Séance', style: GoogleFonts.lato(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Présence %', style: GoogleFonts.lato(fontWeight: FontWeight.bold)), numeric: true),
          DataColumn(label: Text('Absence %', style: GoogleFonts.lato(fontWeight: FontWeight.bold)), numeric: true),
        ],
        rows: details.map((s) {
          final isMax = s.present == maxPresence;
          final presenceColor = s.present >= 80 ? Colors.green.shade700 : Colors.orange.shade700;

          return DataRow(
            color: MaterialStateProperty.resolveWith((states) => isMax ? primaryColor.withOpacity(0.05) : Colors.transparent),
            cells: [
              DataCell(Text(s.nomSeance)),
              DataCell(Text(
                '${s.present.toStringAsFixed(1)}%',
                style: TextStyle(fontWeight: FontWeight.bold, color: presenceColor),
              )),
              DataCell(Text(
                '${s.absent.toStringAsFixed(1)}%',
                style: TextStyle(color: Colors.red.shade700),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.moduleName} - ${widget.groupName}'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<GroupDetailStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text("Erreur de chargement des statistiques: ${snapshot.error ?? 'Données manquantes'}", textAlign: TextAlign.center,));
          }

          final stats = snapshot.data!;
          final overallPresence = stats.overallPresence;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Overall Summary Card (Pie Chart) ---
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Taux de Présence Global (Moyenne)',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Center(child: _buildPieChart(overallPresence)),

                        // Legend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem('Présence', Colors.green.shade600),
                            const SizedBox(width: 20),
                            _buildLegendItem('Absence', Colors.red.shade600),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- Session Detail Table ---
                Text(
                  'Statistiques Détaillées par Séance:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                stats.seanceDetails.isEmpty
                    ? const Center(child: Text("Aucun détail de séance disponible."))
                    : _buildDetailTable(stats.seanceDetails, primaryColor),
              ],
            ),
          );
        },
      ),
    );
  }
}