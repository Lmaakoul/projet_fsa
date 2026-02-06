// المسار: lib/features/3_professor_role/prof/screen/notifications_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:university_app/core/theme/app_colors.dart'; // تأكد أن هذا المسار صحيح في مشروعك

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // بيانات وهمية للتجربة
  final List<Map<String, dynamic>> _notifications = [
    {
      "id": 1,
      "studentName": "Mohamed Taha",
      "message": "Bonjour Monsieur, j'étais absent à la séance de lundi car j'étais malade.",
      "date": "2024-10-15",
      "time": "08:45",
      "response": null,
      "justificatif": "assets/certificat.pdf", // تأكد من وجود ملف PDF في الـ assets للتجربة
    },
    {
      "id": 2,
      "studentName": "Sara El Idrissi",
      "message": "Bonjour, J'appartient au groupe G2, je vous informe que je n’ai pas pu être présente à la séance de TP. Est-ce possible de rattraper avec groupe G1 ?",
      "date": "2025-02-14",
      "time": "15:30",
      "response": null,
      "justificatif": null,
    },
    {
      "id": 3,
      "studentName": "Lina Ait El Haj",
      "message": "Bonjour Monsieur, Je fais partie du groupe G2. J’étais absente car j’avais une réunion avec mon encadrant.",
      "date": "2025-01-16",
      "time": "10:20",
      "response": null,
      "justificatif": null,
    },
  ];

  // دالة معالجة الرد (قبول أو رفض مع سبب)
  void _respondToNotification(int id, String decision, {String? refusalReason}) {
    setState(() {
      final notification = _notifications.firstWhere((notif) => notif["id"] == id);
      String message = "";

      if (decision == "accept") {
        message = "Bonjour ${notification['studentName']}, votre demande a été acceptée.";
      } else {
        // حالة الرفض مع دمج السبب
        if (refusalReason != null && refusalReason.isNotEmpty) {
          message = "Bonjour ${notification['studentName']}, votre demande a été refusée. Motif: $refusalReason";
        } else {
          message = "Bonjour ${notification['studentName']}, votre demande a été refusée.";
        }
      }

      notification["response"] = {
        "message": message,
        "status": decision,
      };
    });
  }

  // ==========================================
  // ✅ بوب-آب الرفض بتصميم احترافي (UI/UX Improved)
  // ==========================================
  Future<void> _showRefusalDialog(Map<String, dynamic> notification) async {
    final TextEditingController reasonController = TextEditingController();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // حواف دائرية ناعمة
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. أيقونة ورأس النافذة
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.note_alt_outlined,
                    size: 35,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 15),

                const Text(
                  'Motif de Refus',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  "Veuillez indiquer la raison du refus pour l'étudiant.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // 2. حقل الكتابة بتصميم حديث
                TextField(
                  controller: reasonController,
                  autofocus: true,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Ex: Certificat non valide, date incorrecte...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(15),
                  ),
                ),
                const SizedBox(height: 25),

                // 3. الأزرار
                Row(
                  children: [
                    // زر الإلغاء
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // زر التأكيد
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Refuser',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    // تنفيذ الرفض إذا تم التأكيد
    if (confirmed == true && mounted) {
      String reason = reasonController.text;
      _respondToNotification(notification['id'], "refuse", refusalReason: reason);
    }
  }

  // دوال مساعدة لفتح الـ PDF
  Future<String?> _getFilePathFromAssets(String? assetPath) async {
    if (assetPath == null) return null;
    try {
      final byteData = await DefaultAssetBundle.of(context).load(assetPath);
      final fileName = assetPath.split('/').last;
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
      return tempFile.path;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement du fichier: $e")),
      );
      return null;
    }
  }

  Future<void> _openJustificatif(String? assetPath) async {
    final filePath = await _getFilePathFromAssets(assetPath);
    if (filePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(pdfPath: filePath),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun justificatif disponible.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _buildNotificationList(),
    );
  }

  Widget _buildNotificationList() {
    if (_notifications.isEmpty) {
      return const Center(
        child: Text(
          "Aucun message reçu.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];

        return Card(
          elevation: 4, // تخفيف الظل ليكون أكثر عصرية
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // رأس البطاقة (الاسم والوقت)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: AppColors.selectedNavItemColor.withOpacity(0.1),
                          child: const Icon(Icons.person, size: 18, color: AppColors.selectedNavItemColor),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${notification['studentName']}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${notification['date']}",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          "${notification['time']}",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),

                const Divider(height: 20),

                // نص الرسالة
                Text(
                  "${notification['message']}",
                  style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                ),

                const SizedBox(height: 10),

                // رابط التبرير (المرفق)
                if (notification['justificatif'] != null)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                      title: const Text("Justificatif Médical.pdf", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      trailing: TextButton(
                        onPressed: () => _openJustificatif(notification['justificatif']),
                        child: const Text("Voir"),
                      ),
                    ),
                  ),

                const SizedBox(height: 15),

                // قسم الرد (يظهر فقط إذا تم الرد)
                if (notification['response'] != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: notification['response']['status'] == 'accept'
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: notification['response']['status'] == 'accept'
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              notification['response']['status'] == 'accept' ? Icons.check_circle : Icons.cancel,
                              size: 18,
                              color: notification['response']['status'] == 'accept' ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              notification['response']['status'] == 'accept' ? "Demande Acceptée" : "Demande Refusée",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: notification['response']['status'] == 'accept' ? Colors.green.shade800 : Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification['response']['message'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),

                // أزرار الإجراءات (تظهر فقط إذا لم يتم الرد بعد)
                if (notification['response'] == null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _showRefusalDialog(notification), // ✅ استدعاء البوب-آب الجديد
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text("Refuser"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () => _respondToNotification(notification['id'], "accept"),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text("Accepter"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// صفحة عرض PDF
class PDFViewerPage extends StatelessWidget {
  final String pdfPath;
  const PDFViewerPage({Key? key, required this.pdfPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Justificatif"),
        backgroundColor: AppColors.selectedNavItemColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PDFView(
        filePath: pdfPath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur lors du chargement du PDF: $error")),
          );
        },
      ),
    );
  }
}