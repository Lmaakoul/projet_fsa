import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:university_app/core/models/seance.dart';
import 'package:university_app/core/services/seance_service.dart';
import 'package:university_app/core/services/auth_service.dart';

// ✅ تأكد أن هذا المسار يشير إلى الملف الصحيح
import '../scan/scan_choice_page.dart';

class ProfHome extends StatefulWidget {
  final int profId;
  const ProfHome({super.key, required this.profId});

  @override
  _ProfHomeState createState() => _ProfHomeState();
}

class _ProfHomeState extends State<ProfHome> {
  final SeanceService _seanceService = SeanceService();
  final AuthService _authService = AuthService();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  List<Seance> _allSeances = [];
  bool _isLoading = true;
  bool _isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null).then((_) {
      if (mounted) setState(() => _isLocaleInitialized = true);
    });
    _loadSeances();
  }

  void _loadSeances() async {
    final token = await _authService.getToken();
    if (token != null) {
      try {
        final seances = await _seanceService.getSeances(
          token: token,
          moduleId: "",
          groupId: "",
        );
        if (mounted) {
          setState(() {
            _allSeances = seances;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          // طباعة الخطأ لنعرف السبب إذا حدثت مشكلة
          print("🚨 Erreur de chargement: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  List<Seance> _getEventsForDay(DateTime day) {
    return _allSeances.where((s) => isSameDay(s.schedule, day)).toList();
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _formatDuration(int totalMinutes) {
    if (totalMinutes == 0) return "0min";
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    if (hours > 0 && minutes > 0) return "${hours}h ${minutes}min";
    if (hours > 0) return "${hours}h";
    return "${minutes}min";
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocaleInitialized || _isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final dailySeances = _getEventsForDay(_selectedDay ?? DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildTableCalendar(), // التقويم مع النقاط
          const SizedBox(height: 10),
          Expanded(
            child: dailySeances.isEmpty
                ? _buildEmptyState("Pas de cours ce jour-là 🎉")
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: dailySeances.length,
              itemBuilder: (context, index) {
                return _buildSeanceCard(dailySeances[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCalendar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: TableCalendar<Seance>(
        locale: 'fr_FR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        eventLoader: _getEventsForDay, // هذا السطر هو الذي يظهر النقاط
        selectedDayPredicate: (day) => isSameDay(_selectedDay ?? DateTime.now(), day),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay ?? DateTime.now(), selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) setState(() => _calendarFormat = format);
        },
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF190B60)),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(color: const Color(0xFF190B60).withOpacity(0.4), shape: BoxShape.circle),
          selectedDecoration: const BoxDecoration(color: Color(0xFF190B60), shape: BoxShape.circle),
        ),
        // تخصيص النقاط
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return null;
            final seances = events.cast<Seance>();
            bool allCompleted = seances.every((s) => s.isCompleted);
            return Positioned(
              bottom: 1,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: allCompleted ? Colors.green : Colors.orange,
                ),
                width: 7.0,
                height: 7.0,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSeanceCard(Seance seance) {
    final timeStr = DateFormat('HH:mm').format(seance.schedule);
    final endTime = seance.schedule.add(Duration(minutes: seance.duration));
    final endTimeStr = DateFormat('HH:mm').format(endTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                // ✅ تأكد أن اسم الكلاس هنا يطابق ملف scan_choice_page.dart
                // غالباً هو: PresenceMethodScreen
                builder: (context) => PresenceMethodScreen(
                  sessionData: {
                    "module": seance.name,
                    "groupe": seance.groupName,
                    "seance": "${seance.name} ($timeStr)",
                    "profId": widget.profId,
                    "seanceId": int.tryParse(seance.id) ?? 0,
                    // استخدمنا ?? "" لتجنب خطأ null
                    "moduleId": 0,
                    "groupeId": 0,
                    "filiereName": "",
                  },
                ),
              ),
            );
          },
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 85,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                    border: Border(right: BorderSide(color: Colors.grey.shade100)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF190B60))),
                      Text(endTimeStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getColorByType(seance.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formatDuration(seance.duration),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getColorByType(seance.type)),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(seance.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
                            _buildStatusIcon(seance.isCompleted),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(children: [
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          // استخدام قيمة افتراضية لتجنب خطأ null
                          Text(seance.locationName ?? "Salle ?", style: TextStyle(color: Colors.grey[800], fontSize: 13)),
                        ]),
                        const SizedBox(height: 4),
                        Text(seance.groupName, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(isCompleted ? "Fait" : "À venir", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isCompleted ? Colors.green : Colors.orange)),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.event_busy, size: 70, color: Colors.grey[300]), const SizedBox(height: 16), Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w500))]));
  }

  Color _getColorByType(String type) {
    switch (type.toUpperCase()) {
      case "COURS": return Colors.blue;
      case "TP": return Colors.purple;
      case "TD": return Colors.orange;
      default: return const Color(0xFF190B60);
    }
  }
}