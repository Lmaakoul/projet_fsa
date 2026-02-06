import 'package:flutter/material.dart';
import 'package:university_app/features/2_student_role/screen/codeqr.dart';

class StudentCodeChoicePage extends StatelessWidget {
  final int etudiantId;

  const StudentCodeChoicePage({super.key, required this.etudiantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Ma Carte Digitale"),
        backgroundColor: const Color(0xFF190B60),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false, // لأنها في الـ BottomNav
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Choisissez le format à afficher",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF190B60)),
            ),
            const SizedBox(height: 40),

            // 1. زر QR Code
            _buildChoiceCard(
              context,
              title: "Code QR",
              icon: Icons.qr_code_2,
              color: Colors.blue,
              isQr: true,
            ),

            const SizedBox(height: 20),

            // 2. زر Code-Barres
            _buildChoiceCard(
              context,
              title: "Code-Barres",
              icon: Icons.view_week_outlined, // أيقونة تشبه الباركود
              color: Colors.purple,
              isQr: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCard(BuildContext context, {required String title, required IconData icon, required Color color, required bool isQr}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // الانتقال لصفحة العرض مع تحديد النوع
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CodeQRPage(
                etudiantId: etudiantId,
                showQr: isQr, // نمرر هذا المتغير لتحديد ما سنعرضه
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}