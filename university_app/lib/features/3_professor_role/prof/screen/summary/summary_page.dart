// المسار: lib/features/3_professor_role/prof/screen/summary/summary_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'valider_page.dart';
// import '../../model/etudiant.dart'; // إذا كنت تستخدم Etudiant

class SummaryPage extends StatefulWidget {
  // --- المعرفات (IDs) ---
  final int profId;
  final int seanceId;
  final int moduleId;
  final int groupeId;
  final int parcoursId;

  // --- البيانات ---
  final List<Map<String, dynamic>> attendanceData;
  final String method;

  // --- أسماء المكونات (Strings) ---
  final String selectedFiliere;
  final String selectedParcours;
  final String selectedModule;
  final String selectedGroupe;
  final String selectedSeance;

  final String? moduleName;
  final String? groupeCode;
  final String? seanceLabel;


  const SummaryPage({
    super.key,
    required this.profId,
    required this.seanceId,
    required this.moduleId,
    required this.groupeId,
    required this.parcoursId,
    required this.attendanceData,
    required this.method,

    required this.selectedFiliere,
    required this.selectedParcours,
    required this.selectedModule,
    required this.selectedGroupe,
    required this.selectedSeance,
    this.moduleName,
    this.groupeCode,
    this.seanceLabel,
  });

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {

  late List<Map<String, dynamic>> studentsWithStatus;

  @override
  void initState() {
    super.initState();
    // 🛑 يجب التأكد من أن studentsWithStatus لديها قيمة ابتدائية غير فارغة
    studentsWithStatus = widget.attendanceData;
  }

  // --- دوال مساعدة لحساب الإحصائيات (Getters) ---
  int get _totalStudents => studentsWithStatus.length;
  int get _presentCount => studentsWithStatus.where((s) => s['present'] == true).length;
  int get _absentCount => _totalStudents - _presentCount;
  int get _rattrapageCount => studentsWithStatus.where((s) => s['isRattrapage'] == true || s['statut'] == 'rattrapage').length;

  double _calculatePresencePercentage() {
    final regularStudents = studentsWithStatus.where((s) => s['statut'] != 'rattrapage').toList();
    if (regularStudents.isEmpty) return 0.0;
    int presentCount = regularStudents.where((s) => s['present'] == true).length;
    return (presentCount / regularStudents.length) * 100;
  }
  double _calculateAbsencePercentage() {
    final regularStudents = studentsWithStatus.where((s) => s['statut'] != 'rattrapage').toList();
    if (regularStudents.isEmpty) return 0.0;
    int absentCount = regularStudents.where((s) => s['present'] != true).length;
    return (absentCount / regularStudents.length) * 100;
  }


  // --- الدوال المساعدة للـ UI (يجب أن تكون داخل الكلاس) ---

  // 🛑 دالة infoValue المصححة (تستخدم toString() وتحويل القيمة)
  Widget _infoValue(String? value) {
    // 💡 FIX: استخدام toString() لضمان أن القيمة نصية
    final displayValue = value?.toString() ?? '—';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        displayValue,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).textTheme.bodySmall?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // 🛑 دالة StatCard (موجودة الآن داخل الكلاس)
  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // دالة تغيير الحالة (لتعديل الحالة قبل الإرسال)
  void _changeStatus(Map<String, dynamic> student) {
    showDialog( context: context, builder: (context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text( "Changer le statut de ${student['prenom']} ${student['nom']}", style: Theme.of(context).textTheme.titleLarge ),
        content: SingleChildScrollView( child: Column( mainAxisSize: MainAxisSize.min, children: [
          _statusChip("Présent", true, student), const SizedBox(height: 8),
          _statusChip("Absent", false, student),
        ],),),
      );
    });
  }

