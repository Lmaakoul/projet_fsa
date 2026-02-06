import 'package:flutter/material.dart';
// Models
import 'package:university_app/core/models/departement.dart';
import 'package:university_app/core/models/filiere.dart';
import 'package:university_app/core/models/semestre.dart';
import 'package:university_app/core/models/module.dart';
import 'package:university_app/core/models/selection_models.dart';

// Services
import 'package:university_app/core/services/departement_service.dart';
import 'package:university_app/core/services/filiere_service.dart';
import 'package:university_app/core/services/semestre_service.dart';
import 'package:university_app/core/services/module_service.dart';
import 'package:university_app/core/services/selection_service.dart';
import 'package:university_app/core/services/auth_service.dart'; // ✅ ضروري

import 'etudiants_screen.dart';

class EtudiantSelectionScreen extends StatefulWidget {
  // ❌ حيدنا token من هنا باش نتهناو من مشاكل الـ arguments
  const EtudiantSelectionScreen({super.key});

  @override
  State<EtudiantSelectionScreen> createState() => _EtudiantSelectionScreenState();
}

class _EtudiantSelectionScreenState extends State<EtudiantSelectionScreen> {
  // Services
  final DepartementService _departementService = DepartementService();
  final FiliereService _filiereService = FiliereService();
  final SemestreService _semestreService = SemestreService();
  final ModuleService _moduleService = ModuleService();
  final SelectionService _selectionService = SelectionService();
  final AuthService _authService = AuthService(); // ✅

  // Data Lists
  List<Departement> _allDepartements = [];
  List<Filiere> _allFilieres = [];
  List<Semestre> _allSemestres = [];
  List<Module> _allModules = [];

  // Filtered Lists
  final List<String> _fixedNiveaux = ["LICENCE", "MASTER", "DEUG", "LP", "DOCTORAT", "Licence d'excellence", "Master d'excellence"];
  List<String> _availableNiveaux = [];
  List<Filiere> _filteredFilieres = [];
  List<Semestre> _filteredSemestres = [];
  List<Module> _filteredModules = [];
  List<GroupeSimple> _groupesList = [];

  // Selected Values
  Departement? _selectedDepartement;
  String? _selectedNiveau;
  Filiere? _selectedFiliere;
  Semestre? _selectedSemestre;
  Module? _selectedModule;
  String? _selectedGroupeId;
  String _selectedGroupeCode = '';

  String? _token; // ✅ المتغير اللي غنخبيو فيه التوكن
  bool _isLoadingInitial = true;
  bool _isLoadingGroupes = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  // 1. دالة لجلب التوكن والبيانات الأولية
  Future<void> _fetchInitialData() async {
    setState(() => _isLoadingInitial = true);

    // ✅ نجبدو التوكن من الذاكرة (SharedPreferences)
    String? savedToken = await _authService.getToken();

    if (savedToken == null || savedToken.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Session expirée, connectez-vous"), backgroundColor: Colors.red));
        setState(() => _isLoadingInitial = false);
      }
      return;
    }

    _token = savedToken; // ✅ سجلنا التوكن

