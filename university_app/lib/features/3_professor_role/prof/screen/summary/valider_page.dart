// المسار: lib/features/3_professor_role/prof/screen/summary/valider_page.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // 🛑 تم إضافة الاستيراد المفقود
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';
import '../../service/prof_service.dart';
import 'dart:typed_data';

class ValiderPage extends StatefulWidget {
  // --- المعرفات (IDs) ---
  final List<Map<String, dynamic>> students;
  final int profId;
  final int seanceId;
  final int moduleId;
  final int groupeId;
  final int parcoursId; // ✅ مطلوب

  // --- أسماء المكونات (Strings) ---
  final String selectedFiliere;
  final String selectedParcours;
  final String selectedModule;
  final String selectedGroupe;
  final String selectedSeance;
  final String method; // الطريقة المستخدمة (Manuel / QR Scan)

  const ValiderPage({
    super.key,
    required this.students,
    required this.profId,
    required this.seanceId,
    required this.moduleId,
    required this.groupeId,
    required this.parcoursId,
    required this.selectedFiliere,
    required this.selectedParcours,
    required this.selectedModule,
    required this.selectedGroupe,
    required this.selectedSeance,
    this.method = 'Manuel',
  });

  @override
  State<ValiderPage> createState() => _ValiderPageState();
}

class _ValiderPageState extends State<ValiderPage> {
  final ProfService _profService = ProfService();
  bool _isSubmitting = false;
  bool _submissionSuccess = false;

  @override
  void initState() {
    super.initState();
    // 💡 يمكن تشغيل الإرسال هنا إذا أردت أن يكون تلقائياً
    // _submitAttendance();
  }

