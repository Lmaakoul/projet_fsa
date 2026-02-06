// ملف: identifiant_page.dart

import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart'; // 1. كنجيبو الباكج لي زدنا

class IdentifiantPage extends StatelessWidget {
  // هاد الصفحة غتحتاج الـ ID ديال الطالب باش تصاوب الكود
  final int etudiantId;

  const IdentifiantPage({Key? key, required this.etudiantId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // غنحولو الـ ID لـ String باش نخدمو بيه
    final String studentIdString = etudiantId.toString();

    return Container(
      color: Colors.white, // خلفية بيضاء بحال البروفايل
      width: double.infinity,
      child: Column(
        children: [
          // الفراغ لي اتفقنا عليه
          const SizedBox(height: 50.0),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // 2. البوطونة الأولى ديال QR Code
                IdentifiantButton(
                  icon: Icons.qr_code_2,
                  text: 'Afficher QR Code',
                  onTap: () {
                    // كنعيطو للدالة لي كتبيّن البوب-آب
                    _showCodeDialog(
                      context,
                      'Mon QR Code',
                      Barcode.qrCode(), // النوع هو QR
                      studentIdString, // البيانات هي ID الطالب
                    );
                  },
                ),
                const SizedBox(height: 10.0),

                // 3. البوطونة الثانية ديال Code Barre
                IdentifiantButton(
                  icon: Icons.barcode_reader,
                  text: 'Afficher Code Barre',
                  onTap: () {
                    // كنعيطو للدالة لي كتبيّن البوب-آب
                    _showCodeDialog(
                      context,
                      'Mon Code Barre',
                      Barcode.code128(), // النوع هو Barcode
                      studentIdString, // البيانات هي ID الطالب
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. هادي هي الدالة لي كتبيّن البوب-آب (Dialog)
  void _showCodeDialog(
      BuildContext context, String title, Barcode type, String data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: BarcodeWidget(
              barcode: type, // النوع (QR أو Barcode)
              data: data, // البيانات (ID الطالب)
              width: 200,
              height: 200,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// ==========================================================
// هادي Widget صاوبناها باش نرسمو البوطونات (بحال ديال البروفايل)
// ==========================================================
class IdentifiantButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const IdentifiantButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black54),
              const SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}