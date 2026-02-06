// ملف: lib/features/4_admin_role/screens/groups/group_details_screen.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:university_app/core/models/group.dart';

class GroupDetailsScreen extends StatelessWidget {
  final Group group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F3FD),
      appBar: AppBar(
        title: Text(group.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF113A47),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoCard("Informations Générales", [
              _buildInfoRow(LucideIcons.users, "Nom", group.name),
              _buildInfoRow(LucideIcons.hash, "Code", group.code ?? 'N/A'),
              _buildInfoRow(LucideIcons.maximize, "Capacité Max", "${group.maxCapacity}"),
              _buildInfoRow(LucideIcons.users, "Capacité Actuelle", "${group.currentCapacity}"),
            ]),
            const SizedBox(height: 15),
            _buildInfoCard("Module Associé", [
              _buildInfoRow(LucideIcons.bookOpen, "Module", group.moduleTitle ?? 'Non assigné'),
              // يمكنك إضافة اسم الأستاذ أو تفاصيل أخرى هنا إذا كانت متوفرة في الموديل
            ]),
            const SizedBox(height: 15),
            // حالة الامتلاء
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: group.isFull ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: group.isFull ? Colors.red : Colors.green),
              ),
              child: Row(
                children: [
                  Icon(group.isFull ? LucideIcons.alertCircle : LucideIcons.checkCircle,
                      color: group.isFull ? Colors.red : Colors.green),
                  const SizedBox(width: 10),
                  Text(
                    group.isFull ? "Groupe Complet" : "Places Disponibles",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: group.isFull ? Colors.red : Colors.green,
                        fontSize: 16
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF113A47))),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}