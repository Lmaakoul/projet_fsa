// المسار: lib/features/4_admin_role/screens/settings/settings_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:university_app/core/providers/theme_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // هادي كتجيب لينا الـ providers باش نقدرو نخدمو بيه
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
      ),
      body: ListView(
        children: [
          // هذا هو الزر ديال تبدال الثيم
          SwitchListTile(
            title: const Text("Mode Sombre (Dark Mode)"),
            subtitle: const Text("Activer le mode sombre pour l'application"),
            secondary: Icon(
                themeProvider.themeMode == ThemeMode.dark
                    ? LucideIcons.moon
                    : LucideIcons.sun
            ),
            // القيمة ديال الزر (واش خدام ولا طافي)
            value: themeProvider.themeMode == ThemeMode.dark,

            // شنو غيوقع ملي نكليكيو عليه
            onChanged: (bool newValue) {
              // غنعيطو للدالة اللي فـ provider باش نبدلو الثيم
              themeProvider.toggleTheme(newValue);
            },
          ),

          const Divider(),

          // هنا تقدر تزيد إعدادات أخرين من بعد
          ListTile(
            leading: Icon(LucideIcons.languages),
            title: Text("Langue"),
            subtitle: Text("Français"),
            onTap: () {
              // TODO: Add language switching
            },
          ),
        ],
      ),
    );
  }
}