  // --- دوال مساعدة لإنشاء PDF ---
  pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Center( child: pw.Text( text, style: pw.TextStyle( color: PdfColors.white, fontWeight: pw.FontWeight.bold,),),),
    );
  }

  pw.Widget _chip(String label, PdfColor bgColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration( color: bgColor, borderRadius: pw.BorderRadius.circular(6),),
      child: pw.Text( label, style: pw.TextStyle( fontWeight: pw.FontWeight.bold, color: PdfColors.white,),),
    );
  }

  // --- منطق إنشاء PDF ---
  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    // 💡 تأكد أن مسار logoFsa.png صحيح
    final logoImage = pw.MemoryImage((await rootBundle.load('assets/logoFsa.png')).buffer.asUint8List(),);

    String profNom = 'N/A';
    String profPrenom = 'N/A';
    try {
      final fullName = await _profService.fetchProfFullName(widget.profId);
      final names = fullName.split(' ');
      if (names.length > 1) {
        profPrenom = names[0];
        profNom = names.sublist(1).join(' ');
      } else {
        profNom = fullName;
      }
    } catch (e) {
      print("Error fetching prof name for PDF: $e");
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 16),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text('Liste de Présence', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, letterSpacing: 1.2, color: PdfColors.indigo900,),),
                ),
                pw.Image(logoImage, width: 120, height: 60),
              ],
            ),
          ),
          pw.Divider(),
          pw.SizedBox(height: 20),

          // Context Info
          pw.Center(
            child: pw.Wrap( alignment: pw.WrapAlignment.center, spacing: 6, runSpacing: 6,
              children: [
                _chip("Filière : ${widget.selectedFiliere}", PdfColors.blue200),
                _chip("Parcours : ${widget.selectedParcours}", PdfColors.green200),
                _chip("Module : ${widget.selectedModule}", PdfColors.orange200),
                _chip("Groupe : ${widget.selectedGroupe}", PdfColors.purple200),
                _chip("Séance : ${widget.selectedSeance}", PdfColors.red200),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Professor Name
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.RichText( text: pw.TextSpan( style: pw.TextStyle(fontSize: 14, color: PdfColors.black),
              children: [ pw.TextSpan(text: 'Présence prise par : Prof. '), pw.TextSpan( text: '$profPrenom $profNom', style: pw.TextStyle( color: PdfColors.blue900, fontWeight: pw.FontWeight.bold,),), ],
            ),
            ),
          ),
          pw.SizedBox(height: 20),

          // Table
          pw.Table(
            defaultColumnWidth: const pw.FixedColumnWidth(100),
            border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
            children: [
              // Headers
              pw.TableRow( decoration: pw.BoxDecoration(color: PdfColors.grey700),
                children: [ _headerCell("CNE"), _headerCell("Nom"), _headerCell("Prénom"), _headerCell("Statut"),],
              ),
              // Student Rows
              ...widget.students.map((student) {
                String statut; PdfColor statutColor;
                if (student['isRattrapage'] == true || student['statut'] == 'rattrapage') {
                  statut = 'Rattrapage'; statutColor = PdfColors.orange300;
                } else {
                  if (student['present'] ?? false) { statut = 'Présent'; statutColor = PdfColors.green300; }
                  else { statut = 'Absent'; statutColor = PdfColors.red300; }
                }
                return pw.TableRow( children: [
                  pw.Center(child: pw.Text(student['cne'] ?? '')),
                  pw.Center(child: pw.Text(student['nom'] ?? '')),
                  pw.Center(child: pw.Text(student['prenom'] ?? '')),
                  pw.Padding( padding: const pw.EdgeInsets.symmetric(vertical: 6),
                    child: pw.Center( child: pw.Container( padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: pw.BoxDecoration( color: statutColor, borderRadius: pw.BorderRadius.circular(4),),
                      child: pw.Column( mainAxisSize: pw.MainAxisSize.min, children: [
                        pw.Text(statut),
                        if (statut == 'Rattrapage') pw.Text( "Grp: ${student['groupeOrigine'] ?? ''}", style: pw.TextStyle( fontSize: 10, fontWeight: pw.FontWeight.bold,),),
                      ],),),),),
                ],);
              }).toList(),
            ],
          ),
        ],
      ),
    );
    return pdf.save();
  }

  // --- منطق الإرسال إلى API ---
  Future<void> _submitAttendance() async {
    setState(() => _isSubmitting = true);

    final List<Map<String, dynamic>> presenceRecords = widget.students.map((student) {
      return {
        'studentCne': student['cne'],
        'status': student['present'] == true ? 'PRESENT' : 'ABSENT',
        'isCatchUp': student['isRattrapage'] == true,
        'sessionId': widget.seanceId,
        'professorId': widget.profId,
        'attendanceMethod': widget.method.toUpperCase(),
      };
    }).toList();

    try {
      // ⚠️ يجب إنشاء هذه الدالة في prof_service.dart
      // await _profService.submitBulkAttendance(presenceRecords);

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _submissionSuccess = true;
        _isSubmitting = false;
      });
      _showSuccessDialog();

    } catch (e) {
      print("Error submitting attendance: $e");
      setState(() => _isSubmitting = false);
      _showErrorSnackbar("Échec de la soumission. Veuillez réessayer.");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Succès!'),
        content: Text('Le pointage de la séance ${widget.selectedSeance} a été soumis avec succès.'),
        actions: [
          TextButton(
            onPressed: () {
              // العودة إلى الصفحة الرئيسية أو لوحة التحكم
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // --- دالة البناء الرئيسية ---
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirmer et Valider"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. حالة التأكيد (قبل الإرسال)
              if (!_submissionSuccess && !_isSubmitting)
                ...[
                  Icon(Icons.warning_amber_rounded, size: 80, color: Colors.amber.shade700),
                  const SizedBox(height: 20),
                  Text("Veuillez confirmer l'envoi des données d'absence.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold,),
                  ),
                  const SizedBox(height: 40),

                  // زر Valider/Confirmer
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitAttendance,
                    icon: _isSubmitting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const FaIcon(FontAwesomeIcons.check, size: 20),
                    label: const Text('Confirmer et Enregistrer la Présence'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ]
              // 2. حالة النجاح (بعد الإرسال)
              else if (_submissionSuccess)
                ...[
                  Icon(Icons.check_circle, size: 80, color: Colors.green.shade700),
                  const SizedBox(height: 20),
                  Text("Présence enregistrée avec succès !",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.green.shade800, fontWeight: FontWeight.bold,),
                  ),
                  const SizedBox(height: 40),

                  // زر تحميل PDF
                  ElevatedButton.icon(
                    onPressed: () => Printing.layoutPdf(
                      name: "Presence_${widget.selectedModule}_${widget.selectedGroupe}.pdf",
                      onLayout: _generatePdf,
                    ),
                    icon: Icon(Icons.download, color: onPrimaryColor),
                    label: Text("Télécharger le PDF", style: TextStyle(color: onPrimaryColor)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // زر العودة للرئيسية
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    icon: Icon(Icons.home, color: onPrimaryColor),
                    label: Text("Retour à l'accueil", style: TextStyle(color: onPrimaryColor)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}