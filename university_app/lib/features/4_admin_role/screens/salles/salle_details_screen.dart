// ملف: lib/features/4_admin_role/screens/salles/salle_details_screen.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:university_app/core/models/salle.dart';
import 'edit_salle_screen.dart'; // 🛑 تأكد من استيراد شاشة التعديل

class SalleDetailsScreen extends StatelessWidget {
  final String token; // 🛑 نحتاج التوكن للتعديل
  final Salle salle;

  const SalleDetailsScreen({
    super.key,
    required this.token,
    required this.salle,
  });

  void _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditSalleScreen(token: token, salle: salle)),
    );
    // إذا تم التعديل، نعود للخلف لتحديث القائمة
    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF113A47);
    const Color bgColor = Color(0xFFF9F3FD);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Détails de la Salle", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // 🛑 زر التعديل العائم (كما في رسمك)
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _navigateToEdit(context),
        child: const Icon(LucideIcons.pencil, color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // بطاقة العنوان
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                border: const Border(top: BorderSide(color: primaryColor, width: 5)),
              ),
              child: Column(
                children: [
                  const Icon(LucideIcons.doorOpen, size: 50, color: primaryColor),
                  const SizedBox(height: 15),
                  Text(
                    salle.code,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    salle.departmentName,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // المعلومات
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Informations Générales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                  const Divider(height: 30),

                  _buildInfoRow(LucideIcons.building, "Bâtiment", salle.building),
                  _buildInfoRow(LucideIcons.layoutTemplate, "Type", salle.type),
                  _buildInfoRow(LucideIcons.users, "Capacité", "${salle.capacity} places"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}