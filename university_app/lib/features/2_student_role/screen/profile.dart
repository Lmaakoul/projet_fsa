import 'package:flutter/material.dart';
import 'package:university_app/core/services/auth_service.dart';

// ✅ استيراد الصفحات الفرعية
import 'information_personnelles_page.dart';
import 'a_propos_page.dart';
import 'historique_presence_page.dart';

class ProfilePage extends StatelessWidget {
  final int? etudiantId; // جعلناه اختياري مؤقتاً لتجنب الأخطاء إذا لم يتم تمريره

  const ProfilePage({super.key, this.etudiantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      // لا نحتاج AppBar هنا لأنه موجود في التصميم العام، لكن يمكن إضافته للجمالية
      appBar: AppBar(
        title: const Text("Mon Profil"),
        centerTitle: true,
        backgroundColor: const Color(0xFF190B60),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // 👤 صورة البروفايل
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF190B60), width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                ),
                child: const Icon(Icons.person, size: 50, color: Color(0xFF190B60)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
                "Étudiant #${etudiantId ?? '000'}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF190B60))
            ),
            const SizedBox(height: 30),

            // 📋 القائمة (Menu)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 1. المعلومات الشخصية
                  _ProfileMenuItem(
                    icon: Icons.person_outline,
                    text: 'Informations Personnelles',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InformationPersonnellesPage(etudiantId: etudiantId ?? 0),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),

                  // 2. سجل الحضور
                  _ProfileMenuItem(
                    icon: Icons.history,
                    text: 'Historique De Présence',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoriquePresencePage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),

                  // 3. عن التطبيق
                  _ProfileMenuItem(
                    icon: Icons.info_outline,
                    text: 'A Propos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AProposPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),

                  // 4. تسجيل الخروج
                  _ProfileMenuItem(
                    icon: Icons.logout,
                    text: 'Se déconnecter',
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: () async {
                      final authService = AuthService();
                      await authService.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// تصميم العنصر الواحد في القائمة
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color textColor;
  final Color iconColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.text,
    required this.onTap,
    this.textColor = const Color(0xFF2D3748),
    this.iconColor = const Color(0xFF190B60),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                ),
              ),
              if (text != 'Se déconnecter')
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}