  // دالة بناء Chip
  Widget _statusChip(String label, bool value, Map<String, dynamic> student) {
    return GestureDetector( onTap: () {
      setState(() {
        // 💡 تحديث حالة الطالب في القائمة
        final index = studentsWithStatus.indexWhere((s) => s['cne'] == student['cne']);
        if(index != -1) {
          studentsWithStatus[index]['present'] = value;
        }
      });
      Navigator.pop(context);
    },
      child: Chip( label: Text( label ),
        backgroundColor: value ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
        labelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }


  // --- منطق التنقل إلى صفحة التأكيد النهائية ---
  void _navigateToValidation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ValiderPage(
          students: studentsWithStatus, // تمرير البيانات النهائية
          profId: widget.profId,
          seanceId: widget.seanceId,
          moduleId: widget.moduleId,
          groupeId: widget.groupeId,
          parcoursId: widget.parcoursId, // تمرير الـ ID
          method: widget.method,

          selectedFiliere: widget.selectedFiliere,
          selectedParcours: widget.selectedParcours,
          selectedModule: widget.selectedModule,
          selectedGroupe: widget.selectedGroupe,
          selectedSeance: widget.selectedSeance,
        ),
      ),
    );
  }

  // 🛑 دالة بناء الجدول (يجب أن تكون داخل الكلاس)
  Widget _buildAttendanceTable(Color primaryColor) {
    return DataTable(
      columnSpacing: 20,
      columns: [
        DataColumn(label: Text('CNE', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor))),
        DataColumn(label: Text('Nom & Prénom', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor))),
        DataColumn(label: Text('Statut', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor))),
      ],
      rows: studentsWithStatus.map((student) {
        final isPresent = student['present'] == true;
        final isRattrapage = student['isRattrapage'] == true;
        final statusText = isRattrapage ? 'Rattrapage' : (isPresent ? 'Présent' : 'Absent');
        final statusColor = isRattrapage ? Colors.orange.shade700 : (isPresent ? Colors.green : Colors.red);

        return DataRow(
          color: MaterialStateProperty.resolveWith((states) => isRattrapage ? Colors.orange.withOpacity(0.1) : Colors.transparent),
          cells: [
            DataCell(Text(student['cne']?.toString() ?? 'N/A')),
            DataCell(Text('${student['nom'] ?? 'N/A'} ${student['prenom'] ?? ''}')),
            DataCell(
              Row(
                children: [
                  Icon(isPresent ? Icons.check_circle : Icons.cancel, color: statusColor, size: 18),
                  const SizedBox(width: 5),
                  Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }


  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: const Text("Récapitulatif"),
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 25),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          // 1. ملخص الجلسة
          _buildSessionHeader(primaryColor), // 💡 يتم استخدامها الآن
          const SizedBox(height: 20),

          // 2. بطاقات الإحصائيات
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                _buildStatCard(_totalStudents.toString(), 'Total', Colors.grey.shade700), // 💡 يتم استخدامها الآن
                const SizedBox(width: 5),
                _buildStatCard("${_calculatePresencePercentage().toStringAsFixed(1)}%", 'Présents', Colors.green),
                const SizedBox(width: 5),
                _buildStatCard("${_calculateAbsencePercentage().toStringAsFixed(1)}%", 'Absents', Colors.red),
                const SizedBox(width: 5),
                _buildStatCard(_rattrapageCount.toString(), 'Rattrapage', Colors.orange),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. جدول الملخص (الطلاب)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: _buildAttendanceTable(primaryColor), // 💡 يتم استخدامها الآن
              ),
            ),
          ),

          // 4. زر التأكيد النهائي
          _buildConfirmationButton(context, primaryColor),
        ],
      ),
    );
  }

  // دالة بناء الـ Header (يجب أن تكون داخل الكلاس)
  Widget _buildSessionHeader(Color primaryColor) {
    // ... (كودها يبقى كما هو)
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      color: primaryColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Méthode : ${widget.method}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          Text('Module : ${widget.selectedModule}', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Groupe : ${widget.selectedGroupe}', style: TextStyle(color: Colors.grey[700])),
          Text('Séance : ${widget.selectedSeance}', style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  // دالة بناء زر التأكيد (يجب أن تكون داخل الكلاس)
  Widget _buildConfirmationButton(BuildContext context, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: _totalStudents == 0 ? null : _navigateToValidation,
        icon: const FaIcon(FontAwesomeIcons.circleCheck, size: 20),
        label: const Text('Confirmer & Envoyer'),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}