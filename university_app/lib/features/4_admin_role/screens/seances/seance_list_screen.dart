import 'package:flutter/material.dart';
import 'package:university_app/core/models/seance.dart';
import 'package:university_app/core/services/seance_service.dart';
import 'package:university_app/core/services/auth_service.dart';
import 'package:intl/intl.dart';

class SeanceListScreen extends StatefulWidget {
  final String moduleId;
  final String groupId;
  final String moduleName;
  final String groupName;

  const SeanceListScreen({
    super.key,
    required this.moduleId,
    required this.groupId,
    required this.moduleName,
    required this.groupName,
  });

  @override
  State<SeanceListScreen> createState() => _SeanceListScreenState();
}

class _SeanceListScreenState extends State<SeanceListScreen> {
  final SeanceService _seanceService = SeanceService();
  final AuthService _authService = AuthService();

  late Future<List<Seance>> _seancesFuture;

  @override
  void initState() {
    super.initState();
    _loadSeances();
  }

  void _loadSeances() async {
    final token = await _authService.getToken();
    if (token != null) {
      setState(() {
        _seancesFuture = _seanceService.getSeances(
          token: token,
          moduleId: widget.moduleId,
          groupId: widget.groupId,
        );
      });
    }
  }

  // ✅ دالة جديدة لتحويل الدقائق إلى ساعات ودقائق
  String _formatDuration(int totalMinutes) {
    int hours = totalMinutes ~/ 60; // حساب الساعات
    int minutes = totalMinutes % 60; // حساب الدقائق المتبقية

    if (hours > 0 && minutes > 0) {
      return "${hours}h ${minutes}min"; // مثال: 1h 30min
    } else if (hours > 0) {
      return "${hours}h"; // مثال: 3h
    } else {
      return "${minutes}min"; // مثال: 45min
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // لون خلفية هادئ
      appBar: AppBar(
        title: Text("${widget.moduleName} - ${widget.groupName}"),
        backgroundColor: const Color(0xFF190B60), // اللون الأزرق الاحترافي
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Seance>>(
        future: _seancesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune séance trouvée."));
          }

          final seances = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: seances.length,
            itemBuilder: (context, index) {
              final seance = seances[index];
              final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(seance.schedule);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: _getColorByType(seance.type).withOpacity(0.1),
                    child: Text(
                        seance.type.substring(0, 1),
                        style: TextStyle(
                            color: _getColorByType(seance.type),
                            fontWeight: FontWeight.bold
                        )
                    ),
                  ),
                  title: Text(
                      seance.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // التاريخ
                      Row(children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(dateStr, style: TextStyle(color: Colors.grey[800]))
                      ]),
                      const SizedBox(height: 4),

                      // ✅ الوقت (تم تعديله هنا)
                      Row(children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                            _formatDuration(seance.duration), // استدعاء الدالة هنا
                            style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500)
                        )
                      ]),

                      const SizedBox(height: 4),
                      // القاعة
                      Row(children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(seance.locationName ?? "Salle inconnue", style: TextStyle(color: Colors.grey[800]))
                      ]),
                    ],
                  ),
                  // ✅ شرح الأيقونة الجانبية
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      seance.isCompleted
                          ? const Icon(Icons.check_circle, color: Colors.green) // مكتملة
                          : const Icon(Icons.pending, color: Colors.orange),    // قيد الانتظار (النقاط الثلاث)
                      const SizedBox(height: 4),
                      Text(
                        seance.isCompleted ? "Fait" : "En cours",
                        style: TextStyle(
                            fontSize: 10,
                            color: seance.isCompleted ? Colors.green : Colors.orange
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getColorByType(String type) {
    switch (type.toUpperCase()) { // أضفت UpperCase لتجنب مشاكل الأحرف الصغيرة
      case "LECTURE": return Colors.blue;
      case "COURS": return Colors.blue;
      case "TP": return Colors.purple;
      case "TD": return Colors.orange;
      default: return const Color(0xFF190B60);
    }
  }
}