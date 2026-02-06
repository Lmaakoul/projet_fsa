// ملف: lib/features/4_admin_role/screens/enseignant/add_enseignant_screen.dart
// (النسخة النهائية: تم إصلاح مشكلة Overflow في جميع القوائم المنسدلة)

import 'package:flutter/material.dart';
// Imports dyal Models
import 'package:university_app/core/models/departement.dart';
import 'package:university_app/core/models/filiere.dart';
import 'package:university_app/core/models/module.dart';
import 'package:university_app/core/models/semestre.dart'; // تأكد من وجود هذا
// Imports dyal Services
import 'package:university_app/core/services/departement_service.dart';
import 'package:university_app/core/services/professor_service.dart';
import 'package:university_app/core/services/filiere_service.dart';
import 'package:university_app/core/services/module_service.dart';
import 'package:university_app/core/services/semestre_service.dart'; // تأكد من وجود هذا

class AddEnseignantScreen extends StatefulWidget {
  final String token;

  const AddEnseignantScreen({
    super.key,
    required this.token,
  });

  @override
  State<AddEnseignantScreen> createState() => _AddEnseignantScreenState();
}

class _AddEnseignantScreenState extends State<AddEnseignantScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _gradeController = TextEditingController();
  final _passwordController = TextEditingController();

  // --- Services ---
  late final DepartementService _departementService;
  late final ProfessorService _professorService;
  late final FiliereService _filiereService;
  late final ModuleService _moduleService;
  late final SemestreService _semestreService;

  // --- Data Lists ---
  List<Departement> _allDepartements = [];
  List<Filiere> _allFilieres = [];
  List<Semestre> _allSemestres = [];
  List<Module> _allModules = [];

  // --- Filtered Lists ---
  List<String> _niveauxList = [];
  List<Filiere> _filteredFilieres = [];
  List<Semestre> _filteredSemestres = [];
  List<Module> _filteredModules = [];

  // --- Selected Values ---
  String? _selectedDepartementId;
  String? _selectedNiveau;
  Filiere? _selectedFiliere;
  String? _selectedSemestreId;
  String? _selectedModuleId;

  bool _isLoadingData = true;
  bool _isSaving = false;

  static const Color primaryAppBarColor = Color(0xFF0A4F48);
  static const Color pageBackgroundColor = Color(0xFFFCF5F8);

  @override
  void initState() {
    super.initState();
    _departementService = DepartementService();
    _professorService = ProfessorService();
    _filiereService = FiliereService();
    _moduleService = ModuleService();
    _semestreService = SemestreService();

    _passwordController.text = "fsa123456";
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoadingData = true);
    try {
      final results = await Future.wait([
        _departementService.getAllDepartements(widget.token),
        _filiereService.getAllFilieres(widget.token),
        _semestreService.getAllSemestres(widget.token),
        _moduleService.getAllModules(widget.token),
      ]);

      if (mounted) {
        setState(() {
          _allDepartements = results[0] as List<Departement>;
          _allFilieres = results[1] as List<Filiere>;
          _allSemestres = results[2] as List<Semestre>;
          _allModules = results[3] as List<Module>;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      print("Erreur chargement data: $e");
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  // --- Logic Cascade ---

  void _onDepartementChanged(String? deptId) {
    setState(() {
      _selectedDepartementId = deptId;
      _selectedNiveau = null; _selectedFiliere = null; _selectedSemestreId = null; _selectedModuleId = null;
      _niveauxList = []; _filteredFilieres = []; _filteredSemestres = []; _filteredModules = [];

      if (deptId != null) {
        final filieresDuDept = _allFilieres.where((f) => f.departmentId == deptId).toList();
        _niveauxList = filieresDuDept.map((f) => f.degreeType).toSet().toList();
      }
    });
  }

  void _onNiveauChanged(String? niveau) {
    setState(() {
      _selectedNiveau = niveau;
      _selectedFiliere = null; _selectedSemestreId = null; _selectedModuleId = null;
      _filteredFilieres = []; _filteredSemestres = []; _filteredModules = [];

      if (niveau != null && _selectedDepartementId != null) {
        final normalizedNiveau = niveau.trim().toLowerCase();
        _filteredFilieres = _allFilieres.where((f) =>
        f.departmentId == _selectedDepartementId &&
            f.degreeType.trim().toLowerCase() == normalizedNiveau
        ).toList();
      }
    });
  }

  void _onFiliereChanged(Filiere? filiere) {
    setState(() {
      _selectedFiliere = filiere;
      _selectedSemestreId = null; _selectedModuleId = null;
      _filteredSemestres = []; _filteredModules = [];

      if (filiere != null) {
        _filteredSemestres = _allSemestres
            .where((s) => s.filiereId == filiere.id)
            .toList();
        _filteredSemestres.sort((a, b) => a.semesterNumber.compareTo(b.semesterNumber));
      }
    });
  }

  void _onSemestreChanged(String? semestreId) {
    setState(() {
      _selectedSemestreId = semestreId;
      _selectedModuleId = null;
      _filteredModules = [];

      if (semestreId != null) {
        _filteredModules = _allModules
            .where((m) => m.semesterId == semestreId)
            .toList();
      }
    });
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDepartementId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez sélectionner un département")));
      return;
    }

    setState(() => _isSaving = true);

    bool success = await _professorService.createProfessor(
      token: widget.token,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      grade: _gradeController.text,
      departmentId: _selectedDepartementId!,
      password: _passwordController.text,
    );

    if (mounted) setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la création"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _gradeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryAppBarColor,
        title: const Text('Ajouter Un Enseignant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Informations Personnel'),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _buildTextField(controller: _firstNameController, label: 'Prénom')),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField(controller: _lastNameController, label: 'Nom')),
                ]),
                const SizedBox(height: 15),
                _buildTextField(controller: _emailController, label: 'Email', isEmail: true),
                const SizedBox(height: 15),
                _buildTextField(controller: _gradeController, label: 'Grade'),
                const SizedBox(height: 15),
                _buildTextField(controller: _passwordController, label: 'Mot de passe', isPassword: true),

                const SizedBox(height: 25),
                _buildSectionTitle('Affectation Pédagogique'),
                const SizedBox(height: 10),

                // 1. Departement
                _buildDropdown(
                  label: "Département",
                  value: _selectedDepartementId,
                  items: _allDepartements.map((e) => DropdownMenuItem(
                      value: e.id,
                      child: Text(e.name, overflow: TextOverflow.ellipsis) // 🛑 Fix Overflow
                  )).toList(),
                  onChanged: _onDepartementChanged,
                ),
                const SizedBox(height: 15),

                // 2. Niveau
                _buildDropdown(
                  label: "Niveau (Degree)",
                  value: _selectedNiveau,
                  items: _selectedDepartementId == null
                      ? []
                      : _niveauxList.map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, overflow: TextOverflow.ellipsis) // 🛑 Fix Overflow
                  )).toList(),
                  onChanged: _selectedDepartementId == null ? null : _onNiveauChanged,
                ),
                const SizedBox(height: 15),

                // 3. Filiere (Specific Widget with Fix)
                DropdownButtonFormField<Filiere>(
                  value: _selectedFiliere,
                  isExpanded: true, // 🛑 Fix Overflow: Expand to fit width
                  decoration: _inputDecoration("Filière"),
                  items: _selectedNiveau == null
                      ? []
                      : _filteredFilieres.map((f) => DropdownMenuItem(
                      value: f,
                      child: Text(f.name, overflow: TextOverflow.ellipsis) // 🛑 Fix Overflow: Ellipsis
                  )).toList(),
                  onChanged: _selectedNiveau == null ? null : _onFiliereChanged,
                  hint: const Text("Sélectionner..."),
                ),
                const SizedBox(height: 15),

                // 4. Semestre (Dynamic)
                DropdownButtonFormField<String>(
                  value: _selectedSemestreId,
                  isExpanded: true, // 🛑 Fix Overflow
                  decoration: _inputDecoration("Semestre"),
                  hint: Text(_selectedFiliere != null && _filteredSemestres.isEmpty
                      ? "Aucun semestre trouvé"
                      : "Sélectionner...", overflow: TextOverflow.ellipsis),
                  items: _filteredSemestres.map((s) => DropdownMenuItem(
                    value: s.id,
                    child: Text("${s.name} (${s.academicYear})", overflow: TextOverflow.ellipsis), // 🛑 Fix Overflow
                  )).toList(),
                  onChanged: _filteredSemestres.isEmpty ? null : _onSemestreChanged,
                  disabledHint: const Text("Non disponible"),
                ),
                const SizedBox(height: 15),

                // 5. Module (Dynamic)
                DropdownButtonFormField<String>(
                  value: _selectedModuleId,
                  isExpanded: true, // 🛑 Fix Overflow
                  decoration: _inputDecoration("Module"),
                  hint: Text(_selectedSemestreId != null && _filteredModules.isEmpty
                      ? "Aucun module trouvé"
                      : "Sélectionner...", overflow: TextOverflow.ellipsis),
                  items: _filteredModules.map((m) => DropdownMenuItem(
                    value: m.id,
                    child: Text(m.title, overflow: TextOverflow.ellipsis), // 🛑 Fix Overflow
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedModuleId = val),
                  disabledHint: const Text("Non disponible"),
                ),

                const SizedBox(height: 30),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helpers ---

  Widget _buildSectionTitle(String title) {
    return Row(children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
      const SizedBox(width: 8),
      Expanded(child: Divider(color: Colors.grey[300], thickness: 1))
    ]);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE4DDEF), width: 2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryAppBarColor, width: 2)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, bool isPassword = false, bool isEmail = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: _inputDecoration(label),
        validator: (value) => (value == null || value.isEmpty) ? 'Champ requis' : null,
      )
    ]);
  }

  // 🛑 Widget Dropdown العام (مع الإصلاح)
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true, // 🛑 Fix Overflow
      decoration: _inputDecoration(label),
      hint: const Text('Sélectionner...', overflow: TextOverflow.ellipsis),
      disabledHint: const Text('Non disponible'),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Annuler', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: _isSaving ? null : _onSave,
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryAppBarColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
          ),
          child: _isSaving
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Ajouter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ],
    );
  }
}