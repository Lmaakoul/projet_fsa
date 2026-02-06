import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Models
import 'package:university_app/core/models/departement.dart';
import 'package:university_app/core/models/filiere.dart';
import 'package:university_app/core/models/selection_models.dart'; // SemestreSimple
import 'package:university_app/core/models/module.dart';
import 'package:university_app/core/models/group.dart';
import 'package:university_app/core/models/salle.dart';
import 'package:university_app/core/models/professor.dart';

// Services
import 'package:university_app/core/services/departement_service.dart';
import 'package:university_app/core/services/filiere_service.dart';
import 'package:university_app/core/services/selection_service.dart';
import 'package:university_app/core/services/module_service.dart';
import 'package:university_app/core/services/group_service.dart';
import 'package:university_app/core/services/professor_service.dart';
import 'package:university_app/core/services/salle_service.dart';
import 'package:university_app/core/services/seance_service.dart';
import 'package:university_app/core/services/auth_service.dart';

class AddSeanceScreen extends StatefulWidget {
  // ✅ No token in constructor (handled internally)
  const AddSeanceScreen({super.key});

  @override
  State<AddSeanceScreen> createState() => _AddSeanceScreenState();
}

class _AddSeanceScreenState extends State<AddSeanceScreen> {
  final _formKey = GlobalKey<FormState>();

  // 🛑 Static Lists
  static const List<String> FIXED_NIVEAUX = [
    "LICENCE", "MASTER", "DEUG", "DOCTORAT", "Licence d'excellence", "Master d'excellence",
  ];
  // Display values (French)
  static const List<String> SEANCE_TYPES_DISPLAY = ["COURS", "TD", "TP", "EXAMEN", "RATTRAPAGE"];

  // Services
  late final SelectionService _selectionService = SelectionService();
  late final DepartementService _departementService = DepartementService();
  late final FiliereService _filiereService = FiliereService();
  late final ModuleService _moduleService = ModuleService();
  late final GroupService _groupService = GroupService();
  late final ProfessorService _professorService = ProfessorService();
  late final SalleService _salleService = SalleService();
  late final SeanceService _seanceService = SeanceService();
  late final AuthService _authService = AuthService();

  // Data
  List<Departement> _allDepartements = [];
  List<Filiere> _allFilieres = [];
  List<SemestreSimple> _allSemestres = [];
  List<Module> _allModules = [];
  List<Group> _allGroups = [];
  List<Professor> _allProfessors = [];
  List<Salle> _allSalles = [];
  List<String> _availableNiveaux = [];

  // Selection
  Departement? _selectedDepartement;
  String? _selectedNiveau;
  Filiere? _selectedFiliere;
  SemestreSimple? _selectedSemestre;
  Module? _selectedModule;
  Group? _selectedGroupe;
  Professor? _selectedEnseignant;
  String? _selectedSalleDept;
  Salle? _selectedSalle;
  String? _selectedType;

  // Time & Date
  DateTime? _selectedDate;
  TimeOfDay? _selectedHeureDebut;
  TimeOfDay? _selectedHeureFin;
  final _dateController = TextEditingController();

