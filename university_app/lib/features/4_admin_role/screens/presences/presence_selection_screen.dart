// ملف: lib/features/4_admin_role/screens/presences/presence_selection_screen.dart
// (النسخة النهائية المصححة - استخدام قائمة مستويات ثابتة)

import 'package:flutter/material.dart';
import 'presences_screen.dart';
// Models
import 'package:university_app/core/models/departement.dart';
import 'package:university_app/core/models/filiere.dart';
import 'package:university_app/core/models/group.dart';
// Services
import 'package:university_app/core/services/departement_service.dart';
import 'package:university_app/core/services/filiere_service.dart';
import 'package:university_app/core/services/group_service.dart';

class PresenceSelectionScreen extends StatefulWidget {
  final String token;

  const PresenceSelectionScreen({super.key, required this.token});

  @override
  State<PresenceSelectionScreen> createState() => _PresenceSelectionScreenState();
}

class _PresenceSelectionScreenState extends State<PresenceSelectionScreen> {
  final _formKey = GlobalKey<FormState>();

  // 🛑 1. القائمة الثابتة للمستويات (الحل للمشكلة)
  static const List<String> FIXED_NIVEAUX = [
    "LICENCE", "MASTER", "DEUG", "LP", "DOCTORAT", "Licence d'excellence", "Master d'excellence",
  ];

  // Services
  late final DepartementService _departementService;
  late final FiliereService _filiereService;
  late final GroupService _groupService;

  // Data Lists
  List<Departement> _allDepartements = [];
  List<Filiere> _allFilieres = [];
  List<Group> _allGroups = []; // سنجلب كل المجموعات ونفلترها محلياً

  // Selected Values
  Departement? _selectedDepartement;
  String? _selectedNiveau;
  Filiere? _selectedFiliere;
  Group? _selectedGroupe;

  // Computed/Filtered Lists
  List<String> _availableNiveaux = [];
  List<Filiere> _filteredFilieres = [];
  List<Group> _filteredGroupes = [];

  bool _isLoading = true;
  String? _initialLoadError;

  static const Color primaryAppBarColor = Color(0xFF0A4F48);
  static const Color pageBackgroundColor = Color(0xFFF7F7F7);
  static const Color textFieldBorderColor = Color(0xFFDDE2E5);

  @override
  void initState() {
    super.initState();
    _departementService = DepartementService();
    _filiereService = FiliereService();
    _groupService = GroupService();
    _fetchInitialData();
  }

  // -------------------------
  // Data Fetching
  // -------------------------
  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    _initialLoadError = null;

