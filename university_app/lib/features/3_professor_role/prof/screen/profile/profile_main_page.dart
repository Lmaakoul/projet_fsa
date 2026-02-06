// المسار: lib/features/3_professor_role/prof/screen/profile/profile_main_page.dart

import 'package:flutter/material.dart';

// ✅ استيراد الصفحات الفرعية
import 'infos_personnelles_page.dart';
import 'about_page.dart';
import 'settings_page.dart'; // ✅ تأكد من وجود هذا الملف

class ProfileMainPage extends StatelessWidget {
  final int profId;

  const ProfileMainPage({Key? key, required this.profId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // لون الخلفية الفاتح
    final Color backgroundColor = const Color(0xFFF8F0FC);

    // 🛑 لا نستخدم Scaffold هنا لأن الصفحة معروضة داخل MainScreen
    return Container(
      color: backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          children: [
            // --- الخيار الأول: المعلومات الشخصية ---
            _buildProfileOptionCard(
              context,
              icon: Icons.person_outline,
              title: "Informations Personnelles",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InfoPersonnellePage(profId: profId),
                  ),
                );
              },
            ),

            // --- الخيار الثاني: الإعدادات ---
            _buildProfileOptionCard(
              context,
              icon: Icons.settings_outlined,
              title: "Paramètres de l'application",
              onTap: () {
                // ✅ التوجيه لصفحة الإعدادات الجديدة
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
            ),

            // --- الخيار الثالث: عن التطبيق ---
            _buildProfileOptionCard(
              context,
              icon: Icons.info_outline,
              title: "A Propos",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- دالة مساعدة لبناء بطاقة الخيار (لتقليل التكرار) ---
  Widget _buildProfileOptionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0), // مسافة بين البطاقات
      child: Card(
        elevation: 2, // ظل خفيف
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // زوايا دائرية
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                // الأيقونة بلون التطبيق الأساسي
                Icon(icon, color: Theme.of(context).primaryColor, size: 26),

                const SizedBox(width: 20),

                // العنوان
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // سهم التوجيه الرمادي
                const Icon(Icons.chevron_right, color: Colors.grey, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}