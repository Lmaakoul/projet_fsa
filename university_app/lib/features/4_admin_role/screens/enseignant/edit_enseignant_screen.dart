// ملف: lib/features/4_admin_role/screens/enseignant/edit_enseignant_screen.dart
// (النسخة المصححة - مربوطة بـ API PUT)

import 'package:flutter/material.dart';
// [جديد] Imports dyal l-API
import 'package:university_app/core/models/departement.dart';
import 'package:university_app/core/models/professor.dart';
import 'package:university_app/core/services/departement_service.dart';
import 'package:university_app/core/services/professor_service.dart';

class EditEnseignantScreen extends StatefulWidget {
  // [تصحيح] Kaystqbl Professor Model w Token
  final Professor professor;
  final String token;

  const EditEnseignantScreen({
    super.key,
    required this.professor,
    required this.token,
  });

  @override
  State<EditEnseignantScreen> createState() => _EditEnseignantScreenState();
}

class _EditEnseignantScreenState extends State<EditEnseignantScreen> {
  final _formKey = GlobalKey<FormState>();

  // [تصحيح] L-Form l-jdid 7sb l-API
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _gradeController;
  String? _selectedDepartementId;

  // [جديد] Services w Loading state
  late final DepartementService _departementService;
  late final ProfessorService _professorService;
  late Future<List<Departement>> _departementsFuture;
  bool _isLoading = false;

  static const Color primaryAppBarColor = Color(0xFF0A4F48);
  static const Color pageBackgroundColor = Color(0xFFFCF5F8);

  @override
  void initState() {
    super.initState();
    // Kan-init-iw l-Services
    _departementService = DepartementService();
    _professorService = ProfessorService();
    // Kan-load-iw l-lista dyal Departements
    _loadDepartements();

    // [تصحيح] Kan3mro l-form mn l-Model
    _firstNameController = TextEditingController(text: widget.professor.firstName);
    _lastNameController = TextEditingController(text: widget.professor.lastName);
    _emailController = TextEditingController(text: widget.professor.email);
    _gradeController = TextEditingController(text: widget.professor.grade ?? '');
    _selectedDepartementId = widget.professor.departmentId;
  }

  void _loadDepartements() {
    _departementsFuture = _departementService.getAllDepartements(widget.token);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  // [جديد] L-Function dyal "Enregistrer" l-jdida (b'l-API PUT)
  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDepartementId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner un département")),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = await _professorService.updateProfessor(
      token: widget.token,
      id: widget.professor.id, // L-ID l-qdim
      firstName: _firstNameController.text, // L-ism l-jdid
      lastName: _lastNameController.text, // L-knya l-jdida
      email: _emailController.text, // L-email l-jdid
      grade: _gradeController.text, // L-grade l-jdid
      departmentId: _selectedDepartementId!, // L-dept l-jdid
    );

    if (mounted) setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true); // (Kanrj3o 'true' baš n-refresh-iw l-lista)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Échec de la modification. (Vérifiez si l'email existe déjà)"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryAppBarColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Modifier Un Enseignant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildSectionTitle('Informations Personnel'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controller: _firstNameController, label: 'Prénom (First Name)')),
                    const SizedBox(width: 15),
                    Expanded(child: _buildTextField(controller: _lastNameController, label: 'Nom (Last Name)')),
                  ],
                ),
                const SizedBox(height: 15),
                _buildTextField(controller: _emailController, label: 'Email (Obligatoire)', isEmail: true),
                const SizedBox(height: 15),
                _buildTextField(controller: _gradeController, label: 'Grade (Ex: PES, PA)'),

                const SizedBox(height: 25),
                _buildSectionTitle('Affectation principale'),
                const SizedBox(height: 10),
                _buildDepartementDropdown(), // (L-Dropdown dyal Departements)

                const SizedBox(height: 30),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)), const SizedBox(width: 8), Expanded(child: Divider(color: Colors.grey[300], thickness: 1))]);
  }

  Widget _buildTextField({required TextEditingController controller, required String label, bool isEmail = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 13)), const SizedBox(height: 4), TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE4DDEF), width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryAppBarColor, width: 2)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Champ requis';
        }
        if (isEmail && !value.contains('@')) {
          return 'Email invalide';
        }
        return null;
      },
    )]);
  }

  // [جديد] L-Dropdown dyal Departements mn l-API
  Widget _buildDepartementDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Département (Obligatoire)', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
        const SizedBox(height: 4),

        FutureBuilder<List<Departement>>(
          future: _departementsFuture,
          builder: (context, snapshot) {
            // F'7alat Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Text("Chargement des départements..."));
            }
            // F'7alat Error
            if (!snapshot.hasData || snapshot.hasError) {
              return const Center(child: Text("Erreur de chargement des départements."));
            }

            final departements = snapshot.data!;

            return DropdownButtonFormField<String>(
              value: _selectedDepartementId, // (Kay-select-i l-ID l-qdim)
              hint: const Text('Sélectionner...'),
              items: departements.map((dept) {
                return DropdownMenuItem(
                  value: dept.id,
                  child: Text(dept.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartementId = value;
                });
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE4DDEF), width: 2)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryAppBarColor, width: 2)),
              ),
              validator: (value) => (value == null) ? 'Champ requis' : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: _isLoading ? null : () {Navigator.pop(context);},
          child: const Text('Annuler', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _onSave,
          style: ElevatedButton.styleFrom(backgroundColor: primaryAppBarColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Enregistrer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}