import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Services
import 'package:university_app/core/services/departement_service.dart' as dept_service;
import 'package:university_app/core/services/filiere_service.dart';
import 'package:university_app/core/services/module_service.dart';
import 'package:university_app/core/services/group_service.dart';
import 'package:university_app/core/services/auth_service.dart';

// Models
import 'package:university_app/core/models/departement.dart';
import 'package:university_app/core/models/filiere.dart';
import 'package:university_app/core/models/module.dart';
import 'package:university_app/core/models/group.dart';

// Screens
import 'add_seance_screen.dart';

class SeancesScreen extends StatefulWidget {
  const SeancesScreen({super.key});

  @override
  State<SeancesScreen> createState() => _SeancesScreenState();
}

class _SeancesScreenState extends State<SeancesScreen> {
  // --- Constants ---
  // اللون الأساسي الموحد (الأزرق الغامق)
  final Color primaryColor = const Color(0xFF190B60);

  static const List<String> FIXED_NIVEAUX = [
    "LICENCE", "MASTER", "DEUG", "LP", "DOCTORAT", "Licence d'excellence", "Master d'excellence",
  ];

  // --- Services ---
  late final dept_service.DepartementService _departementService;
  late final FiliereService _filiereService;
  late final ModuleService _moduleService;
  late final GroupService _groupService;
  late final AuthService _authService;

  String? _token;

  // --- Data Sources ---
  List<Departement> _allDepartements = [];
  List<Filiere> _allFilieres = [];
  List<Module> _allModules = [];

  // --- Selected Values ---
  Departement? _selectedDepartement;
  String? _selectedNiveau;
  Filiere? _selectedFiliere;
  Module? _selectedModule;
  Group? _selectedGroup;

  // --- UI States ---
  bool _isLoadingInitialData = true;
  bool _isLoadingGroups = false;
  String? _initialLoadError;

  // Computed Lists
  List<String> _availableNiveaux = [];
  List<Group> _filteredGroups = [];

  @override
  void initState() {
    super.initState();
    // Initialize Services
    _departementService = dept_service.DepartementService();
    _filiereService = FiliereService();
    _moduleService = ModuleService();
    _groupService = GroupService();
    _authService = AuthService();

    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoadingInitialData = true);

    // 1. Get Token
    final token = await _authService.getToken();
    if (token == null) {
      if (mounted) {
        setState(() {
          _initialLoadError = "Session expirée. Veuillez vous reconnecter.";
          _isLoadingInitialData = false;
        });
      }
      return;
    }
    _token = token;

