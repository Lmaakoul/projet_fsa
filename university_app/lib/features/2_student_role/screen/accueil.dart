import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:university_app/core/models/seance.dart';
import 'package:university_app/core/services/seance_service.dart';
import 'package:university_app/core/services/auth_service.dart';

// ✅ استيراد الصفحات (تأكد أن الملفات موجودة)
import 'package:university_app/features/2_student_role/screen/student_notifications_page.dart';
import 'package:university_app/features/2_student_role/screen/profile.dart';

// ✅ استيراد صفحة الاختيار الجديدة (بدلاً من كود QR مباشرة)
import 'package:university_app/features/2_student_role/screen/student_code_choice.dart';

class StudentHomeScreen extends StatefulWidget {
  final int etudiantId;
  const StudentHomeScreen({super.key, required this.etudiantId});

  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // ✅ تعريف الصفحات
    _pages = [
      _StudentCalendarPage(etudiantId: widget.etudiantId), // 0: الجدول
      const StudentNotificationsPage(),                    // 1: الإشعارات

      // ✅✅✅ هنا التغيير: نفتح صفحة الاختيار أولاً ✅✅✅
      StudentCodeChoicePage(etudiantId: widget.etudiantId),

      ProfilePage(etudiantId: widget.etudiantId),          // 3: البروفايل
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // جسم الصفحة يتغير حسب الاختيار
      body: _pages[_currentIndex],

      // شريط التنقل السفلي
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF190B60),
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            // 1. Séances
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded),
              activeIcon: Icon(Icons.calendar_month_rounded),
              label: "Séances",
            ),

            // 2. Notifs
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none_rounded),
              activeIcon: Icon(Icons.notifications_rounded),
              label: "Notifs",
            ),

            // 3. QR Code (الأيقونة تبقى كما هي)
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_2_rounded),
              label: "QR Code",
            ),

            // 4. Profil
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 📅 ودجت صفحة الجدول (Calendar Page)
// =============================================================================
class _StudentCalendarPage extends StatefulWidget {
  final int etudiantId;
  const _StudentCalendarPage({required this.etudiantId});

  @override
  State<_StudentCalendarPage> createState() => _StudentCalendarPageState();
}

class _StudentCalendarPageState extends State<_StudentCalendarPage> {
  final SeanceService _seanceService = SeanceService();
  final AuthService _authService = AuthService();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  List<Seance> _allSeances = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _loadStudentSeances();
  }

  void _loadStudentSeances() async {
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
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  List<Seance> _getEventsForDay(DateTime day) {
    return _allSeances.where((s) => isSameDay(s.schedule, day)).toList();
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
    final dailySeances = _getEventsForDay(_selectedDay ?? DateTime.now());

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.only(top: 50, bottom: 15, left: 20, right: 20),
          decoration: const BoxDecoration(
            color: Color(0xFF190B60),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Bonjour,", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 4),
                  Text("Étudiant", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.school, color: Colors.white),
              )
            ],
          ),
        ),

        // Calendar
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: TableCalendar<Seance>(
            locale: 'fr_FR',
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
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
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF190B60)),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: const Color(0xFF190B60).withOpacity(0.3), shape: BoxShape.circle),
              selectedDecoration: const BoxDecoration(color: Color(0xFF190B60), shape: BoxShape.circle),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;
                return Positioned(
                  bottom: 1,
                  child: Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange),
                    width: 6.0, height: 6.0,
                  ),
                );
              },
            ),
          ),
        ),

        // List Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text("Séances du jour", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              const Spacer(),
              Text("${dailySeances.length} Cours", style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : dailySeances.isEmpty
              ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 50, color: Colors.grey[300]),
              const SizedBox(height: 10),
              Text("Aucun cours aujourd'hui", style: TextStyle(color: Colors.grey[400])),
            ],
          ))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: dailySeances.length,
            itemBuilder: (context, index) {
              return _buildSeanceCard(dailySeances[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeanceCard(Seance seance) {
    final timeStr = DateFormat('HH:mm').format(seance.schedule);
    final endTime = seance.schedule.add(Duration(minutes: seance.duration));
    final endTimeStr = DateFormat('HH:mm').format(endTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 75,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                border: Border(right: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF190B60))),
                  Text(endTimeStr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(_formatDuration(seance.duration), style: const TextStyle(fontSize: 9, color: Colors.blue, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(seance.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(seance.professorName ?? "Professeur", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(seance.locationName ?? "Salle ?", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Text("À venir", style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}