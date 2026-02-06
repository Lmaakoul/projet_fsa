// ملف: lib/features/4_admin_role/screens/semestres/semestre_details_screen.dart

import 'package:flutter/material.dart';
import 'package:university_app/core/models/semestre.dart';

class SemestreDetailsScreen extends StatelessWidget {
  // يتم تمرير كائن Semestre الكامل إلى الشاشة
  final Semestre semestre;
  // يمكن إضافة token إذا كنا سنحتاج لجلب بيانات إضافية (مثل قائمة الـ Modules)
  final String token;

  const SemestreDetailsScreen({
    super.key,
    required this.semestre,
    required this.token,
  });

  // دالة مساعدة لبناء صف التفاصيل
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Label (العنوان)
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF113A47), // لون غامق للعناوين
              ),
            ),
          ),
          // 2. Value (القيمة)
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Détails: ${semestre.name}"),
        backgroundColor: const Color(0xFF113A47),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. القسم العلوي: العنوان الرئيسي ---
            Text(
              semestre.name ?? 'Semestre Inconnu',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF113A47),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Année: ${semestre.academicYear}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const Divider(height: 30, thickness: 1),

            // --- 2. تفاصيل الفصل الأساسية ---
            _buildDetailRow(
              "Code Semestre",
              semestre.code ?? 'N/A',
            ),
            _buildDetailRow(
              "Numéro du Semestre",
              semestre.semesterNumber.toString(),
            ),
            _buildDetailRow(
              "ID Unique",
              semestre.id,
            ),

            const Divider(height: 30, thickness: 1),

            // --- 3. تفاصيل الشعبة (Filière) ---
            const Text(
              "Informations sur la Filière",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF113A47),
              ),
            ),
            const SizedBox(height: 10),

            _buildDetailRow(
              "Filière",
              semestre.filiereName ?? 'Non spécifiée',
            ),
            _buildDetailRow(
              "ID Filière",
              semestre.filiereId ?? 'N/A',
            ),

            const Divider(height: 30, thickness: 1),

            // --- 4. جزء الوحدات (Modules) (يمكن تطويره لاحقاً) ---
            const Text(
              "Unités d'Enseignement (Modules)",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF113A47),
              ),
            ),
            const SizedBox(height: 10),

            // 💡 ملاحظة: هنا يمكنك لاحقاً إضافة FutureBuilder أو StreamBuilder
            // لجلب وعرض قائمة الـ Modules المرتبطة بهذا الـ SemestreId.

            const Text(
              "Cette section affichera les modules et les professeurs associés une fois implémentée.",
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),

          ],
        ),
      ),
    );
  }
}