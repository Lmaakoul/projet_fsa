import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'dart:typed_data'; // من أجل PDF

// ✅ مكتبات الطباعة والـ PDF
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ✅ تأكد من استيراد المودل الصحيح
import '../../model/etudiant.dart';
// import '../../service/prof_service.dart'; // إذا كنت تستخدم السيرفر

class ManualAttendancePage extends StatefulWidget {
  final int profId;
  final int seanceId;
  final int groupeId;
  final int moduleId;
  final int parcoursId;

  final String? moduleName;
  final String? groupeCode;
  final String? seanceLabel;
  final String? selectedFiliere;

  const ManualAttendancePage({
    super.key,
    required this.profId,
    required this.seanceId,
    required this.groupeId,
    required this.moduleId,
    required this.parcoursId,
    this.moduleName,
    this.groupeCode,
    this.seanceLabel,
    this.selectedFiliere,
  });

  @override
  _ManualAttendancePageState createState() => _ManualAttendancePageState();
}

class _ManualAttendancePageState extends State<ManualAttendancePage> {
  List<Etudiant> students = [];
  List<Etudiant> filteredStudents = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final Map<int, bool> presenceStatus = {};

  // بيانات وهمية للتجربة (استبدلها بالـ API)
  final List<Etudiant> _staticStudents = [
    Etudiant(cne: 'P123456', nom: 'ALAMI', prenom: 'Ahmed', isRattrapage: false, groupe: 'G1', groupeOrigine: 'G1'),
    Etudiant(cne: 'P654321', nom: 'BENNANI', prenom: 'Fatima', isRattrapage: false, groupe: 'G1', groupeOrigine: 'G1'),
    Etudiant(cne: 'P987654', nom: 'CHERKAOUI', prenom: 'Youssef', isRattrapage: false, groupe: 'G1', groupeOrigine: 'G1'),
    Etudiant(cne: 'P112233', nom: 'DAOUDI', prenom: 'Amina', isRattrapage: false, groupe: 'G1', groupeOrigine: 'G1'),
    Etudiant(cne: 'P445566', nom: 'EL IDRISSI', prenom: 'Omar', isRattrapage: false, groupe: 'G1', groupeOrigine: 'G1'),
    Etudiant(cne: 'P778899', nom: 'FILALI', prenom: 'Salma', isRattrapage: false, groupe: 'G1', groupeOrigine: 'G1'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _searchController.addListener(() {
      _filterEtudiants(_searchController.text);
    });
  }

  // --- دوال التحضير ---
  List<Map<String, dynamic>> get studentsWithStatus {
    return filteredStudents.asMap().entries.map((entry) {
      int index = entry.key;
      Etudiant student = entry.value;
      final bool isPresent = presenceStatus[index] ?? true;

      return {
        'cne': student.cne,
        'nom': student.nom,
        'prenom': student.prenom,
        'present': isPresent,
        'isRattrapage': student.isRattrapage,
        'groupe': student.groupe,
      };
    }).toList();
  }

  Future<void> _fetchStudents() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500)); // محاكاة الشبكة
    if (!mounted) return;
    setState(() {
      students = List.from(_staticStudents);
      filteredStudents = List.from(students);
      isLoading = false;
      for (int i = 0; i < filteredStudents.length; i++) {
        presenceStatus[i] = true; // الافتراضي: حاضر
      }
    });
  }

  void _filterEtudiants(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      filteredStudents = students.where((student) {
        return student.nom.toLowerCase().contains(lowerCaseQuery) ||
            student.prenom.toLowerCase().contains(lowerCaseQuery) ||
            student.cne.toLowerCase().contains(lowerCaseQuery);
      }).toList();

      // إعادة تعيين الحالة للقائمة المصفاة (لغرض العرض البسيط هنا)
      // في تطبيق حقيقي يجب ربط الحالة بالـ ID وليس الـ index
      presenceStatus.clear();
      for (int i = 0; i < filteredStudents.length; i++) {
        presenceStatus[i] = true;
      }
    });
  }

  void _addTemporaryStudent(String cne, String nom, String prenom) {
    setState(() {
      filteredStudents.add(Etudiant(
          cne: cne, nom: nom, prenom: prenom, isRattrapage: true,
          groupe: widget.groupeCode ?? 'N/A', groupeOrigine: 'Exterieur'
      ));
      presenceStatus[filteredStudents.length - 1] = true;
    });
  }

  void _showAddStudentDialog(BuildContext context) {
    // ... (نفس كود الديالوج السابق الخاص بك)
    // للاختصار سأضع الوظيفة الأساسية
    _addTemporaryStudent("Temp123", "Nouveau", "Etudiant");
  }

  double _calculatePresencePercentage() {
    if (filteredStudents.isEmpty) return 0.0;
    int presentCount = presenceStatus.values.where((v) => v == true).length;
    return (presentCount / filteredStudents.length) * 100;
  }

  // ---------------------------------------------------------------------------
  // 🖨️ دالة توليد وطباعة PDF
  // ---------------------------------------------------------------------------
  Future<void> _generateAndPrintPdf() async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoExtraLight();

    // إعداد البيانات
    final dateStr = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    final presencePercent = _calculatePresencePercentage().toStringAsFixed(1);
    final totalStudents = filteredStudents.length;
    final presentCount = presenceStatus.values.where((v) => v == true).length;
    final absentCount = totalStudents - presentCount;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // 1. رأس الصفحة (Header)
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Université Ibn Zohr - FSA", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                      pw.Text("Feuille de présence", style: const pw.TextStyle(fontSize: 14)),
                    ],
                  ),
                  pw.Text("Date: $dateStr", style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // 2. معلومات الحصة (Info Box)
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(border: pw.Border.all(), borderRadius: pw.BorderRadius.circular(5)),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text("Module: ${widget.moduleName ?? '-'}"),
                    pw.Text("Groupe: ${widget.groupeCode ?? '-'}"),
                  ]),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text("Séance: ${widget.seanceLabel ?? '-'}"),
                    pw.Text("Professeur ID: ${widget.profId}"),
                  ]),
                ],
              ),
            ),

            pw.SizedBox(height: 10),

            // 3. الإحصائيات (Stats)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                pw.Text("Présents: $presentCount", style: const pw.TextStyle(color: PdfColors.green)),
                pw.Text("Absents: $absentCount", style: const pw.TextStyle(color: PdfColors.red)),
                pw.Text("Taux: $presencePercent%", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),

            pw.SizedBox(height: 20),

            // 4. جدول الحضور (Table)
            pw.Table.fromTextArray(
              headers: ['N°', 'CNE', 'Nom', 'Prénom', 'Statut', 'Signature'],
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FixedColumnWidth(80),
                4: const pw.FixedColumnWidth(60),
                5: const pw.FixedColumnWidth(80),
              },
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF190B60)),
              data: List<List<dynamic>>.generate(filteredStudents.length, (index) {
                final student = filteredStudents[index];
                final isPresent = presenceStatus[index] ?? false;
                final statusText = isPresent ? "PRESENT" : "ABSENT";
                final isRattrapage = student.isRattrapage ? " (R)" : "";

                return [
                  (index + 1).toString(),
                  student.cne,
                  student.nom,
                  student.prenom,
                  statusText + isRattrapage,
                  "", // مساحة للتوقيع
                ];
              }),
            ),
          ];
        },
      ),
    );

    // فتح نافذة الطباعة / المشاركة
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Presence_${widget.moduleName}_${widget.groupeCode}_$dateStr',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion Manuelle"),
        backgroundColor: const Color(0xFF190B60),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // ... (نفس تصميم الإحصائيات والبحث السابق)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Module: ${widget.moduleName}", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Groupe: ${widget.groupeCode}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // قائمة الطلاب
          Expanded(
            child: ListView.separated(
              itemCount: filteredStudents.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                final isPresent = presenceStatus[index] ?? false;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPresent ? Colors.green.shade100 : Colors.red.shade100,
                    child: Icon(isPresent ? Icons.check : Icons.close, color: isPresent ? Colors.green : Colors.red),
                  ),
                  title: Text("${student.nom} ${student.prenom}"),
                  subtitle: Text(student.cne + (student.isRattrapage ? " (Rattrapage)" : "")),
                  trailing: Switch(
                    value: isPresent,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      setState(() => presenceStatus[index] = val);
                    },
                  ),
                );
              },
            ),
          ),

          // زر التحقق والطباعة
          Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF190B60),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                // 1. هنا يمكنك إرسال البيانات للسيرفر أولاً
                // await _saveAttendanceToServer();

                // 2. ثم توليد وطباعة الـ PDF
                await _generateAndPrintPdf();
              },
              icon: const Icon(Icons.print),
              label: const Text("Valider & Imprimer PDF", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}