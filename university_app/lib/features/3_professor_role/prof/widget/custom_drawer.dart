import 'package:flutter/material.dart';
import 'package:university_app/features/3_professor_role/prof/service/prof_service.dart';
import 'package:university_app/core/theme/app_colors.dart';
import 'package:university_app/features/3_professor_role/prof/screen/profile/infos_personnelles_page.dart';
import 'package:university_app/features/1_auth/connexion/screen/login.dart';

// ✅✅✅ التصحيح هنا: استيراد AuthService من المسار الصحيح
import 'package:university_app/core/services/auth_service.dart';

class CustomDrawer extends StatelessWidget {
  final int profId;

  // تعريف الخدمات
  final ProfService _profService = ProfService();
  final AuthService _authService = AuthService(); // تأكد من استخدام الاسم الصحيح

  CustomDrawer({super.key, required this.profId});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ... (تصميم الـ Header وباقي العناصر الخاص بك) ...

          // مثال لزر تسجيل الخروج باستخدام AuthService
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await _authService.logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}