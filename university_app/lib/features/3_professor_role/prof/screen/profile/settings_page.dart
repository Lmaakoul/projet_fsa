// المسار: lib/features/3_professor_role/prof/screen/profile/settings_page.dart

import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // متغيرات للحالة (للتجربة فقط)
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F0FC), // نفس لون خلفية البروفايل
      appBar: AppBar(
        title: const Text(
          "Paramètres",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- قسم الحساب والأمان ---
          _buildSectionHeader("Compte & Sécurité"),
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline,
            title: "Changer le mot de passe",
            onTap: () {
              // هنا تضع كود الانتقال لصفحة تغيير كلمة السر
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Changer le mot de passe")));
            },
          ),
          _buildSwitchTile(
            context,
            icon: Icons.fingerprint,
            title: "Authentification Biométrique",
            subtitle: "Face ID / Empreinte",
            value: _biometricEnabled,
            onChanged: (val) => setState(() => _biometricEnabled = val),
          ),

          const SizedBox(height: 20),

          // --- قسم التنبيهات والعرض ---
          _buildSectionHeader("Préférences"),
          _buildSwitchTile(
            context,
            icon: Icons.notifications_active_outlined,
            title: "Notifications",
            subtitle: "Rappel des séances, Annonces...",
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          _buildSwitchTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: "Mode Sombre",
            value: _isDarkMode,
            onChanged: (val) => setState(() => _isDarkMode = val),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.language,
            title: "Langue",
            trailing: const Text("Français", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            onTap: () {
              // كود تغيير اللغة
            },
          ),

          const SizedBox(height: 20),

          // --- قسم الدعم ---
          _buildSectionHeader("Support"),
          _buildSettingsTile(
            context,
            icon: Icons.mail_outline,
            title: "Contacter l'administration",
            onTap: () {
              // فتح تطبيق الايميل
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: "Conditions d'utilisation",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // --- Widgets مساعدة لتكرار التصميم ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // عنصر قائمة عادي (مثل تغيير كلمة السر)
  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Widget? trailing}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // عنصر قائمة مع زر تفعيل/تعطيل (Switch)
  Widget _buildSwitchTile(BuildContext context, {required IconData icon, required String title, String? subtitle, required bool value, required Function(bool) onChanged}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}