import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:university_app/core/theme/app_colors.dart';

class StudentNotificationsPage extends StatefulWidget {
  const StudentNotificationsPage({Key? key}) : super(key: key);

  @override
  _StudentNotificationsPageState createState() => _StudentNotificationsPageState();
}

class _StudentNotificationsPageState extends State<StudentNotificationsPage> {
  // --- MOCK DATA ---
  final List<Map<String, dynamic>> _notifications = [
    {
      "id": 1,
      "senderName": "Administration",
      "type": "absence_alert",
      "title": "Nouvelle Absence Enregistrée",
      "message": "Vous avez été marqué absent lors de la séance de 'Programmation Mobile' le Lundi 14 Oct.",
      "date": "2024-10-15",
      "time": "09:30",
      "read": false,
    },
    {
      "id": 2,
      "senderName": "Pr. Ahmed Alami",
      "type": "request_accepted",
      "title": "Justification Acceptée",
      "message": "Votre demande de justification pour l'absence du 10/10/2024 a été validée.",
      "date": "2024-10-12",
      "time": "14:20",
      "read": true,
      "attachment": null,
    },
    {
      "id": 3,
      "senderName": "Pr. Sara Idrissi",
      "type": "request_refused",
      "title": "Demande Refusée",
      "message": "Votre demande de changement de groupe a été refusée.",
      "reason": "Les groupes sont complets.",
      "date": "2024-10-11",
      "time": "10:00",
      "read": true,
    },
    {
      "id": 4,
      "senderName": "Département Informatique",
      "type": "info",
      "title": "Emploi du temps",
      "message": "Veuillez trouver ci-joint le calendrier des examens pour la session d'automne.",
      "date": "2024-10-09",
      "time": "08:00",
      "read": true,
      "attachment": "assets/calendrier.pdf",
    },
  ];

  // --- HELPERS ---
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
        SnackBar(content: Text("Fichier non trouvé (Demo Mode): $e")),
      );
      return null;
    }
  }

  Future<void> _openAttachment(String? assetPath) async {
    final filePath = await _getFilePathFromAssets(assetPath);
    if (filePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(pdfPath: filePath),
        ),
      );
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'absence_alert': return Icons.warning_amber_rounded;
      case 'request_accepted': return Icons.check_circle_outline;
      case 'request_refused': return Icons.cancel_outlined;
      case 'info': default: return Icons.notifications_none;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'absence_alert': return Colors.orange;
      case 'request_accepted': return Colors.green;
      case 'request_refused': return Colors.red;
      case 'info': default: return const Color(0xFF0A4F48);
    }
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // ✅ APP BAR IS HERE (GREEN COLOR)
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A4F48), // Green Theme
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Prevents back arrow in TabBar
      ),
      body: _notifications.isEmpty
          ? const Center(
        child: Text(
          "Aucune notification.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notif = _notifications[index];
          return _buildNotificationCard(notif);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    Color typeColor = _getColorForType(notif['type']);
    IconData typeIcon = _getIconForType(notif['type']);

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 22),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notif['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notif['senderName'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      notif['time'],
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    if (notif['read'] == false)
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      )
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),

            Text(
              notif['message'],
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
            ),

            if (notif['type'] == 'request_refused' && notif['reason'] != null)
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Motif: ${notif['reason']}",
                        style: TextStyle(fontSize: 13, color: Colors.red.shade900),
                      ),
                    ),
                  ],
                ),
              ),

            if (notif.containsKey('attachment') && notif['attachment'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: OutlinedButton.icon(
                  onPressed: () => _openAttachment(notif['attachment']),
                  icon: const Icon(Icons.attach_file, size: 18),
                  label: const Text("Voir la pièce jointe"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0A4F48),
                    side: const BorderSide(color: Color(0xFF0A4F48)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PDFViewerPage extends StatelessWidget {
  final String pdfPath;
  const PDFViewerPage({Key? key, required this.pdfPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Document"),
        backgroundColor: const Color(0xFF0A4F48),
        foregroundColor: Colors.white,
      ),
      body: PDFView(
        filePath: pdfPath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur PDF: $error")),
          );
        },
      ),
    );
  }
}