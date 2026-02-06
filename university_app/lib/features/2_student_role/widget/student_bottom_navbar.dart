// المسار: lib/features/2_student_role/widget/student_bottom_navbar.dart
// (هادي هي النسخة الخاصة بالطالب)

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// 1. بدلنا سمية الكلاس
class StudentBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  // 2. بدلنا سمية الكونستراكتور
  const StudentBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // الألوان من الثيم
    final Color navBarBackground = Theme.of(context).navigationBarTheme.backgroundColor ?? const Color.fromRGBO(197, 230, 237, 1);
    final Color indicatorColor = Theme.of(context).navigationBarTheme.indicatorColor ?? const Color.fromRGBO(17, 58, 71, .15);

    return NavigationBar(
      backgroundColor: navBarBackground,
      indicatorColor: indicatorColor,
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(
            icon: Icon(LucideIcons.home),
            label: 'Accueil'
        ),
        NavigationDestination(
            icon: Icon(LucideIcons.fileLock2),
            label: 'Statistiques'
        ),

        // ==========================================
        // 3. هادا هو التعديل لي بغيتي
        //    بدلنا "Notifications" بـ "Identifiant"
        // ==========================================
        NavigationDestination(
            icon: Icon(LucideIcons.userSquare), // <-- بدلنا الأيقونة (مثلا: أيقونة هوية)
            label: 'Identifiant'                 // <-- بدلنا السمية
        ),
        // ==========================================

        NavigationDestination(
            icon: Icon(LucideIcons.userCircle),
            label: 'Profil'
        ),
      ],
    );
  }
}