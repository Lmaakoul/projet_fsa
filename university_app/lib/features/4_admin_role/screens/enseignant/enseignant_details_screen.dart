// ملف: lib/features/4_admin_role/screens/enseignant/enseignant_details_screen.dart
// (النسخة المصححة - كتستقبل الـ Model l-s7i7 w l-Token)

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'edit_enseignant_screen.dart';
import 'package:university_app/core/models/professor.dart'; // [جديد] Import l-Model

class EnseignantDetailsScreen extends StatefulWidget {
  // [تصحيح 1] Mabqaš Map, wlla Model
  final Professor professor;
  final String token; // Khassna l-Token baš ndwzoh l-Edit

  const EnseignantDetailsScreen({
    super.key,
    required this.professor,
    required this.token, // Zdnaha
  });

  @override
  State<EnseignantDetailsScreen> createState() => _EnseignantDetailsScreenState();
}

class _EnseignantDetailsScreenState extends State<EnseignantDetailsScreen> {

  // (TODO: L-Modules khasshom ijibo mn l-API, ماشي Dummy Data)
  List<String> _modulesEnseignes = [];
  final List<Map<String, dynamic>> filieresData = [
    { "id": "1", "nom": "ingénieur logiciel", "modulesDetails": [ {'nom': 'Programmation 2', 'responsable': 'Hicham El Amrani'}, {'nom': 'UML et Analyse', 'responsable': 'Hicham El Amrani'},], },
    { "id": "2", "nom": "SMI", "modulesDetails": [{'nom': 'Sécurité', 'responsable': 'Fatima Zahra'}],},
  ];

  @override
  void initState() {
    super.initState();
    _loadModulesEnseignes();
  }

  void _loadModulesEnseignes() {
    // (TODO: Khassha tkhdem b widget.professor.id mli n-connect-iw l-API dyal l-modules)
    final String profNom = widget.professor.fullName ?? ''; // (Daba b'l-Model)
    if (profNom.isEmpty) return;

    final Set<String> modules = {};
    for (var filiere in filieresData) {
      final List<dynamic> modulesDetails = filiere['modulesDetails'] ?? [];
      for (var module in modulesDetails) {
        if (module['responsable'] == profNom) {
          modules.add(module['nom'] as String);
        }
      }
    }
    setState(() { _modulesEnseignes = modules.toList(); });
  }

  // [تصحيح 3] Hada howa l-7el dyal l-Error dyalk
  void _navigateToEditScreen() async {
    final result = await Navigator.push<bool>( // (Ghanrj3o bool)
        context,
        MaterialPageRoute(
          // Kaystqbl 'professor' w 'token'
            builder: (context) => EditEnseignantScreen(
              professor: widget.professor, // L-Model
              token: widget.token,       // L-Token
            )
        )
    );

    if (result == true) {
      // (Ghanrj3o l-lista w n-refresh-iwha mn tma)
      Navigator.pop(context, true); // (Kanrj3o 'true' l-sf7a dyal l-lista)
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryAppBarColor = Color(0xFF113A47);
    const Color pageBackgroundColor = Color(0xFFF9F3FD);

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        // [تصحيح 4] Kanqraw mn l-Model
        title: Text(widget.professor.fullName ?? 'Détails', style: const TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: primaryAppBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.pencil, color: Colors.white, size: 20),
            onPressed: _navigateToEditScreen,
            tooltip: 'Modifier',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // [تصحيح 5] Kanqraw mn l-Model
                _buildDetailRow(
                  icon: LucideIcons.user,
                  label: 'Nom complet',
                  value: widget.professor.fullName,
                ),
                _buildDetailRow(
                  icon: LucideIcons.mail,
                  label: 'Email',
                  value: widget.professor.email,
                ),
                _buildDetailRow(
                  icon: LucideIcons.star, // (L-API kay3tina 'grade')
                  label: 'Grade',
                  value: widget.professor.grade,
                ),
                _buildDetailRow(
                  icon: LucideIcons.building,
                  label: 'Département',
                  value: widget.professor.departmentName,
                ),

                _buildModulesList(
                  icon: LucideIcons.bookCopy,
                  label: 'Modules Enseignés (Dummy)', // (Baqi Dummy)
                  modules: _modulesEnseignes,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF113A47), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? 'N/A',
                  style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesList({required IconData icon, required String label, required List<String> modules}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF113A47), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 8),
                if (modules.isEmpty)
                  const Text(
                    'Aucun module assigné',
                    style: TextStyle(color: Colors.black54, fontSize: 16, fontStyle: FontStyle.italic),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: modules.map((moduleName) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        moduleName,
                        style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    )).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}