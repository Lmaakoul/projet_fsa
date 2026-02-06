// المسار: lib/core/shared_widgets/custom_bottom_navbar.dart
// (الكود المصحح للأيقونة الجديدة)

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
        // --- ✅  التعديل الوحيد هنا ---
        NavigationDestination(
            icon: Icon(LucideIcons.fileLock2), // 1. بدلنا الأيقونة لـ fileLock2
            label: 'Statistiques'              // 2. السمية كتبقى "Statistiques"
        ),
        // --------------------------
        NavigationDestination(
            icon: Icon(LucideIcons.bellDot),
            label: 'Notifications'
        ),
        NavigationDestination(
            icon: Icon(LucideIcons.userCircle),
            label: 'Profil'
        ),
      ],
    );
  }
}