    try {
      // ✅ دابا كنعيطو للبيانات وحنا متأكدين التوكن كاين
      final results = await Future.wait([
        _departementService.getAllDepartements(_token!),
        _filiereService.getAllFilieres(_token!),
        _semestreService.getAllSemestres(_token!),
        _moduleService.getAllModules(_token!),
      ]);

      if (mounted) {
        setState(() {
          _allDepartements = results[0] as List<Departement>;
          _allFilieres = results[1] as List<Filiere>;
          _allSemestres = results[2] as List<Semestre>;
          _allModules = results[3] as List<Module>;
          _isLoadingInitial = false;
        });
      }
    } catch (e) {
      print("❌ Error loading data: $e");
      if (mounted) setState(() => _isLoadingInitial = false);
    }
  }

  // ==========================================================
  //                🔄 المنطق ديال الفلترة (اللي كان ناقصك)
  // ==========================================================

  void _onDepartementChanged(Departement? dept) {
    setState(() {
      _selectedDepartement = dept;
      _selectedNiveau = null; _selectedFiliere = null; _selectedSemestre = null; _selectedModule = null; _selectedGroupeId = null;
      _availableNiveaux = []; _filteredFilieres = []; _filteredSemestres = []; _filteredModules = []; _groupesList = [];

      if (dept != null) {
        final existingNiveaux = _allFilieres
            .where((f) => f.departmentId == dept.id)
            .map((f) => f.degreeType.trim().toLowerCase())
            .toSet();

        _availableNiveaux = _fixedNiveaux
            .where((fixed) => existingNiveaux.contains(fixed.trim().toLowerCase()))
            .toList();
      }
    });
  }

  void _onNiveauChanged(String? niveau) {
    setState(() {
      _selectedNiveau = niveau;
      _selectedFiliere = null; _selectedSemestre = null; _selectedModule = null; _selectedGroupeId = null;
      _filteredFilieres = []; _filteredSemestres = []; _filteredModules = []; _groupesList = [];

      if (niveau != null && _selectedDepartement != null) {
        _filteredFilieres = _allFilieres.where((f) =>
        f.departmentId == _selectedDepartement!.id &&
            f.degreeType.trim().toLowerCase() == niveau.trim().toLowerCase()
        ).toList();
      }
    });
  }

  void _onFiliereChanged(Filiere? filiere) {
    setState(() {
      _selectedFiliere = filiere;
      _selectedSemestre = null; _selectedModule = null; _selectedGroupeId = null;
      _filteredSemestres = []; _filteredModules = []; _groupesList = [];

      if (filiere != null) {
        _filteredSemestres = _allSemestres.where((s) => s.filiereId == filiere.id).toList();
        _filteredSemestres.sort((a, b) => a.semesterNumber.compareTo(b.semesterNumber));
      }
    });
  }

  void _onSemestreChanged(Semestre? semestre) {
    setState(() {
      _selectedSemestre = semestre;
      _selectedModule = null; _selectedGroupeId = null;
      _filteredModules = []; _groupesList = [];

      if (semestre != null) {
        _filteredModules = _allModules.where((m) => m.semesterId == semestre.id).toList();
      }
    });
  }

  Future<void> _onModuleChanged(Module? module) async {
    setState(() {
      _selectedModule = module;
      _selectedGroupeId = null;
      _groupesList = [];
    });

    if (module != null && _token != null) {
      setState(() => _isLoadingGroupes = true);
      try {
        _groupesList = await _selectionService.getGroupesByModule(_token!, module.id);
      } catch(e) {
        print("Erreur groupes: $e");
      }
      if (mounted) setState(() => _isLoadingGroupes = false);
    }
  }

  void _onGroupeChanged(String? groupeId) {
    setState(() {
      _selectedGroupeId = groupeId;
      if (groupeId != null && _groupesList.isNotEmpty) {
        try {
          _selectedGroupeCode = _groupesList.firstWhere((g) => g.id == groupeId).code;
        } catch (_) {
          _selectedGroupeCode = '';
        }
      }
    });
  }

  void _onAfficherEtudiants() {
    if (_selectedGroupeId != null && _selectedFiliere != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EtudiantsScreen(
              groupeId: _selectedGroupeId!,
              groupeCode: _selectedGroupeCode,
              filiereId: _selectedFiliere!.id,
            )
        ),
      );
    }
  }

  // ==========================================================
  //                          UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitial) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text("Sélectionner les Étudiants"),
        backgroundColor: const Color(0xFF0A4F48),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Veuillez sélectionner les critères', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 25),

            _buildDropdown(label: "Département", value: _selectedDepartement, hint: "Choisir...", items: _allDepartements.map((e)=>DropdownMenuItem(value:e, child:Text(e.name))).toList(), onChanged: _onDepartementChanged),
            const SizedBox(height: 15),

            if (_selectedDepartement != null)
              _buildDropdown(label: "Niveau", value: _selectedNiveau, hint: "Choisir...", items: _availableNiveaux.map((e)=>DropdownMenuItem(value:e, child:Text(e))).toList(), onChanged: _onNiveauChanged),
            const SizedBox(height: 15),

            if (_selectedNiveau != null)
              _buildDropdown(label: "Filière", value: _selectedFiliere, hint: "Choisir...", items: _filteredFilieres.map((e)=>DropdownMenuItem(value:e, child:Text(e.name))).toList(), onChanged: _onFiliereChanged),
            const SizedBox(height: 15),

            if (_selectedFiliere != null)
              _buildDropdown(label: "Semestre", value: _selectedSemestre, hint: "Choisir...", items: _filteredSemestres.map((e)=>DropdownMenuItem(value:e, child:Text(e.name))).toList(), onChanged: _onSemestreChanged),
            const SizedBox(height: 15),

            if (_selectedSemestre != null)
              _buildDropdown(label: "Module", value: _selectedModule, hint: "Choisir...", items: _filteredModules.map((e)=>DropdownMenuItem(value:e, child:Text(e.title))).toList(), onChanged: _onModuleChanged),
            const SizedBox(height: 15),

            if (_selectedModule != null)
              _buildDropdown(label: "Groupe", value: _selectedGroupeId, hint: _isLoadingGroupes ? "Chargement..." : "Choisir...", items: _groupesList.map((e)=>DropdownMenuItem(value:e.id, child:Text(e.code))).toList(), onChanged: (v) => _onGroupeChanged(v as String?)),

            const SizedBox(height: 30),

            if (_selectedGroupeId != null)
              ElevatedButton(
                onPressed: _onAfficherEtudiants,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A4F48),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text("Afficher Étudiants"),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({required String label, required T? value, required String hint, required List<DropdownMenuItem<T>> items, required ValueChanged<T?>? onChanged}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      const SizedBox(height: 5),
      DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
          ),
          hint: Text(hint),
          items: items,
          onChanged: onChanged,
          isExpanded: true
      ),
    ]);
  }
}