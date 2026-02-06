import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// يمكنك نقل هذا المودل لملف منفصل لاحقاً إذا أردت
class AttendanceRecord {
  final String module;
  final DateTime date;
  final String status; // "Présent" or "Absent"
  final String type;   // "TP", "TD", "Cours"

  AttendanceRecord({
    required this.module,
    required this.date,
    required this.status,
    required this.type,
  });
}

class StudentStatsPage extends StatefulWidget {
  const StudentStatsPage({super.key});

  @override
  State<StudentStatsPage> createState() => _StudentStatsPageState();
}

class _StudentStatsPageState extends State<StudentStatsPage> {
  // ✅ 1. القائمة فارغة الآن (لا توجد بيانات وهمية)
  List<AttendanceRecord> attendanceRecords = [];

  // ✅ 2. متغير للتحميل
  bool _isLoading = true;
  String? selectedModule;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  // ✅ 3. دالة لجلب البيانات (حالياً تعيد قائمة فارغة)
  Future<void> _fetchStats() async {
    // محاكاة الاتصال بالسيرفر
    await Future.delayed(const Duration(milliseconds: 500));

    // ⬇️⬇️⬇️ هنا ستضع كود الـ API الخاص بك لاحقاً ⬇️⬇️⬇️
    // final data = await _statsService.getStats(studentId);

    if (mounted) {
      setState(() {
        // حالياً نتركها فارغة لأننا حذفنا البيانات الوهمية
        attendanceRecords = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // المنطق الحسابي (سيعمل حتى لو القائمة فارغة)
    List<AttendanceRecord> filteredList = selectedModule == null
        ? attendanceRecords
        : attendanceRecords.where((r) => r.module == selectedModule).toList();

    int presentCount = filteredList.where((r) => r.status == 'Présent').length;
    int absentCount = filteredList.where((r) => r.status == 'Absent').length;
    int total = filteredList.length;
    double presenceRate = total == 0 ? 0.0 : (presentCount / total);

    final modules = attendanceRecords.map((r) => r.module).toSet().toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mes Statistiques",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF190B60)),
            ),
            const SizedBox(height: 20),

            // إذا كانت القائمة فارغة، نخفي الفلتر
            if (modules.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                margin: const EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedModule,
                    hint: const Text("Filtrer par module"),
                    isExpanded: true,
                    icon: const Icon(Icons.filter_list, color: Color(0xFF190B60)),
                    items: [
                      const DropdownMenuItem(value: null, child: Text("Tous les modules")),
                      ...modules.map((m) => DropdownMenuItem(value: m, child: Text(m))),
                    ],
                    onChanged: (val) {
                      setState(() => selectedModule = val);
                    },
                  ),
                ),
              ),

            // بطاقات الملخص
            Row(
              children: [
                Expanded(child: _buildStatCard("Présences", presentCount.toString(), Colors.green, Icons.check_circle)),
                const SizedBox(width: 15),
                Expanded(child: _buildStatCard("Absences", absentCount.toString(), Colors.red, Icons.cancel)),
              ],
            ),
            const SizedBox(height: 20),

            // بطاقة النسبة المئوية
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF190B60),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: const Color(0xFF190B60).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: CircularProgressIndicator(
                      value: presenceRate,
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                      strokeWidth: 8,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Taux de présence", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      Text(
                          "${(presenceRate * 100).toStringAsFixed(1)}%",
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text("Historique récent", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 15),

            // القائمة (تظهر رسالة إذا كانت فارغة)
            filteredList.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    Icon(Icons.bar_chart_rounded, size: 50, color: Colors.grey[300]),
                    const SizedBox(height: 10),
                    Text("Aucune donnée disponible", style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final record = filteredList[index];
                return _buildRecordTile(record);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRecordTile(AttendanceRecord record) {
    final isPresent = record.status == "Présent";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: isPresent ? Colors.green : Colors.red, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(record.module, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                    child: Text(record.type, style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMM yyyy').format(record.date),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isPresent ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              record.status,
              style: TextStyle(
                color: isPresent ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}