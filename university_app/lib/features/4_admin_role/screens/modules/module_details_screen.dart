// ملف: lib/features/4_admin_role/screens/modules/module_details_screen.dart
// (النسخة الكاملة - Dynamic)

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:university_app/core/models/module.dart'; // [جديد] Import l-Model

class ModuleDetailsScreen extends StatelessWidget {

  // [تصحيح 1] Bddlna 10 Strings b Model wa7d w Token
  final Module module;
  final String token;

  const ModuleDetailsScreen({
    super.key,
    required this.module,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryAppBarColor = Color(0xFF0A4F48);
    const Color pageBackgroundColor = Color(0xFFFCF5F8);
    const Color iconBackgroundColor = Color(0xFFEBF0F3);

    // [جديد] Kan-extract-iw l-lista dyal l-Asatida
    final List<String> professorNames = module.professors.map((p) => p.fullName).toList();

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryAppBarColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Fiche Module',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- القسم 1: الهيدر ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MODULE',
                    style: TextStyle(
                      color: Colors.grey[600],
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    module.title, // <-- (Dynamic)
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // --- القسم 2: المعلومات العامة ---
            _buildSectionTitle('Informations générales'),
            _buildInfoRow(
              icon: Icons.qr_code_scanner_outlined,
              text: module.code, // <-- (Dynamic)
              iconBgColor: iconBackgroundColor,
            ),
            _buildInfoRow(
              icon: Icons.school_outlined,
              text: module.filiereName ?? 'N/A', // <-- (Dynamic)
              iconBgColor: iconBackgroundColor,
            ),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              text: module.semesterName ?? 'N/A', // <-- (Dynamic)
              iconBgColor: iconBackgroundColor,
            ),
            const SizedBox(height: 20),

            // --- القسم 3: الأستاذ المسؤول ---
            _buildSectionTitle('Enseignants assignés'),

            // [تصحيح 2] Kan-loop-iw 3la l-lista dyal l-Profs
            if (professorNames.isEmpty)
              _buildInfoRow(
                icon: Icons.person_off_outlined,
                text: 'Aucun enseignant assigné',
                iconBgColor: iconBackgroundColor,
              )
            else
              ...professorNames.map((name) => _buildInfoRow(
                icon: Icons.person_outline,
                text: name, // <-- (Dynamic)
                iconBgColor: iconBackgroundColor,
              )).toList(),

            // (Ma 3ndnaš Tel w Email f l-Model l-jdid, dakši 3laš 7iydnahom)

            const SizedBox(height: 20),

            // --- القسم 4: إحصائيات الوحدة ---
            _buildSectionTitle('Statistiques du module'),

            // [تصحيح 3] Kanst3mlo l-Stats l-jdad
            _buildStatRow(
              icon: Icons.group_outlined,
              label: 'Groupes (TP/TD)',
              value: module.totalGroups.toString(), // <-- (Dynamic)
              iconBgColor: iconBackgroundColor,
            ),
            _buildStatRow(
              icon: Icons.person_outline,
              label: 'Enseignants',
              value: module.totalProfessors.toString(), // <-- (Dynamic)
              iconBgColor: iconBackgroundColor,
            ),
            _buildStatRow(
              icon: Icons.calendar_today,
              label: 'Séances programmées',
              value: module.totalSessions.toString(), // <-- (Dynamic)
              iconBgColor: iconBackgroundColor,
            ),
            _buildStatRow(
              icon: Icons.edit_note,
              label: 'Évaluations',
              value: module.totalEvaluations.toString(), // <-- (Dynamic)
              iconBgColor: iconBackgroundColor,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // (L-Widgets l-mosa3ida bqat kifma hiya)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(color: Colors.grey[300], thickness: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color iconBgColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.black54, size: 22),
      ),
      title: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconBgColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.black54, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}