  String? _token;
  bool _isInitialLoading = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isInitialLoading = true);
    final token = await _authService.getToken();

    if (token == null) {
      if (mounted) setState(() => _isInitialLoading = false);
      return;
    }
    _token = token;

    try {
      final results = await Future.wait([
        _departementService.getAllDepartements(token),
        _filiereService.getAllFilieres(token),
        _moduleService.getAllModules(token),
        _groupService.getAllGroups(token),
        _professorService.getAllProfessors(token),
        _salleService.getAllSalles(token),
        _selectionService.getAllSemestres(token),
      ]);

      if (mounted) {
        setState(() {
          _allDepartements = results[0] as List<Departement>;
          _allFilieres = results[1] as List<Filiere>;
          _allModules = results[2] as List<Module>;
          _allGroups = results[3] as List<Group>;
          _allProfessors = results[4] as List<Professor>;
          _allSalles = results[5] as List<Salle>;
          _allSemestres = results[6] as List<SemestreSimple>;
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      print("Erreur: $e");
      if (mounted) setState(() => _isInitialLoading = false);
    }
  }

  // --- Filtering ---
  List<String> get _uniqueSalleDepartments => _allSalles.map((s) => s.departmentName).toSet().toList();

  List<Salle> get _filteredSalles => _selectedSalleDept == null
      ? []
      : _allSalles.where((s) => s.departmentName == _selectedSalleDept).toList();

  List<Filiere> get _filteredFilieres => _allFilieres.where((f) {
    bool matchesDept = _selectedDepartement == null || f.departmentId == _selectedDepartement!.id;
    bool matchesNiveau = _selectedNiveau == null || f.degreeType.trim().toLowerCase() == _selectedNiveau!.trim().toLowerCase();
    return matchesDept && matchesNiveau;
  }).toList();

  List<Module> get _filteredModules => _allModules.where((m) => m.semesterId == _selectedSemestre?.id).toList();
  List<Group> get _filteredGroups => _allGroups.where((g) => g.moduleId == _selectedModule?.id).toList();

  // --- Handlers ---
  void _onDeptChanged(Departement? d) {
    setState(() {
      _selectedDepartement = d;
      _selectedNiveau = null; _selectedFiliere = null; _selectedSemestre = null; _selectedModule = null; _selectedGroupe = null;
      _availableNiveaux = [];
      if (d != null) {
        final existing = _allFilieres.where((f) => f.departmentId == d.id).map((f) => f.degreeType.trim().toLowerCase()).toSet();
        _availableNiveaux = FIXED_NIVEAUX.where((fix) => existing.contains(fix.trim().toLowerCase())).toList();
      }
    });
  }

  // --- SAVE ---
  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSalle == null || _selectedEnseignant == null || _selectedType == null ||
        _selectedDate == null || _selectedHeureDebut == null || _selectedHeureFin == null ||
        _selectedModule == null || _selectedGroupe == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez remplir tous les champs"), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoading = true);

    // 1. Format Date & Time strictly (Crucial for 500 error)
    final String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final String startStr = "${_selectedHeureDebut!.hour.toString().padLeft(2, '0')}:${_selectedHeureDebut!.minute.toString().padLeft(2, '0')}";
    final String endStr = "${_selectedHeureFin!.hour.toString().padLeft(2, '0')}:${_selectedHeureFin!.minute.toString().padLeft(2, '0')}";

    // 2. Map Type (French -> API Expected English)
    String apiType = _selectedType!;
    if (_selectedType == "COURS") apiType = "LECTURE";
    else if (_selectedType == "EXAMEN") apiType = "EXAM";
    // TD and TP usually stay the same

    print("📤 Sending: $apiType, $dateStr, $startStr - $endStr");

    bool success = await _seanceService.createSeance(
      token: _token!,
      date: dateStr,
      startTime: startStr,
      endTime: endStr,
      type: apiType, // ✅ Send mapped type
      salleId: _selectedSalle!.id,
      moduleId: _selectedModule!.id,
      groupId: _selectedGroupe!.id,
      professorId: _selectedEnseignant!.id,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Séance ajoutée avec succès ✅"), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur serveur (500) - Vérifiez les conflits"), backgroundColor: Colors.red));
      }
    }
  }

  // --- UI Helpers ---
  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (picked != null) setState(() { _selectedDate = picked; _dateController.text = DateFormat('dd/MM/yyyy').format(picked); });
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 8, minute: 30));
    if (picked != null) setState(() => isStart ? _selectedHeureDebut = picked : _selectedHeureFin = picked);
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter une Séance"), backgroundColor: const Color(0xFF0A4F48), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildDropdown(label: "Département", value: _selectedDepartement, items: _allDepartements, display: (d)=>d.name, onChanged: _onDeptChanged),
              if (_selectedDepartement != null) _buildDropdown(label: "Niveau", value: _selectedNiveau, items: _availableNiveaux, display: (s)=>s, onChanged: (v) => setState(() { _selectedNiveau = v; _selectedFiliere = null; })),
              if (_selectedNiveau != null) _buildDropdown(label: "Filière", value: _selectedFiliere, items: _filteredFilieres, display: (f)=>f.name, onChanged: (v) => setState(() { _selectedFiliere = v; _selectedSemestre = null; })),
              if (_selectedFiliere != null) _buildDropdown(label: "Semestre", value: _selectedSemestre, items: _allSemestres.where((s)=>s.filiereId==_selectedFiliere?.id).toList(), display: (s)=>s.nom, onChanged: (v) => setState(() { _selectedSemestre = v; _selectedModule = null; })),
              if (_selectedSemestre != null) _buildDropdown(label: "Module", value: _selectedModule, items: _filteredModules, display: (m)=>m.title, onChanged: (v) => setState(() { _selectedModule = v; _selectedGroupe = null; })),
              if (_selectedModule != null) _buildDropdown(label: "Groupe", value: _selectedGroupe, items: _filteredGroups, display: (g)=>g.name, onChanged: (v) => setState(() => _selectedGroupe = v)),

              const Divider(height: 30),

              _buildDropdown(label: "Type", value: _selectedType, items: SEANCE_TYPES_DISPLAY, display: (s)=>s, onChanged: (v) => setState(() => _selectedType = v)),
              _buildDropdown(label: "Enseignant", value: _selectedEnseignant, items: _allProfessors, display: (p)=>"${p.firstName} ${p.lastName}", onChanged: (v) => setState(() => _selectedEnseignant = v)),
              _buildDropdown(label: "Département (Salle)", value: _selectedSalleDept, items: _uniqueSalleDepartments, display: (s)=>s, onChanged: (v) => setState(() { _selectedSalleDept = v; _selectedSalle = null; })),
              if (_selectedSalleDept != null) _buildDropdown(label: "Salle", value: _selectedSalle, items: _filteredSalles, display: (s)=>"${s.code} (${s.capacity})", onChanged: (v) => setState(() => _selectedSalle = v)),

              const Divider(height: 30),

              TextFormField(controller: _dateController, readOnly: true, decoration: const InputDecoration(labelText: "Date", border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)), onTap: _pickDate),
              const SizedBox(height: 15),
              Row(children: [
                Expanded(child: InkWell(onTap: () => _pickTime(true), child: InputDecorator(decoration: const InputDecoration(labelText: "Début", border: OutlineInputBorder()), child: Text(_selectedHeureDebut?.format(context) ?? "--:--")))),
                const SizedBox(width: 15),
                Expanded(child: InkWell(onTap: () => _pickTime(false), child: InputDecorator(decoration: const InputDecoration(labelText: "Fin", border: OutlineInputBorder()), child: Text(_selectedHeureFin?.format(context) ?? "--:--")))),
              ]),

              const SizedBox(height: 30),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: _isLoading ? null : _onSave,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A4F48), padding: const EdgeInsets.symmetric(vertical: 15)),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Ajouter", style: TextStyle(color: Colors.white, fontSize: 16)),
              ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({required String label, required T? value, required List<T> items, required String Function(T) display, required ValueChanged<T?>? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<T>(
        value: value, isExpanded: true,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15)),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(display(e), overflow: TextOverflow.ellipsis))).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? "Requis" : null,
      ),
    );
  }
}