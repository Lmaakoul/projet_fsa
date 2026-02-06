// المسار: lib/features/3_professor_role/prof/widget/bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // تأكد من المكتبة التي تستخدمها

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Theme.of(context).primaryColor, // لون العنصر المحدد
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        // 1. التقويم
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.calendar),
          label: "Séance",
        ),

        // 2. الإشعارات
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.bell),
          label: "Notifs",
        ),

        // 3. البروفايل (✅ هنا التغيير المهم)
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.user), // ✅ أيقونة المستخدم
          label: "Profil",              // ✅ الاسم: Profil
        ),
      ],
    );
  }
}