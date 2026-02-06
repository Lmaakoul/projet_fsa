// ملف: lib/features/4_admin_role/screens/modules/add_module_screen.dart
// (النسخة النهائية: تم إصلاح مشكلة Overflow في الـ Dropdown)

import 'package:flutter/material.dart';
// Models
import 'package:university_app/core/models/semestre.dart';
import 'package:university_app/core/models/departement.dart';
import 'package:university_app/core/models/filiere.dart';

// Services
import 'package:university_app/core/services/semestre_service.dart';
import 'package:university_app/core/services/module_service.dart';
import 'package:university_app/core/services/departement_service.dart';
import 'package:university_app/core/services/filiere_service.dart';


class AddModuleScreen extends StatefulWidget {
  final String token;
  const AddModuleScreen({super.key, required this.token});

  @override
  State<AddModuleScreen> createState() => _AddModuleScreenState();
}

class _AddModuleScreenState extends State<AddModuleScreen> {
  final _formKey = GlobalKey<FormState>();

  // قائمة المستويات الثابتة
  static const List<String> FIXED_NIVEAUX = [
    "LICENCE",
    "MASTER",
    "DEUG",
    "LP",
    "DOCTORAT",
    "Licence d'excellence",
    "Master d'excellence",
  ];

  // Controllers
  final _titleController = TextEditingController();
  final _codeController = TextEditingController();
  final _creditsController = TextEditingController();
  final _passingGradeController = TextEditingController(text: "10.0");

  // Selection Variables (Cascading)
  Departement? _selectedDepartement;
  String? _selectedNiveau;
  Filiere? _selectedFiliere;
  String? _selectedSemestreId;

  // Dropdown Data
  List<Departement> _allDepartements = [];
  List<Filiere> _allFilieres = [];
  List<Semestre> _allSemestres = [];

  // Dynamic Lists
  List<String> _availableNiveaux = [];
  List<Semestre> _filteredSemestres = [];

