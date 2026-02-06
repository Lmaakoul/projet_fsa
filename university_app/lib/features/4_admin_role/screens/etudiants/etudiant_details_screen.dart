// ملف: lib/features/4_admin_role/screens/etudiants/etudiant_details_screen.dart
// (النسخة المصححة - Zidna fih l-Groupe)

import 'package:flutter/material.dart';
import 'package:university_app/core/models/student.dart';

const Color primaryAppBarColor = Color(0xFF0A4F48);
const Color pageBackgroundColor = Color(0xFFF7F7F7);

class EtudiantDetailsScreen extends StatelessWidget {
  final Student student;
  final String groupeCode; // <-- [جديد] Zidna l-Groupe hna

  const EtudiantDetailsScreen({
    super.key,
    required this.student,
    required this.groupeCode, // <-- [جديد]
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryAppBarColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Fiche Étudiant', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Nom Complet:', student.fullName),
                _buildDetailRow('CNE:', student.cne),
                _buildDetailRow('CIN:', student.cin),
                _buildDetailRow('Email:', student.email),
                _buildDetailRow('Date de Naissance:', student.dateOfBirth ?? 'N/A'),
                _buildDetailRow('Filière:', student.filiereName ?? 'N/A'),
                _buildDetailRow('Groupe (Actuel):', groupeCode), // <-- [جديد] Zidna l-Groupe
                _buildDetailRow('ID Étudiant (Test):', student.id),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }
}