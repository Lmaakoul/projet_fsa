// ملف: lib/features/2_student_role/screen/justification.dart
// (النسخة المصححة - بدلنا import ديال image_picker)

import 'dart:io';
import 'package:flutter/material.dart';

// ==========================================
// 1. هادا هو السطر لي صححنا
// ==========================================
import 'package:image_picker/image_picker.dart'; // <-- كانت 'package.image_picker...'
// ==========================================

import 'accueil.dart';
import 'profile.dart'; // (هادي باش نخدمو بالبوطونة)

// (الكلاس ديال JustificationHistoryItem كيبقى كيفما هو)
class JustificationHistoryItem {
  final String moduleName;
  final String dateTime;
  final String fileName;
  final String status;
  final String? refusalReason;

  const JustificationHistoryItem({
    required this.moduleName,
    required this.dateTime,
    required this.fileName,
    required this.status,
    this.refusalReason,
  });
}

// (البيانات الوهمية كتبقى كيفما هي)
final List<JustificationHistoryItem> justificationHistory = [
  JustificationHistoryItem(
    moduleName: 'Bases de Données',
    dateTime: 'Le 15/10/2025 | 10h-12h',
    fileName: 'Certificat_Maladie_Oct.pdf',
    status: 'Approuvé',
  ),
  JustificationHistoryItem(
    moduleName: 'Programmation Mobile',
    dateTime: 'Le 14/10/2025 | 08h-10h',
    fileName: 'IMG_20251015.jpg',
    status: 'En attente',
  ),
  JustificationHistoryItem(
    moduleName: 'Réseaux',
    dateTime: 'Le 13/10/2025 | 14h-16h',
    fileName: 'Demande_Absence.pdf',
    status: 'Refusé',
    refusalReason:
    'Le document n\'est pas un certificat médical signé. Veuillez importer un certificat valide.',
  ),
];

class JustificationPage extends StatefulWidget {
  final AttendanceRecord? record;

  const JustificationPage({
    Key? key,
    this.record,
  }) : super(key: key);

  @override
  State<JustificationPage> createState() => _JustificationPageState();
}

class _JustificationPageState extends State<JustificationPage> {
  late List<JustificationHistoryItem> _historyItems;
  final ImagePicker _picker = ImagePicker(); // <-- دابا غيعرفها

  @override
  void initState() {
    super.initState();
    // كنعمرّوها من البيانات الوهمية ملي الصفحة كتبدا
    _historyItems = [
      JustificationHistoryItem( moduleName: 'Bases de Données', dateTime: 'Le 15/10/2025 | 10h-12h', fileName: 'Certificat_Maladie_Oct.pdf', status: 'Approuvé',),
      JustificationHistoryItem( moduleName: 'Programmation Mobile', dateTime: 'Le 14/10/2025 | 08h-10h', fileName: 'IMG_20251015.jpg', status: 'En attente',),
      JustificationHistoryItem( moduleName: 'Réseaux', dateTime: 'Le 13/10/2025 | 14h-16h', fileName: 'Demande_Absence.pdf', status: 'Refusé', refusalReason: 'Le document n\'est pas un certificat médical signé. Veuillez importer un certificat valide.',),
    ];
  }

  Future<File?> _pickImage(ImageSource source) async { // <-- دابا غيعرفها
    final XFile? pickedXFile = await _picker.pickImage(source: source); // <-- دابا غيعرفها
    if (pickedXFile != null) {
      return File(pickedXFile.path);
    }
    return null;
  }

