// المسار: lib/features/3_professor_role/prof/screen/stats/stats_page.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
// 🛑 تأكد من أن المسارات التالية صحيحة:
import '../../model/presence_percentage_dto.dart';
import '../../model/seance_stats.dart';

import 'groupe_stats_page.dart';
// ----------------------------------------------------

// --- Group Attendance Summary (Used for the list on this page) ---
class GroupAttendanceSummary {
  final int groupId;
  final String groupName;
  final String moduleName;
  final int moduleId; // ✅ موجود
  final double averagePresence;
  final int totalStudents;

  GroupAttendanceSummary({
    required this.groupId,
    required this.groupName,
    required this.moduleName,
    required this.moduleId,
    required this.averagePresence,
    required this.totalStudents,
  });
}
// ----------------------------------------------------


class StatsPage extends StatefulWidget {
  final int profId;

  const StatsPage({super.key, required this.profId});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  // final ProfService _profService = ProfService();

  List<GroupAttendanceSummary> _groupsStats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatsSummary();
  }

  // --- 1. Fetch Overall Stats Summary ---
  Future<void> _fetchStatsSummary() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _groupsStats = [];
    });

    try {
      // Mock Data:
      await Future.delayed(const Duration(milliseconds: 700));
      final mockData = [
        {
          'groupId': 1011,
          'moduleId': 101, // ✅ تم توحيد اسم المفتاح
          'groupName': 'INFO1-G1',
          'moduleName': 'Algorithmique',
          'averagePresence': 85.5,
          'totalStudents': 45
        },
        {
          'groupId': 1012,
          'moduleId': 101, // ✅ تم توحيد اسم المفتاح
          'groupName': 'INFO1-G2',
          'moduleName': 'Algorithmique',
          'averagePresence': 72.0,
          'totalStudents': 42
        },
        {
          'groupId': 2011,
          'moduleId': 201, // ✅ تم توحيد اسم المفتاح
          'groupName': 'GI-A',
          'moduleName': 'Génie Industriel',
          'averagePresence': 95.2,
          'totalStudents': 30
        },
      ];

      final statsList = mockData.map((d) => GroupAttendanceSummary(
        groupId: d['groupId'] as int,

        // 🛑 FIX: الوصول إلى moduleId من الـ Map
        moduleId: d['moduleId'] as int,

        groupName: d['groupName'] as String,
        moduleName: d['moduleName'] as String,
        averagePresence: d['averagePresence'] as double,
        totalStudents: d['totalStudents'] as int,
      )).toList();

      if (!mounted) return;
      setState(() {
        _groupsStats = statsList;
        _isLoading = false;
      });

    } catch (e) {
      print("Error fetching stats summary: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // --- 2. Group Stat Card Widget ---
  Widget _buildGroupStatCard(BuildContext context, GroupAttendanceSummary stats, Color primaryColor) {
    final Color presenceColor = stats.averagePresence >= 80 ? Colors.green.shade700 : Colors.amber.shade700;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const FaIcon(
            FontAwesomeIcons.users,
            color: Colors.blueGrey,
            size: 30
        ),
        title: Text(
            stats.groupName,
            style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        subtitle: Text('Module: ${stats.moduleName} | Total: ${stats.totalStudents} étudiants'),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: presenceColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${stats.averagePresence.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: presenceColor,
                ),
              ),
              Text(
                'Moyenne',
                style: TextStyle(fontSize: 10, color: presenceColor),
              ),
            ],
          ),
        ),
        onTap: () {
          // Navigate to detailed stats page for this group
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupeStatsPage(
                profId: widget.profId,
                groupId: stats.groupId,
                groupName: stats.groupName,
                moduleName: stats.moduleName,
                moduleId: stats.moduleId, // ✅ تمرير moduleId
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiques de Présence', style: GoogleFonts.lato()),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groupsStats.isEmpty
          ? Center(child: Text("Aucune donnée de présence trouvée.", style: TextStyle(color: Colors.grey[700])))
          : RefreshIndicator(
        onRefresh: _fetchStatsSummary,
        color: primaryColor,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Résumé de l\'activité (Moyenne par groupe) :',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // List of Groups with Summary Stats
            ..._groupsStats.map((stats) {
              return _buildGroupStatCard(context, stats, primaryColor);
            }).toList(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}