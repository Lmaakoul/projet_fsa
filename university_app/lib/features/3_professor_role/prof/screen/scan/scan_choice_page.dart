import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ✅ اسم الكلاس كما هو عندك في الصورة
class PresenceMethodScreen extends StatelessWidget {

  final Map<String, dynamic> sessionData;

  const PresenceMethodScreen({
    super.key,
    // قيم افتراضية للتجربة
    this.sessionData = const {
      "module": "Compilation",
      "groupe": "G2",
      "seance": "Compilation (C) (09:00)",
    },
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF004D40);
    const Color cardBackgroundColor = Colors.white;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Méthode de présence",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1️⃣ بطاقة المعلومات
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.book_outlined, "Module:", sessionData['module'] ?? 'N/A'),
                  const Divider(height: 20),
                  _buildInfoRow(Icons.group_outlined, "Groupe:", sessionData['groupe'] ?? 'N/A'),
                  const Divider(height: 20),
                  _buildInfoRow(Icons.access_time, "Séance:", sessionData['seance'] ?? 'N/A'),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Comment voulez-vous marquer la présence ?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
            ),

            const SizedBox(height: 30),

            // 2️⃣ الأزرار (Buttons)

            // زر 1: Scanner Code QR
            _buildMethodButton(
              context,
              title: "Scanner Code QR",
              icon: Icons.qr_code_scanner,
              iconColor: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, '/scanQR', arguments: sessionData);
              },
            ),

            const SizedBox(height: 15),

            // زر 2: Scanner Code-Barres (الخيار الجديد ✅)
            _buildMethodButton(
              context,
              title: "Scanner Code-Barres",
              icon: FontAwesomeIcons.barcode,
              iconColor: Colors.purple,
              onTap: () {
                Navigator.pushNamed(context, '/scanBarcode', arguments: sessionData);
              },
            ),

            const SizedBox(height: 15),

            // زر 3: Liste Manuelle
            _buildMethodButton(
              context,
              title: "Liste Manuelle",
              icon: FontAwesomeIcons.listCheck,
              iconColor: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, '/manualList', arguments: sessionData);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.teal[700], fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildMethodButton(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color iconColor,
        required VoidCallback onTap,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87))),
                const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}