    try {
      final results = await Future.wait([
        _departementService.getAllDepartements(widget.token),
        _filiereService.getAllFilieres(widget.token),
        _groupService.getAllGroups(widget.token), // نجلب كل المجموعات للفلترة
      ]);

      if (mounted) {
        setState(() {
          _allDepartements = results[0] as List<Departement>;
          _allFilieres = results[1] as List<Filiere>;
          _allGroups = results[2] as List<Group>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _initialLoadError = "Erreur de connexion: $e";
        });
      }
    }
  }

  // -------------------------
  // Logic Cascade
  // -------------------------

  // 1. Dept Changed
  void _onDepartementChanged(Departement? dept) {
    setState(() {
      _selectedDepartement = dept;
      // Reset
      _selectedNiveau = null; _selectedFiliere = null; _selectedGroupe = null;
      _availableNiveaux = []; _filteredFilieres = []; _filteredGroupes = [];

      if (dept != null) {
        // Calculate available Niveaux
        final existingNiveaux = _allFilieres
            .where((f) => f.departmentId == dept.id)
            .map((f) => f.degreeType.trim().toLowerCase())
            .toSet();

        _availableNiveaux = FIXED_NIVEAUX
            .where((fixed) => existingNiveaux.contains(fixed.trim().toLowerCase()))
            .toList();
      }
    });
  }

  // 2. Niveau Changed
  void _onNiveauChanged(String? niveau) {
    setState(() {
      _selectedNiveau = niveau;
      // Reset
      _selectedFiliere = null; _selectedGroupe = null;
      _filteredFilieres = []; _filteredGroupes = [];

      if (niveau != null && _selectedDepartement != null) {
        final normNiveau = niveau.trim().toLowerCase();
        _filteredFilieres = _allFilieres.where((f) =>
        f.departmentId == _selectedDepartement!.id &&
            f.degreeType.trim().toLowerCase() == normNiveau
        ).toList();
      }
    });
  }

  // 3. Filiere Changed
  void _onFiliereChanged(Filiere? filiere) {
    setState(() {
      _selectedFiliere = filiere;
      _selectedGroupe = null;
      _filteredGroupes = [];

      if (filiere != null) {
        // 🛑 هنا التحدي: كيف نربط المجموعة بالشعبة مباشرة؟
        // المجموعات ترتبط بـ Modules، والـ Modules ترتبط بـ Semestres، والـ Semestres ترتبط بـ Filiere.
        // للتبسيط، سنعرض كل المجموعات، أو يمكنك إضافة فلترة ذكية بالاسم إذا كانت تتبع نمط تسمية معين.
        // الحل الأفضل: عرض كل المجموعات المتاحة، أو إضافة خطوات (Semestre -> Module) كما في الشاشات السابقة.

        // في هذا الكود، سأعرض جميع المجموعات كحل مؤقت سريع،
        // ولكن يفضل في المستقبل إضافة خطوات Semestre و Module لفلترة دقيقة.
        _filteredGroupes = _allGroups;
      }
    });
  }

  // 4. Submit
  void _onSubmit() {
    if (_formKey.currentState!.validate() && _selectedGroupe != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PresencesScreen(
              selectedDepartement: _selectedDepartement!.name,
              selectedNiveau: _selectedNiveau!,
              selectedFiliere: _selectedFiliere!.name,
              selectedGroupe: _selectedGroupe!.name,
              token: widget.token,
            )
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs'), backgroundColor: Colors.red),
      );
    }
  }

  // -------------------------
  // UI
  // -------------------------
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryAppBarColor,
        title: const Text('Sélectionner pour Présences', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Veuillez sélectionner les critères', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              const SizedBox(height: 30),

              // 1. Département
              _buildDropdown<Departement>(
                label: 'Département',
                value: _selectedDepartement,
                items: _allDepartements,
                display: (d) => d.name,
                onChanged: _onDepartementChanged,
              ),
              const SizedBox(height: 20),

              // 2. Niveau
              if (_selectedDepartement != null) ...[
                _buildDropdown<String>(
                  label: 'Niveau',
                  value: _selectedNiveau,
                  items: _availableNiveaux,
                  display: (s) => s,
                  onChanged: _onNiveauChanged,
                ),
                const SizedBox(height: 20),
              ],

              // 3. Filière
              if (_selectedNiveau != null) ...[
                _buildDropdown<Filiere>(
                  label: 'Filière',
                  value: _selectedFiliere,
                  items: _filteredFilieres,
                  display: (f) => f.name,
                  onChanged: _onFiliereChanged,
                ),
                const SizedBox(height: 20),
              ],

              // 4. Groupe
              if (_selectedFiliere != null) ...[
                _buildDropdown<Group>(
                  label: 'Groupe',
                  value: _selectedGroupe,
                  items: _filteredGroupes,
                  display: (g) => g.name,
                  onChanged: (g) => setState(() => _selectedGroupe = g),
                ),
                const SizedBox(height: 40),
              ],

              if (_selectedGroupe != null)
                ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryAppBarColor, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Afficher Présences', style: TextStyle(fontSize: 16)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) display,
    required ValueChanged<T?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label *', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          hint: Text('Choisir le ${label.toLowerCase()}', style: TextStyle(color: Colors.grey[600])),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(display(item), overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: textFieldBorderColor, width: 1.5)),
          ),
          validator: (val) => val == null ? 'Requis' : null,
        ),
      ],
    );
  }
}