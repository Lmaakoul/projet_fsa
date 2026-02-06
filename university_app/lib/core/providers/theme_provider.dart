// المسار: lib/core/providers/theme_provider.dart

import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {

  // غنبداو بالوضع العادي (Light)
  ThemeMode _themeMode = ThemeMode.light;

  // هادي باش نقراو القيمة
  ThemeMode get themeMode => _themeMode;

  // هادي هي الدالة اللي غتبدل الثيم
  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;

    // هادي مهمة: كتعلم التطبيق كامل بلي القيمة تبدلات
    notifyListeners();
  }
}