    try {
      // 2. Fetch Basic Data in Parallel
      final futures = await Future.wait([
        _departementService.getAllDepartements(_token!),
        _filiereService.getAllFilieres(_token!),
        _moduleService.getAllModules(_token!),
      ]);

      if (mounted) {
        setState(() {
          _allDepartements = futures[0] as List<Departement>;
          _allFilieres = futures[1] as List<Filiere>;
          _allModules = futures[2] as List<Module>;
          _isLoadingInitialData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialLoadError = "Erreur de chargement: ${e.toString()}";
          _isLoadingInitialData = false;
        });
      }
    }
  }

  // --- Logic Filtering ---

  List<Filiere> get _filteredFilieres {
    if (_selectedDepartement == null || _selectedNiveau == null) return [];
    final normalizedNiveau = _selectedNiveau!.trim().toLowerCase();

    return _allFilieres.where((f) {
      bool matchesDept = f.departmentId == _selectedDepartement!.id;
      bool matchesNiveau = f.degreeType.trim().toLowerCase() == normalizedNiveau;
      return matchesDept && matchesNiveau;
    }).toList();
  }

  List<Module> get _filteredModules {
    // يمكنك هنا إضافة شرط لفلترة الموديولات حسب الشعبة إذا كان الـ API يدعم ذلك
    // حالياً نعيد كل الموديولات
    if (_selectedFiliere == null) return [];
    return _allModules;
  }

  Future<void> _loadGroupsByModule() async {
    if (_selectedModule == null || _token == null) return;

    setState(() => _isLoadingGroups = true);
    try {
      final groups = await _groupService.getGroupsByModuleId(_token!, _selectedModule!.id);
      if (mounted) {
        setState(() {
          _filteredGroups = groups;
          _isLoadingGroups = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingGroups = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur groupes: $e")));
    }
  }

  // --- Event Handlers ---

  void _onDepartementChanged(Departement? val) {
    setState(() {
      _selectedDepartement = val;
      // Reset dependent fields
      _selectedNiveau = null;
      _selectedFiliere = null;
      _selectedModule = null;
      _selectedGroup = null;
      _filteredGroups = [];

      // Calculate available levels for this department
      if (val != null) {
        final existingLevels = _allFilieres
            .where((f) => f.departmentId == val.id)
            .map((f) => f.degreeType.trim().toLowerCase())
            .toSet();

        _availableNiveaux = FIXED_NIVEAUX
            .where((fix) => existingLevels.contains(fix.trim().toLowerCase()))
            .toList();
      } else {
        _availableNiveaux = [];
      }
    });
  }

  void _onNiveauChanged(String? val) {
    setState(() {
      _selectedNiveau = val;
      _selectedFiliere = null;
      _selectedModule = null;
      _selectedGroup = null;
      _filteredGroups = [];
    });
  }

  void _onFiliereChanged(Filiere? val) {
    setState(() {
      _selectedFiliere = val;
      _selectedModule = null;
      _selectedGroup = null;
      _filteredGroups = [];
    });
  }

  void _onModuleChanged(Module? val) {
    setState(() {
      _selectedModule = val;
      _selectedGroup = null;
      _filteredGroups = [];
    });
    if (val != null) {
      _loadGroupsByModule();
    }
  }

  // --- Main Action ---
  void _navigateToSeancesList() {
    if (_selectedModule == null || _selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Veuillez sélectionner un module et un groupe"),
            backgroundColor: Colors.orange,
          )
      );
      return;
    }

    // ✅✅✅ THIS IS THE FIX: Using pushNamed to go to the list ✅✅✅
    Navigator.pushNamed(
      context,
      '/seances_list', // Must match the route in main.dart
      arguments: {
        'moduleId': _selectedModule!.id,
        'groupId': _selectedGroup!.id,
        'moduleName': _selectedModule!.title,
        'groupName': _selectedGroup!.name,
      },
    );
  }

  // --- Helper Widgets ---

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) displayItem,
    required ValueChanged<T?>? onChanged,
    bool isEnabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: DropdownButtonFormField<T>(
              value: value,
              hint: Text(
                  'Choisir...',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14)
              ),
              isExpanded: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    displayItem(item),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: isEnabled ? onChanged : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitialData) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(backgroundColor: primaryColor, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_initialLoadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Erreur"), backgroundColor: Colors.red),
        body: Center(child: Text(_initialLoadError!)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Sélectionner pour Séances"),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),

      // Floating Action Button to Add Seance
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSeanceScreen()),
          );
        },
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Text
            const Text(
              "Veuillez filtrer pour trouver les séances",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 25),

            // 1. Departement
            _buildDropdown<Departement>(
              label: 'Département',
              value: _selectedDepartement,
              items: _allDepartements,
              displayItem: (d) => d.name,
              onChanged: _onDepartementChanged,
            ),

            // 2. Niveau
            if (_selectedDepartement != null)
              _buildDropdown<String>(
                label: 'Niveau',
                value: _selectedNiveau,
                items: _availableNiveaux,
                displayItem: (s) => s,
                onChanged: _onNiveauChanged,
              ),

            // 3. Filiere
            if (_selectedNiveau != null)
              _buildDropdown<Filiere>(
                label: 'Filière',
                value: _selectedFiliere,
                items: _filteredFilieres,
                displayItem: (f) => f.name,
                onChanged: _onFiliereChanged,
              ),

            // 4. Module
            if (_selectedFiliere != null)
              _buildDropdown<Module>(
                label: 'Module',
                value: _selectedModule,
                items: _filteredModules,
                displayItem: (m) => m.title,
                onChanged: _onModuleChanged,
              ),

            // 5. Group
            if (_selectedModule != null)
              _isLoadingGroups
                  ? const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              )
                  : _buildDropdown<Group>(
                label: 'Groupe',
                value: _selectedGroup,
                items: _filteredGroups,
                displayItem: (g) => g.name,
                onChanged: (v) => setState(() => _selectedGroup = v),
              ),

            const SizedBox(height: 40),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: _navigateToSeancesList, // ✅ Calls the fixed function
                child: const Text(
                  'Afficher Séances',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40), // Bottom spacing
          ],
        ),
      ),
    );
  }
}