// ملف: lib/features/4_admin_role/screens/groups/add_group_screen.dart

import 'package:flutter/material.dart';
import 'package:university_app/core/models/departement.dart';
import 'package:university_app/core/models/filiere.dart';
import 'package:university_app/core/models/semestre.dart';
import 'package:university_app/core/models/module.dart';

import 'package:university_app/core/services/departement_service.dart';
import 'package:university_app/core/services/filiere_service.dart';
import 'package:university_app/core/services/semestre_service.dart';
import 'package:university_app/core/services/module_service.dart';
import 'package:university_app/core/services/group_service.dart';

class AddGroupScreen extends StatefulWidget {
  final String token;
  const AddGroupScreen({super.key, required this.token});

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final _formKey = GlobalKey<FormState>();

  static const List<String> FIXED_NIVEAUX = ["LICENCE", "MASTER", "DEUG", "LP", "DOCTORAT", "Licence d'excellence", "Master d'excellence"];

  final _nameController = TextEditingController();
  final _codeController = TextEditingController(); // 🛑 [NEW] Controller
  final _capacityController = TextEditingController();

  // Services
  late final DepartementService _deptService;
  late final FiliereService _filiereService;
  late final SemestreService _semestreService;
  late final ModuleService _moduleService;
  late final GroupService _groupService;

  // Lists
  List<Departement> _allDepartements = [];
  List<Filiere> _allFilieres = [];
  List<Semestre> _allSemestres = [];
  List<Module> _allModules = [];

  // Filtered Lists
  List<String> _availableNiveaux = [];
  List<Semestre> _filteredSemestres = [];
  List<Module> _filteredModules = [];

  // Selection
  Departement? _selectedDepartement;
  String? _selectedNiveau;
  Filiere? _selectedFiliere;
  String? _selectedSemestreId;
  String? _selectedModuleId;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _deptService = DepartementService();
    _filiereService = FiliereService();
    _semestreService = SemestreService();
    _moduleService = ModuleService();
    _groupService = GroupService();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose(); // 🛑 Dispose
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    try {
      final results = await Future.wait([
        _deptService.getAllDepartements(widget.token),
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
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Logic Cascade ---
  void _onDepartementChanged(Departement? dept) {
    setState(() {
      _selectedDepartement = dept;
      _selectedNiveau = null; _selectedFiliere = null; _selectedSemestreId = null; _selectedModuleId = null;
      _availableNiveaux = []; _filteredSemestres = []; _filteredModules = [];
      if (dept != null) {
        final existingNiveaux = _allFilieres.where((f) => f.departmentId == dept.id).map((f) => f.degreeType.trim().toLowerCase()).toSet();
        _availableNiveaux = FIXED_NIVEAUX.where((n) => existingNiveaux.contains(n.trim().toLowerCase())).toList();
      }
    });
  }

  void _onNiveauChanged(String? niveau) {
    setState(() {
      _selectedNiveau = niveau;
      _selectedFiliere = null; _selectedSemestreId = null; _selectedModuleId = null;
      _filteredSemestres = []; _filteredModules = [];
    });
  }

  void _onFiliereChanged(Filiere? filiere) {
    setState(() {
      _selectedFiliere = filiere;
      _selectedSemestreId = null; _selectedModuleId = null;
      _filteredSemestres = []; _filteredModules = [];
      if (filiere != null) {
        _filteredSemestres = _allSemestres.where((s) => s.filiereId == filiere.id).toList();
      }
    });
  }

  void _onSemestreChanged(String? semestreId) {
    setState(() {
      _selectedSemestreId = semestreId;
      _selectedModuleId = null;
      _filteredModules = [];
      if (semestreId != null) {
        _filteredModules = _allModules.where((m) => m.semesterId == semestreId).toList();
      }
    });
  }

  List<Filiere> get _filteredFilieres {
    if (_selectedDepartement == null || _selectedNiveau == null) return [];
    final normNiveau = _selectedNiveau!.trim().toLowerCase();
    return _allFilieres.where((f) => f.departmentId == _selectedDepartement!.id && f.degreeType.trim().toLowerCase() == normNiveau).toList();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedModuleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez sélectionner un module")));
      return;
    }

    setState(() => _isSaving = true);

    bool success = await _groupService.createGroup(
      token: widget.token,
      name: _nameController.text,
      code: _codeController.text, // 🛑 [NEW] Send Code
      moduleId: _selectedModuleId!,
      capacity: int.tryParse(_capacityController.text) ?? 30,
    );

    if (mounted) setState(() => _isSaving = false);
    if (mounted && success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un Groupe", style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF113A47)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Nom du Groupe (ex: TP-A)", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Requis" : null
              ),
              const SizedBox(height: 15),

              // 🛑 [NEW] Field for Code
              TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: "Code du Groupe (ex: GR-TP-A)", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Requis" : null
              ),
              const SizedBox(height: 15),

              TextFormField(
                  controller: _capacityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Capacité (ex: 30)", border: OutlineInputBorder())
              ),
              const SizedBox(height: 25),

              _buildDropdown<Departement>(value: _selectedDepartement, label: "Département", items: _allDepartements, onChanged: _onDepartementChanged, display: (d) => d.name),
              const SizedBox(height: 15),
              _buildDropdown<String>(value: _selectedNiveau, label: "Niveau", items: _availableNiveaux, onChanged: _selectedDepartement == null ? null : _onNiveauChanged, display: (s) => s),
              const SizedBox(height: 15),
              _buildDropdown<Filiere>(value: _selectedFiliere, label: "Filière", items: _filteredFilieres, onChanged: _selectedNiveau == null ? null : _onFiliereChanged, display: (f) => f.name),
              const SizedBox(height: 15),
              _buildDropdown<String>(value: _selectedSemestreId, label: "Semestre", items: _filteredSemestres.map((s) => s.id).toList(), onChanged: _selectedFiliere == null ? null : _onSemestreChanged, display: (id) => _filteredSemestres.firstWhere((s) => s.id == id).name),
              const SizedBox(height: 15),
              _buildDropdown<String>(value: _selectedModuleId, label: "Module", items: _filteredModules.map((m) => m.id).toList(), onChanged: _selectedSemestreId == null ? null : (v) => setState(() => _selectedModuleId = v), display: (id) => _filteredModules.firstWhere((m) => m.id == id).title),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSaving ? null : _onSave,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF113A47), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({required T? value, required String label, required List<T> items, required ValueChanged<T?>? onChanged, required String Function(T) display}) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(display(item), overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? "Requis" : null,
    );
  }
}