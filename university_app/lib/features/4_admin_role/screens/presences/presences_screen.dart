// ملف: lib/features/4_admin_role/screens/presences/presences_screen.dart
// (النسخة النهائية مع استقبال الـ token)

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// استيراد الشاشات الأخرى
import 'add_presence_screen.dart';
import 'edit_presence_screen.dart';
import 'presence_filter_sheet.dart';
// import 'presence_details_screen.dart';

class PresencesScreen extends StatefulWidget {
  // 🛑 1. إضافة الـ token كـ خاصية مطلوبة
  final String token;
  final String selectedDepartement;
  final String selectedNiveau;
  final String selectedFiliere;
  final String selectedGroupe;

  const PresencesScreen({
    super.key,
    required this.token, // ✅ تم إضافة الـ token هنا
    required this.selectedDepartement,
    required this.selectedNiveau,
    required this.selectedFiliere,
    required this.selectedGroupe,
  });

  @override
  State<PresencesScreen> createState() => _PresencesScreenState();
}

class _PresencesScreenState extends State<PresencesScreen> {
  // --- بيانات وهمية كاملة ---
  final List<Map<String, dynamic>> dummyPresences = [
    {
      "id": "P1", "etudiant": "Ahmed Alami", "module": "UML et Analyse", "seance_id": "S1",
      "date": "19/10/2025", "statut": "Présent", "details": {"groupe": "GL1", "heure": "08:30 - 10:30"}
    },
    {
      "id": "P2", "etudiant": "Fatima Benali", "module": "UML et Analyse", "seance_id": "S1",
      "date": "19/10/2025", "statut": "Absent", "details": {"groupe": "GL1", "heure": "08:30 - 10:30"}
    },
    {
      "id": "P3", "etudiant": "Youssef Cherkaoui", "module": "Programmation 2", "seance_id": "S2",
      "date": "20/10/2025", "statut": "Présent", "details": {"groupe": "GL2", "heure": "10:45 - 12:45"}
    },
    {
      "id": "P4", "etudiant": "Amina Saidi", "module": "Réseaux Avancés", "seance_id": "S4",
      "date": "20/10/2025", "statut": "Présent", "details": {"groupe": "RI1", "heure": "14:00 - 16:00"}
    },
  ];

  late List<Map<String, dynamic>> _presencesData;
  late List<Map<String, dynamic>> _filteredPresences;

  @override
  void initState() {
    super.initState();
    // 💡 الآن يمكنك استخدام widget.token لجلب البيانات من الخدمة الحقيقية

    _presencesData = List.from(dummyPresences);
    _filterPresences();
  }

  // دالة التصفية
  void _filterPresences() {
    _filteredPresences = _presencesData.where((presence) {
      final matchesGroupe = presence['details']?['groupe'] == widget.selectedGroupe;
      // 💡 هنا يجب إضافة منطق فلترة الـ API الحقيقي
      return matchesGroupe;
    }).toList();
  }

  // --- الدوال (الإضافة، التعديل، الحذف، الفلتر) ---
  void _navigateToAddScreen() async {
    final result = await Navigator.push<Map<String, dynamic>>(context, MaterialPageRoute(builder: (context) => const AddPresenceScreen()));
    if (result != null) {
      setState(() {
        _presencesData.insert(0, result);
        _filterPresences();
      });
    }
  }

  void _navigateToEditScreen(Map<String, dynamic> presenceToEdit) async {
    final result = await Navigator.push<Map<String, dynamic>>(context, MaterialPageRoute(builder: (context) => EditPresenceScreen(presence: presenceToEdit)));
    if (result != null) {
      setState(() {
        final index = _presencesData.indexWhere((p) => p['id'] == result['id']);
        if (index != -1) _presencesData[index] = result;
        _filterPresences();
      });
    }
  }

