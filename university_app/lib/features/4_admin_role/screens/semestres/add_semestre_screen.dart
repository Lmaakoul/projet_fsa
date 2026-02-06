// ملف: lib/features/4_admin_role/screens/semestres/add_semestre_screen.dart
// (النسخة النهائية: إصلاح مشكلة Overflow في النصوص الطويلة)

import 'package:flutter/material.dart';
// Models
import 'package:university_app/core/models/departement.dart';
import 'package:university_app/core/models/filiere.dart';
// Services
import 'package:university_app/core/services/semestre_service.dart';
import 'package:university_app/core/services/departement_service.dart';
import 'package:university_app/core/services/filiere_service.dart';

class AddSemestreScreen extends StatefulWidget {
  final String token;
  const AddSemestreScreen({super.key, required this.token});

  @override
  State<AddSemestreScreen> createState() => _AddSemestreScreenState();
}

class _AddSemestreScreenState extends State<AddSemestreScreen> {
  final _formKey = GlobalKey<FormState>();

  // 🛑 قائمة المستويات الثابتة
  static const List<String> FIXED_NIVEAUX = [
    "Licence",
    "Master",
    "Licence d'excellence",
    "Master d'excellence",
  ];

  // Controllers
  final _nameController = TextEditingController();
  final _academicYearController = TextEditingController(text: "2024-2025");
  final _semesterNumberController = TextEditingController();

  // Selection Variables
  Departement? _selectedDepartement;
  String? _selectedNiveau;
  Filiere? _selectedFiliere;

  // Services
  late final SemestreService _semestreService;
  late final DepartementService _departementService;
  late final FiliereService _filiereService;

  // Data Lists
  List<Departement> _allDepartements = [];
  List<Filiere> _allFilieres = [];
  List<String> _availableNiveaux = [];

  // UI States
  bool _isSaving = false;
  bool _isLoadingInitialData = true;
  String? _initialLoadError;

  @override
  void initState() {
    super.initState();
    _semestreService = SemestreService();
    _departementService = DepartementService();
    _filiereService = FiliereService();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _academicYearController.dispose();
    _semesterNumberController.dispose();
    super.dispose();
  }

  // 1. Data Loading
  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoadingInitialData = true;
      _initialLoadError = null;
    });

    try {
      final results = await Future.wait([
        _departementService.getAllDepartements(widget.token),
        _filiereService.getAllFilieres(widget.token),
      ]);

      if (mounted) {
        setState(() {
          _allDepartements = results[0] as List<Departement>;
          _allFilieres = results[1] as List<Filiere>;
          _isLoadingInitialData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
          _initialLoadError = "Erreur de connexion: $e";
        });
      }
    }
  }

  // 2. Logic: Cascade Changes

  void _onDepartementChanged(Departement? dept) {
    setState(() {
      _selectedDepartement = dept;
      _selectedNiveau = null;
      _selectedFiliere = null;
      _availableNiveaux = [];

      if (dept != null) {
        final existingNiveauxNormalized = _allFilieres
            .where((f) => f.departmentId == dept.id)
            .map((f) => f.degreeType.trim().toLowerCase())
            .toSet();

        _availableNiveaux = FIXED_NIVEAUX
            .where((fixedNiv) {
          final normalizedFixedNiv = fixedNiv.trim().toLowerCase();
          return existingNiveauxNormalized.contains(normalizedFixedNiv);
        })
            .toList();
      }
    });
  }

  void _onNiveauChanged(String? niveau) {
    setState(() {
      _selectedNiveau = niveau;
      _selectedFiliere = null;
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

    if (_selectedFiliere == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez sélectionner une filière.")));
      return;
    }

    setState(() => _isSaving = true);

    final String? result = await _semestreService.createSemestre(
      token: widget.token,
      name: _nameController.text,
      academicYear: _academicYearController.text,
      semesterNumber: int.parse(_semesterNumberController.text),
      filiereId: _selectedFiliere!.id,
    );

    if (mounted) setState(() => _isSaving = false);

    if (mounted) {
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Succès!"), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $result"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitialData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_initialLoadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Erreur")),
        body: Center(child: Text(_initialLoadError!, style: const TextStyle(color: Colors.red))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un Semestre"),
        backgroundColor: const Color(0xFF113A47),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: "Nom (ex: S1)", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Requis" : null),
              const SizedBox(height: 15),
              TextFormField(controller: _academicYearController, decoration: const InputDecoration(labelText: "Année Académique (ex: 2024-2025)", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Requis" : null),
              const SizedBox(height: 15),
              TextFormField(controller: _semesterNumberController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Numéro (ex: 1)", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Requis" : null),
              const SizedBox(height: 25),
              const Divider(),
              const SizedBox(height: 10),

              // 1. Departement (Fixed Overflow)
              DropdownButtonFormField<Departement>(
                decoration: const InputDecoration(labelText: "Département", border: OutlineInputBorder()),
                value: _selectedDepartement,
                isExpanded: true, // 🛑 Fix Overflow
                items: _allDepartements.map((dept) {
                  return DropdownMenuItem(
                      value: dept,
                      child: Text(dept.name, overflow: TextOverflow.ellipsis) // 🛑 Fix Text Overflow
                  );
                }).toList(),
                onChanged: _onDepartementChanged,
                validator: (value) => value == null ? 'Requis' : null,
              ),
              const SizedBox(height: 15),

              // 2. Niveau
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Niveau", border: OutlineInputBorder()),
                value: _selectedNiveau,
                hint: const Text('Sélectionner...'),
                isExpanded: true, // 🛑 Fix Overflow
                items: _availableNiveaux.map((n) => DropdownMenuItem(
                    value: n,
                    child: Text(n, overflow: TextOverflow.ellipsis) // 🛑 Fix Text Overflow
                )).toList(),
                onChanged: _availableNiveaux.isEmpty ? null : _onNiveauChanged,
                validator: (value) => value == null ? 'Requis' : null,
              ),
              const SizedBox(height: 15),

              // 3. Filiere (Fixed Overflow)
              _buildFiliereDropdown(),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSaving ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF113A47),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🛑 الويدجت المصححة للـ Filiere
  Widget _buildFiliereDropdown() {
    final filieres = _filteredFilieres;
    final isEnabled = _selectedNiveau != null;

    return DropdownButtonFormField<Filiere>(
      decoration: const InputDecoration(labelText: "Filière", border: OutlineInputBorder()),
      value: _selectedFiliere,
      isExpanded: true, // 🛑 1. يجعل الحقل يأخذ العرض الكامل
      hint: Text(
          isEnabled && filieres.isEmpty ? 'Aucune filière trouvée' : 'Sélectionner une Filière',
          overflow: TextOverflow.ellipsis // 🛑 2. يمنع الخطأ في نص التلميح
      ),
      items: filieres.map((f) => DropdownMenuItem(
          value: f,
          child: Text(f.name, overflow: TextOverflow.ellipsis) // 🛑 3. يقص النص الطويل في القائمة
      )).toList(),
      onChanged: (isEnabled && filieres.isNotEmpty)
          ? (val) => setState(() => _selectedFiliere = val)
          : null,
      validator: (value) => value == null ? 'Requis' : null,
    );
  }
}