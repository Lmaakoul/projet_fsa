// ملف: lib/features/4_admin_role/screens/profile/admin_profile_screen.dart
// (النسخة المصححة - كتستقبل الـ Token والـ ID)

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'admin_info_page.dart';
import 'admin_about_page.dart';

class AdminProfileScreen extends StatelessWidget {

  // [تعديل 1]: زدنا هادو باش نستقبلو الـ Token والـ ID
  final String adminId;
  final String token;

  // [تعديل 2]: حيدنا 'const' وزدناهم هنا
  const AdminProfileScreen({
    Key? key,
    required this.adminId,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F3FD),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 30.0),

            // ==========================================
            // [تعديل 3]: دوزنا الـ ID والـ Token لصفحة 'AdminInfoPage'
            // ==========================================
            ProfileMenuItem(
              icon: LucideIcons.user,
              text: 'Informations Personnelles',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminInfoPage(
                      adminId: adminId, // <-- دوزناه
                      token: token,   // <-- دوزناه
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10.0),

            // (البوطونة الثانية: كتبقى كيفما هي)
            ProfileMenuItem(
              icon: LucideIcons.settings,
              text: 'Paramètres de l\'application',
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            const SizedBox(height: 10.0),

            // (البوطونة الثالثة: كتبقى كيفما هي)
            ProfileMenuItem(
              icon: LucideIcons.info,
              text: 'A Propos',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminAboutPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// (ويدجت البوطونة كيبقى كيفما هو)
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200)
          ),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColorDark),
              const SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}