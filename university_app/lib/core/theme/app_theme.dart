// المسار: lib/core/theme/app_theme.dart
// (هذا هو الكود المصحح)

import 'package:flutter/material.dart';

class AppTheme {

  // --- 1. تعريف الألوان الأساسية ديالك ---

  // --- ألوان الوضع العادي (Light Mode) ---
  static const Color lightPrimary = Color(0xFF113A47); // الغامق (لـ AppBar)
  static const Color lightBackground = Color(0xFFF9F3FD); // الخلفية (البيضة/الوردية)
  static const Color lightBottomNav = Color.fromRGBO(197, 230, 237, 1); // الفاتح (لـ BottomNav)
  static const Color lightIndicator = Color.fromRGBO(17, 58, 71, .15); // الإشارة (ملي تكليكي)
  static const Color lightCard = Colors.white; // لون الكارتات والأزرار
  static const Color lightText = Color(0xFF113A47); // لون الكتابة

  // --- ألوان الوضع الليلي (Dark Mode) ---
  static const Color darkPrimary = Color(0xFF113A47); // غنخليو نفس اللون للـ AppBar
  static const Color darkBackground = Color(0xFF121212); // الخلفية (الكحلة)
  static const Color darkBottomNav = Color(0xFF1E1E1E); // لون غامق شوية (لـ BottomNav)
  static const Color darkIndicator = Color.fromRGBO(197, 230, 237, 1); // الإشارة (غتولي فاتحة)
  static const Color darkCard = Color(0xFF1E1E1E); // لون الكارتات (بحال البوتوم ناف)
  static const Color darkText = Colors.white70; // لون الكتابة


  // --- 2. بناء الثيم العادي (Light Theme) ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,

    // ثيم الـ AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: lightPrimary,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white), // أيقونات (بحال ☰)
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
    ),

    // ثيم الـ Drawer (السايد بار)
    drawerTheme: const DrawerThemeData(
      backgroundColor: lightBackground, // الخلفية ديالو
    ),

    // ثيم الـ BottomNavBar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: lightBottomNav,
      indicatorColor: lightIndicator,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      // لون الأيقونات والكتابة
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: lightPrimary); // ملي تكليكي
        }
        return IconThemeData(color: lightPrimary.withOpacity(0.7)); // عادي
      }),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(color: lightPrimary, fontWeight: FontWeight.bold, fontSize: 12);
        }
        return TextStyle(color: lightPrimary.withOpacity(0.7), fontSize: 12);
      }),
    ),

    // --- ✅  التصحيح الأول هنا ---
    cardTheme: CardThemeData( // بدلنا CardTheme بـ CardThemeData
      color: lightCard,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );


  // --- 3. بناء الثيم الليلي (Dark Theme) ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,

    // ثيم الـ AppBar (كيبقى تقريبا بحال اللايت)
    appBarTheme: const AppBarTheme(
      backgroundColor: darkPrimary,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
    ),

    // ثيم الـ Drawer (السايد بار)
    drawerTheme: const DrawerThemeData(
      backgroundColor: darkBackground, // الخلفية ديالو غامقة
    ),

    // ثيم الـ BottomNavBar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkBottomNav,
      indicatorColor: darkIndicator,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      // لون الأيقونات والكتابة
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: darkPrimary); // ملي تكليكي
        }
        return const IconThemeData(color: darkText); // عادي
      }),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(color: darkIndicator, fontWeight: FontWeight.bold, fontSize: 12);
        }
        return const TextStyle(color: darkText, fontSize: 12);
      }),
    ),

    // --- ✅  التصحيح الثاني هنا ---
    cardTheme: CardThemeData( // بدلنا CardTheme بـ CardThemeData
      color: darkCard,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}