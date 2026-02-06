// ملف: lib/features/4_admin_role/screens/seances/seance_details_screen.dart
// (هادي هي الصفحة الجديدة ديال التفاصيل)

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SeanceDetailsScreen extends StatelessWidget {
  // 1. البيانات لي غتستقبل هاد الصفحة
  final Map<String, dynamic> seance;

  const SeanceDetailsScreen({
    super.key,
    required this.seance,
  });

  @override
  Widget build(BuildContext context) {
    // (كنستعملو نفس الألوان ديال الآدمين)
    const Color primaryAppBarColor = Color(0xFF113A47);
    const Color lightPinkBackground = Color(0xFFF9F3FD);
    const Color iconBackgroundColor = Color(0xFFEBF0F3);

    return Scaffold(
      backgroundColor: lightPinkBackground, // <-- الخلفية الموف الفاتح
      appBar: AppBar(
        backgroundColor: primaryAppBarColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Fiche Séance',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- الهيدر (العنوان) ---
            Container(
              color: lightPinkBackground,
              width: double.infinity,
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
                    seance['module'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // --- المعلومات العامة ---
            Container(
              color: lightPinkBackground,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSectionTitle('Informations générales'),
                  _buildInfoRow(
                    icon: LucideIcons.user, // (أيقونة الأستاذ)
                    text: seance['enseignant'] ?? 'N/A',
                    iconBgColor: iconBackgroundColor,
                  ),
                  _buildInfoRow(
                    icon: LucideIcons.calendar,
                    text: seance['date'] ?? 'N/A',
                    iconBgColor: iconBackgroundColor,
                  ),
                  _buildInfoRow(
                    icon: LucideIcons.clock,
                    text: "${seance['heureDebut']} - ${seance['heureFin']}",
                    iconBgColor: iconBackgroundColor,
                  ),
                  _buildInfoRow(
                    icon: LucideIcons.users,
                    text: seance['groupe'] ?? 'N/A',
                    iconBgColor: iconBackgroundColor,
                  ),
                  _buildInfoRow(
                    icon: LucideIcons.mapPin,
                    text: seance['salle'] ?? 'N/A',
                    iconBgColor: iconBackgroundColor,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // (تقدر تزيد هنا ليستة الطلبة الحاضرين/الغايبين من بعد)
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 2. هادو هوما الدوال المساعدة ديال الستايل
  // (كوبيناهم من filiere_details_screen.dart)
  // ==========================================

  // (ويدجت عنوان القسم)
  Widget _buildSectionTitle(String title) {
    return Row(
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
    );
  }

  // (ويدجت صف المعلومات)
  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color iconBgColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
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
}