  // الدالة ديال الفورم
  void _showJustificationFormDialog(BuildContext context,
      {AttendanceRecord? record, JustificationHistoryItem? oldItem}) {
    final _sujetController = TextEditingController();
    final _textController = TextEditingController();
    File? _dialogFile;

    // كنعبيو العنوان أوتوماتيكيا
    if (oldItem != null) {
      _sujetController.text = "Justification pour: ${oldItem.moduleName}";
    }
    if (record != null) {
      _sujetController.text = "Justification pour: ${record.module}";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {

            void _pickFileInternal(ImageSource source) async { // <-- دابا غيعرفها
              Navigator.of(context).pop();
              final File? pickedFile = await _pickImage(source);
              if (pickedFile != null) {
                setDialogState(() {
                  _dialogFile = pickedFile;
                });
              }
            }

            void _showPickOptionsInner() {
              showDialog(
                context: context,
                builder: (innerDialogContext) => AlertDialog(
                  title: const Text('Choisir la source'),
                  actions: [
                    TextButton(
                        child: const Text('Caméra'),
                        onPressed: () => _pickFileInternal(ImageSource.camera)), // <-- دابا غيعرفها
                    TextButton(
                        child: const Text('Galerie'),
                        onPressed: () => _pickFileInternal(ImageSource.gallery)), // <-- دابا غيعرفها
                  ],
                ),
              );
            }

            // الحالة لي كتأكتيفي البوطونة
            final bool isFormValid = _dialogFile != null &&
                _sujetController.text.isNotEmpty;

            return AlertDialog(
              title: const Text('Soumettre une Justification'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _sujetController,
                      decoration: const InputDecoration(
                        labelText: 'Sujet',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (text) {
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optionnel)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Attacher un fichier'),
                      onPressed: _showPickOptionsInner,
                    ),
                    if (_dialogFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          _dialogFile!.path.split('/').last,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Annuler'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  child: const Text('Envoyer'),
                  onPressed: isFormValid
                      ? () {
                    // (هنا فين كنبدلو الحالة للهيستوريك)
                    final newFileName = _dialogFile!.path.split('/').last;
                    if (oldItem != null) {
                      final index = _historyItems.indexWhere((item) => item == oldItem);
                      if(index != -1) {
                        final updatedItem = JustificationHistoryItem(
                          moduleName: oldItem.moduleName,
                          dateTime: oldItem.dateTime,
                          fileName: newFileName,
                          status: 'En attente',
                          refusalReason: null,
                        );
                        setState(() {
                          _historyItems[index] = updatedItem;
                        });
                      }
                    } else {
                      print('--- Nouveau fichier importé ---');
                      /* Add logic to add new item if needed */
                    }
                    Navigator.of(dialogContext).pop();
                  }
                      : null,
                ),
              ],
            );
          },
        );
      },
    );
  }

  // (الدالة ديال _showRefusalDialog كتبقى كيفما هي)
  void _showRefusalDialog(BuildContext context, JustificationHistoryItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Motif de Refus'),
          content: Text(item.refusalReason ??
              'Aucune explication fournie de la part du professeur.'),
          actions: [
            TextButton(
              child: const Text('Fermer'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Ré-importer'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showJustificationFormDialog(context, oldItem: item);
              },
            ),
          ],
        );
      },
    );
  }

  // (الكود ديال build ديال الصفحة كاملة كيبقى كيفما هو)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.record != null
            ? 'Justifier l\'absence'
            : 'Mes Justifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // معلومات الحصة
            if (widget.record != null)
              Card(
                elevation: 0,
                color: Colors.grey[100],
                margin: const EdgeInsets.only(bottom: 20.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text( 'Vous justifiez l\'absence pour:', style: Theme.of(context).textTheme.bodySmall,),
                      const SizedBox(height: 5),
                      Text( widget.record!.module, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold,),),
                      const SizedBox(height: 2),
                      Text('${widget.record!.prof} | ${widget.record!.time}', style: Theme.of(context).textTheme.bodyMedium,),
                    ],
                  ),
                ),
              ),

            // البوطونة ديال "Importer"
            ProfileMenuItem(
              icon: Icons.upload_file_outlined,
              text: 'Importer une Justification',
              onTap: () {
                _showJustificationFormDialog(context, record: widget.record);
              },
            ),

            const Divider(height: 40),

            Text(
              'Historique des Justifications',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),

            // الهيستوريك
            Expanded(
              child: ListView.builder(
                itemCount: _historyItems.length,
                itemBuilder: (context, index) {
                  final item = _historyItems[index];
                  IconData statusIcon;
                  Color statusColor;
                  switch (item.status) {
                    case 'Approuvé':
                      statusIcon = Icons.check_circle;
                      statusColor = Colors.green;
                      break;
                    case 'Refusé':
                      statusIcon = Icons.cancel;
                      statusColor = Colors.red;
                      break;
                    default:
                      statusIcon = Icons.hourglass_top;
                      statusColor = Colors.orange;
                  }

                  return ListTile(
                    leading: Icon(statusIcon, color: statusColor),
                    title: Text(
                      item.moduleName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.dateTime,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                        Text(item.fileName),
                        Text(
                          'Status: ${item.status}',
                          style: TextStyle(color: statusColor),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: item.status == 'Refusé'
                        ? Icon(Icons.info_outline, color: statusColor)
                        : null,
                    onTap: () {
                      if (item.status == 'Refusé') {
                        _showRefusalDialog(context, item);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// (الكود ديال البوطونة ProfileMenuItem كيبقى كيفما هو)
// ...