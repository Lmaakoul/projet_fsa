import 'package:flutter/material.dart';
import 'package:university_app/core/models/group.dart';
import 'package:university_app/core/models/departement.dart';
import 'package:university_app/core/models/filiere.dart';
import 'package:university_app/core/models/semestre.dart';
import 'package:university_app/core/models/module.dart';
import 'package:university_app/core/services/departement_service.dart';
import 'package:university_app/core/services/filiere_service.dart';
import 'package:university_app/core/services/semestre_service.dart';
import 'package:university_app/core/services/module_service.dart';
import 'package:university_app/core/services/group_service.dart';

class EditGroupScreen extends StatefulWidget {
  final String token;
  final Group group;

  const EditGroupScreen({super.key, required this.token, required this.group});

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _codeController; // 🛑 1. الكنترولر
  late TextEditingController _capacityController;

  // Services
  late final DepartementService _deptService;
  late final FiliereService _filiereService;
  late final SemestreService _semestreService;
  late final ModuleService _moduleService;
  late final GroupService _groupService;

  static const List<String> FIXED_NIVEAUX = ["LICENCE", "MASTER", "DEUG", "LP", "DOCTORAT", "Licence d'excellence", "Master d'excellence"];
  List<Departement> _allDepartements = [];
  List<Filiere> _allFilieres = [];
  List<Semestre> _allSemestres = [];
  List<Module> _allModules = [];

  List<String> _availableNiveaux = [];
  List<Semestre> _filteredSemestres = [];
  List<Module> _filteredModules = [];

  Departement? _selectedDepartement;
  String? _selectedNiveau;
  Filiere? _selectedFiliere;
  String? _selectedSemestreId;
  String? _selectedModuleId;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _changeModuleMode = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.name);
    _codeController = TextEditingController(text: widget.group.code ?? ''); // 🛑 تهيئة الكنترولر
    _capacityController = TextEditingController(text: widget.group.maxCapacity.toString());

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
    _codeController.dispose();
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

  // --- Cascade Logic ---
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

  void _onNiveauChanged(String? n) => setState(() { _selectedNiveau = n; _selectedFiliere = null; _selectedSemestreId = null; _selectedModuleId = null; });

  void _onFiliereChanged(Filiere? f) {
    setState(() {
      _selectedFiliere = f; _selectedSemestreId = null; _selectedModuleId = null;
      if (f != null) _filteredSemestres = _allSemestres.where((s) => s.filiereId == f.id).toList();
    });
  }

  void _onSemestreChanged(String? sId) {
    setState(() {
      _selectedSemestreId = sId; _selectedModuleId = null;
      if (sId != null) _filteredModules = _allModules.where((m) => m.semesterId == sId).toList();
    });
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final String finalModuleId = (_changeModuleMode && _selectedModuleId != null)
        ? _selectedModuleId!
        : widget.group.moduleId!;

    setState(() => _isSaving = true);

    bool success = await _groupService.updateGroup(
      token: widget.token,
      groupId: widget.group.id,
      name: _nameController.text,
      code: _codeController.text, // 🛑 2. تمرير الكود هنا لإصلاح الخطأ
      capacity: int.tryParse(_capacityController.text) ?? 0,
      moduleId: finalModuleId,
    );

    if (mounted) setState(() => _isSaving = false);
    if (mounted && success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le Groupe", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF113A47),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Nom du Groupe", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Requis" : null
              ),
              const SizedBox(height: 15),

              // 🛑 3. حقل إدخال الكود في الواجهة
              TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: "Code du Groupe", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Requis" : null
              ),
              const SizedBox(height: 15),

              TextFormField(
                  controller: _capacityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Capacité", border: OutlineInputBorder())
              ),
              const SizedBox(height: 25),

              Text("Module Actuel : ${widget.group.moduleTitle ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),

              SwitchListTile(
                title: const Text("Changer le module ?"),
                value: _changeModuleMode,
                activeColor: const Color(0xFF113A47),
                onChanged: (val) => setState(() => _changeModuleMode = val),
              ),

              if (_changeModuleMode) ...[
                const Divider(),
                _buildDropdown<Departement>(value: _selectedDepartement, label: "Département", items: _allDepartements, onChanged: _onDepartementChanged, display: (d) => d.name),
                const SizedBox(height: 10),
                _buildDropdown<String>(value: _selectedNiveau, label: "Niveau", items: _availableNiveaux, onChanged: _selectedDepartement == null ? null : _onNiveauChanged, display: (s) => s),
                const SizedBox(height: 10),
                _buildDropdown<Filiere>(value: _selectedFiliere, label: "Filière", items: _filteredFilieres, onChanged: _selectedNiveau == null ? null : _onFiliereChanged, display: (f) => f.name),
                const SizedBox(height: 10),
                _buildDropdown<String>(value: _selectedSemestreId, label: "Semestre", items: _filteredSemestres.map((s)=>s.id).toList(), onChanged: _selectedFiliere == null ? null : _onSemestreChanged, display: (id) => _filteredSemestres.firstWhere((s)=>s.id==id).name),
                const SizedBox(height: 10),
                _buildDropdown<String>(value: _selectedModuleId, label: "Nouveau Module", items: _filteredModules.map((m)=>m.id).toList(), onChanged: _selectedSemestreId == null ? null : (v)=>setState(()=>_selectedModuleId=v), display: (id) => _filteredModules.firstWhere((m)=>m.id==id).title),
              ],

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onSave,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF113A47), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Enregistrer les modifications"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Filiere> get _filteredFilieres {
    if (_selectedDepartement == null || _selectedNiveau == null) return [];
    final norm = _selectedNiveau!.trim().toLowerCase();
    return _allFilieres.where((f) => f.departmentId == _selectedDepartement!.id && f.degreeType.trim().toLowerCase() == norm).toList();
  }

  Widget _buildDropdown<T>({required T? value, required String label, required List<T> items, required ValueChanged<T?>? onChanged, required String Function(T) display}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<T>(
        value: value, isExpanded: true, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(display(item), overflow: TextOverflow.ellipsis))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}