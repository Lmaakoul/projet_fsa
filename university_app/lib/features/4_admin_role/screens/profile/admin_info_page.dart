// ملف: lib/features/4_admin_role/screens/profile/admin_info_page.dart
// (النسخة المصححة - كتستقبل الـ Token والـ ID)

import 'package:flutter/material.dart';

class AdminInfoPage extends StatelessWidget {

  // [تعديل 1]: زدنا هادو باش نستقبلو الـ Token والـ ID
  final String adminId;
  final String token;

  // [تعديل 2]: حيدنا 'const' وزدناهم هنا
  const AdminInfoPage({
    Key? key,
    required this.adminId,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F3FD),
      appBar: AppBar(
        title: const Text('Informations Personnelles'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // (غنخليو بيانات وهمية دابا، وغنصلحوهم من بعد)
          const ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Nom Complet'),
            subtitle: Text('Mme. SALWA BELAQZIZ'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.email_outlined),
            title: Text('Email'),
            subtitle: Text('admin@test.com'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.badge_outlined),
            title: Text('Rôle'),
            subtitle: Text('Administrateur'),
          ),

          // [تعديل 3]: (اختياري) غنأفيشيو الـ ID والـ Token باش نتأكدو
          const Divider(color: Colors.red, thickness: 1),
          ListTile(
            leading: const Icon(Icons.vpn_key_outlined, color: Colors.red),
            title: const Text('Admin ID (للتجريب)'),
            subtitle: Text(adminId), // (كيجي من الـ widget)
          ),
          ListTile(
            leading: const Icon(Icons.security_outlined, color: Colors.red),
            title: const Text('Token (للتجريب)'),
            subtitle: Text(
              token, // (كيجي من الـ widget)
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}