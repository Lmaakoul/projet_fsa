// ملف: lib/features/4_admin_role/screens/filieres/filiere_details_screen.dart
// (النسخة النهائية - دمج التصميم الجميل مع البيانات الحقيقية)

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // تأكد من وجود هذه المكتبة أو استبدلها بـ Icons
import 'package:university_app/core/models/filiere.dart';
import 'edit_filiere_screen.dart'; // لاستخدام زر التعديل

class FiliereDetailsScreen extends StatelessWidget {
  final Filiere filiere; // 🛑 نستخدم الموديل مباشرة
  final String token;    // 🛑 نحتاج التوكن للتعديل

  const FiliereDetailsScreen({
    super.key,
    required this.filiere,
    required this.token,
  });

  // دالة الانتقال للتعديل
  void _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditFiliereScreen(token: token, filiere: filiere)),
    );
    if (result == true) {
      Navigator.pop(context, true); // العودة وتحديث القائمة
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryAppBarColor = Color(0xFF113A47); // نفس لون التطبيق الموحد
    const Color lightPinkBackground = Color(0xFFFCF5F8);
    const Color iconBackgroundColor = Color(0xFFEBF0F3);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryAppBarColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Fiche Filière',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      // 🛑 زر التعديل العائم (مهم)
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryAppBarColor,
        onPressed: () => _navigateToEdit(context),
        child: const Icon(LucideIcons.pencil, color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // (الهيدر)
            Container(
              color: lightPinkBackground,
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FILIÈRE',
                    style: TextStyle(color: Colors.grey[600], letterSpacing: 1.2, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    filiere.name, // ✅ الاسم من الموديل
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),

            // (المعلومات العامة)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSectionTitle('Informations générales'),
                  const SizedBox(height: 10),

                  _buildInfoRow(
                    icon: LucideIcons.qrCode, // أو Icons.qr_code
                    text: filiere.code, // ✅ الكود
                    iconBgColor: iconBackgroundColor,
                    label: "Code",
                  ),
                  _buildInfoRow(
                    icon: LucideIcons.building, // أو Icons.business
                    text: filiere.departmentName ?? 'Non assigné', // ✅ القسم
                    iconBgColor: iconBackgroundColor,
                    label: "Département",
                  ),
                  _buildInfoRow(
                    icon: LucideIcons.graduationCap, // أو Icons.school
                    text: filiere.degreeType, // ✅ المستوى
                    iconBgColor: iconBackgroundColor,
                    label: "Niveau",
                  ),
                  _buildInfoRow(
                    icon: LucideIcons.timer, // أو Icons.timer
                    text: "${filiere.durationYears} Ans", // ✅ المدة
                    iconBgColor: iconBackgroundColor,
                    label: "Durée",
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            const Divider(height: 1),

            // (إحصائيات - إن وجدت في الموديل أو نعرض بيانات افتراضية حالياً)
            Container(
              color: lightPinkBackground,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSectionTitle('Statistiques'),
                  const SizedBox(height: 10),

                  // ملاحظة: إذا لم تكن هذه الأرقام في الـ API، يمكنك حذف هذا القسم أو عرضه كـ 0
                  _buildStatRow(
                    icon: LucideIcons.users, // أو Icons.group
                    label: 'Nombre total d\'étudiants',
                    value: "0", // ⚠️ يحتاج ربط مع API الإحصائيات
                    iconBgColor: iconBackgroundColor,
                  ),
                  _buildStatRow(
                    icon: LucideIcons.layers, // أو Icons.layers
                    label: 'Nombre de Semestres',
                    // حساب عدد الفصول (سنتين = 4، 3 سنوات = 6)
                    value: "${filiere.durationYears * 2}",
                    iconBgColor: iconBackgroundColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80), // مساحة للزر العائم
          ],
        ),
      ),
    );
  }

  // (ويدجت عنوان القسم)
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
      ],
    );
  }

  // (ويدجت صف المعلومات)
  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required String label, // أضفت العنوان للتوضيح
    required Color iconBgColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF113A47), size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text(
                  text,
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // (ويدجت صف الإحصائيات)
  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconBgColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.black54, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                Text(
                  value,
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}