  void _showDeleteConfirmDialog(BuildContext context, Map<String, dynamic> presenceToDelete) {
    showDialog(context: context, builder: (BuildContext dialogContext) { return AlertDialog(title: const Text('Confirmation de suppression'), content: Text('Êtes-vous sûr de vouloir supprimer l\'enregistrement de présence لـ "${presenceToDelete['etudiant']}" في ${presenceToDelete['date']}?'), actions: [ TextButton(child: const Text('Annuler'), onPressed: () => Navigator.of(dialogContext).pop()), TextButton(child: const Text('Supprimer', style: TextStyle(color: Colors.red)), onPressed: () { setState(() { _presencesData.removeWhere((item) => item['id'] == presenceToDelete['id']); _filterPresences(); }); Navigator.of(dialogContext).pop();},),]);},);
  }

  void _openFilterSheet() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) { return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), child: const PresenceFilterSheet());},);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'présent': return Colors.green.shade700;
      case 'absent': return Colors.red.shade700;
      case 'justifié': return Colors.orange.shade700;
      default: return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryAppBarColor = Color(0xFF0A4F48);
    const Color searchBarColor = Color(0xFFFFFFFF);
    const Color pageBackgroundColor = Color(0xFFF7F7F7);

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryAppBarColor, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
            'Présences - ${widget.selectedGroupe}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
      body: Column(
        children: [
          // شريط البحث/الفلتر وزر الإضافة
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: searchBarColor, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey[300]!), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)]),
                    child: TextField(
                        readOnly: true,
                        onTap: _openFilterSheet,
                        decoration: InputDecoration(hintText: 'Rechercher / Filtrer...', hintStyle: const TextStyle(color: Colors.grey), border: InputBorder.none, prefixIcon: Icon(Icons.search, color: Colors.grey[600]))
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                FloatingActionButton(
                  onPressed: _navigateToAddScreen,
                  backgroundColor: primaryAppBarColor,
                  tooltip: 'Marquer une présence',
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),

          // قائمة البطاقات
          Expanded(
            child: _filteredPresences.isEmpty
                ? Center(child: Text('Aucun enregistrement de présence trouvé لـ ${widget.selectedGroupe}.', textAlign: TextAlign.center,))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: _filteredPresences.length,
              itemBuilder: (context, index) {
                final presence = _filteredPresences[index];
                return _buildPresenceCard(context, presence);
              },
            ),
          ),
        ],
      ),
    );
  }

  // =================================================================
  // --- ويدجت بناء البطاقة (ترتيب التاريخ والوقت منفصل) ---
  // =================================================================
  Widget _buildPresenceCard(BuildContext context, Map<String, dynamic> presence) {
    const Color primaryAppBarColor = Color(0xFF0A4F48);
    final Color statusColor = _getStatusColor(presence['statut']);
    final String heure = presence['details']?['heure'] ?? 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
          // السطر 1: الإسم والأيقونات
          Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(presence['etudiant'], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primaryAppBarColor), overflow: TextOverflow.ellipsis)),
            Row( mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: const Icon(LucideIcons.pencil, color: Colors.green, size: 20),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                constraints: const BoxConstraints(),
                onPressed: () => _navigateToEditScreen(presence),
                tooltip: 'Modifier',
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                constraints: const BoxConstraints(),
                onPressed: () => _showDeleteConfirmDialog(context, presence),
                tooltip: 'Supprimer',
              ),
            ],),
          ],),
          const SizedBox(height: 12),

          // السطر 2: الموديل
          _buildInfoRow(Icons.library_books_outlined, presence['module']),
          const SizedBox(height: 6),

          // السطر 3: التاريخ
          _buildInfoRow(Icons.calendar_today_outlined, presence['date']),
          const SizedBox(height: 6),

          // السطر 4: الوقت
          _buildInfoRow(Icons.access_time_outlined, heure),

          const SizedBox(height: 10),

          // السطر 5: الحالة (Statut)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(5)),
              child: Text(
                presence['statut'],
                style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],),
      ),
    );
  }

  // ويدجت بناء صف المعلومات
  Widget _buildInfoRow(IconData icon, String text) {
    return Row( children: [
      Icon(icon, size: 16, color: Colors.grey[600]),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[800]), overflow: TextOverflow.ellipsis)),
    ],);
  }
}