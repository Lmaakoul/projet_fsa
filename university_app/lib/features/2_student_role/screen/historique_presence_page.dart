// ملف: historique_presence_page.dart
// (النسخة المصححة - زدنا import لي كان ناقص)

// ==========================================
// 1. هادا هو السطر لي كان ناقص وكيسبب المشكل
// ==========================================
import 'package:flutter/material.dart';

class HistoriquePresencePage extends StatelessWidget {
  const HistoriquePresencePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // الخلفية البيضاء
      appBar: AppBar(
        title: const Text('Historique de Présence'),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        itemCount: 15, // بيانات وهمية
        itemBuilder: (context, index) {

          final bool isPresent = index % 3 == 0;
          final String statusText = isPresent ? 'Présent' : 'Absent';
          final Color statusColor = isPresent ? Colors.green.shade600 : Colors.red.shade600;
          final IconData statusIcon =
          isPresent ? Icons.check_circle_outline : Icons.cancel_outlined;

          final List<String> times = ['14h-16h', '10h-12h', '08h-10h'];
          final String sessionTime = times[index % times.length];

          // غلفنا ListTile بـ Card
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 12.0), // <-- هادي هي لي كدير "more space between"
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              leading: Icon(statusIcon, color: statusColor, size: 30), // <-- دابا غيعرفها
              title: const Text(
                'Module de Programmation Mobile',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text( // <-- دابا غيعرفها
                'Le ${28 - index}/10/2025 | $sessionTime - $statusText',
              ),
            ),
          );
        },
      ),
    );
  }
}