  // Services
  final _moduleService = ModuleService();
  final _semestreService = SemestreService();
  late final DepartementService _departementService;
  late final FiliereService _filiereService;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _departementService = DepartementService();
    _filiereService = FiliereService();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _creditsController.dispose();
    _passingGradeController.dispose();
    super.dispose();
  }

  // 1. Data Loading
  Future<void> _fetchInitialData() async {
    try {
      final results = await Future.wait([
        _departementService.getAllDepartements(widget.token),
        _filiereService.getAllFilieres(widget.token),
        _semestreService.getAllSemestres(widget.token),
      ]);

      if (mounted) {
        setState(() {
          _allDepartements = results[0] as List<Departement>;
          _allFilieres = results[1] as List<Filiere>;
          _allSemestres = results[2] as List<Semestre>;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ ERROR loading initial data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. Logic: Cascade Changes

  void _onDepartementChanged(Departement? dept) {
    setState(() {
      _selectedDepartement = dept;
      _selectedNiveau = null;
      _selectedFiliere = null;
      _selectedSemestreId = null;
      _availableNiveaux = [];
      _filteredSemestres = [];

      if (dept != null) {
        final existingNiveauxNormalized = _allFilieres
            .where((f) => f.departmentId == dept.id)
            .map((f) => f.degreeType.trim().toLowerCase())
            .toSet();

        _availableNiveaux = FIXED_NIVEAUX
            .where((fixedNiv) => existingNiveauxNormalized.contains(fixedNiv.trim().toLowerCase()))
            .toList();
      }
    });
  }

  void _onNiveauChanged(String? niveau) {
    setState(() {
      _selectedNiveau = niveau;
      _selectedFiliere = null;
      _selectedSemestreId = null;
      _filteredSemestres = [];
    });
  }

  void _onFiliereChanged(Filiere? filiere) {
    setState(() {
      _selectedFiliere = filiere;
      _selectedSemestreId = null;
      _filteredSemestres = [];

      if (filiere != null) {
        _filteredSemestres = _allSemestres
            .where((s) => s.filiereId == filiere.id)
            .toList();
      }
    });
  }

  List<Filiere> get _filteredFilieres {
    if (_selectedDepartement == null || _selectedNiveau == null) return [];

    final selectedNiveauNormalized = _selectedNiveau!.trim().toLowerCase();

    return _allFilieres.where((f) =>
    f.departmentId == _selectedDepartement!.id &&
        f.degreeType.trim().toLowerCase() == selectedNiveauNormalized
    ).toList();
  }

  // 3. Save Action
  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSemestreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sélectionnez un semestre")));
      return;
    }

    setState(() => _isLoading = true);

    bool success = await _moduleService.createModule(
      token: widget.token,
      title: _titleController.text,
      code: _codeController.text,
      semesterId: _selectedSemestreId!,
      credits: int.tryParse(_creditsController.text) ?? 0,
      passingGrade: double.tryParse(_passingGradeController.text) ?? 10.0,
      professorIds: [],
    );

    if (mounted) setState(() => _isLoading = false);
    if (mounted && success) Navigator.pop(context, true);
  }

  // 4. Build Widgets

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
          appBar: AppBar(title: const Text("Ajouter un Module", style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF113A47)),
          body: const Center(child: CircularProgressIndicator())
      );
    }

    final filieres = _filteredFilieres;
    final isNiveauEnabled = _selectedDepartement != null && _availableNiveaux.isNotEmpty;
    final isFiliereEnabled = _selectedNiveau != null && filieres.isNotEmpty;
    final isSemestreEnabled = _selectedFiliere != null && _filteredSemestres.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un Module", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF113A47),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: "Titre du Module", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Requis" : null),
              const SizedBox(height: 15),
              Row(children: [
                Expanded(child: TextFormField(controller: _codeController, decoration: const InputDecoration(labelText: "Code (ex: M-101)", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Requis" : null)),
                const SizedBox(width: 15),
                Expanded(child: TextFormField(controller: _passingGradeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Note de passage (ex: 10.0)", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Requis" : null)),
              ]),
              const SizedBox(height: 15),
              TextFormField(controller: _creditsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Crédits (ex: 4)", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Requis" : null),
              const SizedBox(height: 25),
              const Divider(),
              const SizedBox(height: 10),

              // 1. Departement
              _buildDropdownDepartement(),
              const SizedBox(height: 15),

              // 2. Niveau
              _buildDropdownNiveau(isNiveauEnabled),
              const SizedBox(height: 15),

              // 3. Filiere
              _buildDropdownFiliere(filieres, isFiliereEnabled),
              const SizedBox(height: 15),

              // 4. Semestre
              _buildDropdownSemestre(isSemestreEnabled),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _onSave,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Enregistrer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF113A47),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Dropdowns (With Overflow Fixes) ---

  Widget _buildDropdownDepartement() {
    return DropdownButtonFormField<Departement>(
      value: _selectedDepartement,
      isExpanded: true, // 🛑 Fix Overflow
      decoration: const InputDecoration(labelText: "Département", border: OutlineInputBorder()),
      items: _allDepartements.map((dept) => DropdownMenuItem(
          value: dept,
          child: Text(dept.name, overflow: TextOverflow.ellipsis) // 🛑 Fix Text Overflow
      )).toList(),
      onChanged: _onDepartementChanged,
      validator: (v) => v == null ? 'Obligatoire' : null,
    );
  }

  Widget _buildDropdownNiveau(bool isEnabled) {
    return DropdownButtonFormField<String>(
      value: _selectedNiveau,
      isExpanded: true, // 🛑 Fix Overflow
      hint: const Text('Sélectionner un Niveau'),
      decoration: const InputDecoration(labelText: "Niveau", border: OutlineInputBorder()),
      items: _availableNiveaux.map((n) => DropdownMenuItem(
          value: n,
          child: Text(n, overflow: TextOverflow.ellipsis) // 🛑 Fix Text Overflow
      )).toList(),
      onChanged: isEnabled ? _onNiveauChanged : null,
      validator: (v) => v == null ? 'Obligatoire' : null,
    );
  }

  Widget _buildDropdownFiliere(List<Filiere> filieres, bool isEnabled) {
    return DropdownButtonFormField<Filiere>(
      value: _selectedFiliere,
      isExpanded: true, // 🛑 Fix Overflow
      hint: Text(isEnabled && filieres.isEmpty ? 'Aucune filière trouvée' : 'Sélectionner une Filière', overflow: TextOverflow.ellipsis),
      decoration: const InputDecoration(labelText: "Filière", border: OutlineInputBorder()),
      items: filieres.map((f) => DropdownMenuItem(
          value: f,
          child: Text(f.name, overflow: TextOverflow.ellipsis) // 🛑 Fix Text Overflow
      )).toList(),
      onChanged: isEnabled ? _onFiliereChanged : null,
      validator: (v) => v == null ? 'Obligatoire' : null,
    );
  }

  Widget _buildDropdownSemestre(bool isEnabled) {
    return DropdownButtonFormField<String>(
      value: _selectedSemestreId,
      isExpanded: true, // 🛑 Fix Overflow
      hint: const Text('Sélectionner un Semestre'),
      decoration: const InputDecoration(labelText: "Semestre (Obligatoire)", border: OutlineInputBorder()),
      items: _filteredSemestres.map((s) => DropdownMenuItem(
          value: s.id,
          child: Text("${s.name} (${s.academicYear})", overflow: TextOverflow.ellipsis) // 🛑 Fix Text Overflow
      )).toList(),
      onChanged: isEnabled ? (v) => setState(() => _selectedSemestreId = v) : null,
      validator: (v) => v == null ? 'Obligatoire' : null,
    );
  }
}