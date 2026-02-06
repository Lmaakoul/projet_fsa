// ملف: lib/features/4_admin_role/screens/semestres/edit_semestre_screen.dart

import 'package:flutter/material.dart';
import 'package:university_app/core/models/semestre.dart';
import 'package:university_app/core/services/semestre_service.dart';
// 🛑 Importation des dépendances pour les Dropdowns
import 'package:university_app/core/models/selection_models.dart';
import 'package:university_app/core/services/selection_service.dart';
import '../../../../core/services/departement_service.dart';
import '../../../../core/services/filiere_service.dart';
import '../../../../core/models/departement.dart';
import '../../../../core/models/filiere.dart';

class EditSemestreScreen extends StatefulWidget {
  final String token;
  final Semestre semestre;

  const EditSemestreScreen({super.key, required this.token, required this.semestre});

  @override
  State<EditSemestreScreen> createState() => _EditSemestreScreenState();
}

class _EditSemestreScreenState extends State<EditSemestreScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _academicYearController;
  late TextEditingController _semesterNumberController;

  // 🛑 حالة Dropdowns الجديدة
  Departement? _selectedDepartement;
  String? _selectedNiveau;
  Filiere? _selectedFiliere;

  // الخدمات وقوائم البيانات
  late final SemestreService _semestreService;
  late final DepartementService _departementService;
  late final FiliereService _filiereService;
  late final SelectionService _selectionService;

  List<EnumResponse> _niveauxOptions = [];
  List<Departement> _allDepartements = [];
  List<Filiere> _allFilieres = [];

  // حالة التحميل
  bool _isLoadingInitialData = true;
  bool _isSaving = false;
  String? _initialLoadError;

  @override
  void initState() {
    super.initState();
    _semestreService = SemestreService();
    _departementService = DepartementService();
    _filiereService = FiliereService();
    _selectionService = SelectionService();

    // تهيئة الـ Controllers بقيم الفصل الدراسي الحالية
    _nameController = TextEditingController(text: widget.semestre.name);
    _academicYearController = TextEditingController(text: widget.semestre.academicYear);
    _semesterNumberController = TextEditingController(text: widget.semestre.semesterNumber.toString());

    // 🛑 جلب البيانات الأولية وتهيئة القيم المحددة
    _fetchInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _academicYearController.dispose();
    _semesterNumberController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------
  // Data Loading: جلب البيانات الأولية وتهيئة الاختيارات
  // -----------------------------------------------------------
  Future<void> _fetchInitialData() async {
    setState(() => _isLoadingInitialData = true);

    try {
      // 1. جلب البيانات
      _allDepartements = await _departementService.getAllDepartements(widget.token);
      _niveauxOptions = await _selectionService.getNiveaux(widget.token);
      _allFilieres = await _filiereService.getAllFilieres(widget.token);

      // 2. تهيئة الاختيارات بناءً على بيانات الـ Semestre الحالية

      // نجد الشعبة الحالية أولاً (باستخدام ID)
      final currentFiliere = _allFilieres.firstWhere(
              (f) => f.id == widget.semestre.filiereId,
          orElse: () => Filiere(id: '', name: 'N/A', code: '', degreeType: 'N/A', durationYears: 0) // Placeholder
      );

      // إذا وجدنا الشعبة
      if (currentFiliere.id.isNotEmpty) {
        _selectedFiliere = currentFiliere;
        _selectedNiveau = currentFiliere.degreeType;

        // نجد القسم بناءً على ID الشعبة
        _selectedDepartement = _allDepartements.firstWhere(
              (d) => d.id == currentFiliere.departmentId,
          orElse: () => _allDepartements.first, // Fallback
        );
      }


    } catch (e) {
      _initialLoadError = "Erreur de chargement des données des filières: ${e.toString()}";
    } finally {
      if (mounted) {
        setState(() => _isLoadingInitialData = false);
      }
    }
  }

  // -----------------------------------------------------------
  // Filtering Logic (نفس منطق شاشة الإضافة)
  // -----------------------------------------------------------
  List<Filiere> get _filteredFilieres {
    Iterable<Filiere> filieres = _allFilieres;

    if (_selectedDepartement != null) {
      filieres = filieres.where(
            (f) => f.departmentId == _selectedDepartement!.id,
      );
    }

    if (_selectedNiveau != null) {
      filieres = filieres.where(
            (f) => f.degreeType == _selectedNiveau,
      );
    }

    return filieres.toList();
  }

  // -----------------------------------------------------------
  // Handlers for Dropdown changes
  // -----------------------------------------------------------
  void _onDepartementChanged(Departement? newValue) {
    setState(() {
      _selectedDepartement = newValue;
      _selectedNiveau = null;
      _selectedFiliere = null;
    });
  }

  void _onNiveauChanged(String? newValue) {
    setState(() {
      _selectedNiveau = newValue;
      _selectedFiliere = null;
    });
  }


  // -----------------------------------------------------------
  // Save Logic
  // -----------------------------------------------------------
  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFiliere == null || _selectedFiliere!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez sélectionner une filière valide.")));
      return;
    }

    setState(() => _isSaving = true);

    final String? result = await _semestreService.updateSemestre(
      token: widget.token,
      id: widget.semestre.id,
      name: _nameController.text,
      academicYear: _academicYearController.text,
      semesterNumber: int.parse(_semesterNumberController.text),
      filiereId: _selectedFiliere!.id!,
    );

    if (mounted) setState(() => _isSaving = false);

    if (mounted) {
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Semestre mis à jour avec succès!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result), backgroundColor: Colors.red),
        );
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
        appBar: AppBar(title: const Text("Modifier le Semestre")),
        body: Center(child: Text('Erreur: $_initialLoadError', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le Semestre"),
        backgroundColor: const Color(0xFF113A47),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nom", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _academicYearController,
                decoration: const InputDecoration(labelText: "Année Académique", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _semesterNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Numéro", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 20),

              // 🛑 1. DROPDOWN Département
              _buildDepartementDropdown(),
              const SizedBox(height: 15),

              // 🛑 2. DROPDOWN Niveau
              _buildNiveauDropdown(),
              const SizedBox(height: 15),

              // 🛑 3. DROPDOWN Filière
              _buildFiliereDropdown(),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isSaving ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF113A47),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Enregistrer les Modifications"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // Dropdown Widgets (منقولة ومعدلة من شاشة الإضافة)
  // -----------------------------------------------------------

  Widget _buildDepartementDropdown() {
    return DropdownButtonFormField<Departement>(
      decoration: const InputDecoration(labelText: "Département", border: OutlineInputBorder()),
      value: _selectedDepartement,
      items: _allDepartements.map((Departement dept) {
        return DropdownMenuItem<Departement>(
          value: dept,
          child: Text(dept.name),
        );
      }).toList(),
      onChanged: _onDepartementChanged,
      validator: (value) => value == null ? 'Champ requis' : null,
    );
  }

  Widget _buildNiveauDropdown() {
    final isNiveauEnabled = _selectedDepartement != null;

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: "Niveau", border: OutlineInputBorder()),
      value: _selectedNiveau,
      hint: const Text('Sélectionner un Niveau'),
      items: isNiveauEnabled
          ? _niveauxOptions.map((e) => DropdownMenuItem(value: e.value, child: Text(e.label))).toList()
          : [],
      onChanged: isNiveauEnabled ? _onNiveauChanged : null,
      validator: (value) => value == null ? 'Champ requis' : null,
    );
  }

  Widget _buildFiliereDropdown() {
    final availableFilieres = _filteredFilieres;
    final isFiliereEnabled = _selectedDepartement != null && _selectedNiveau != null;

    return DropdownButtonFormField<Filiere>(
      decoration: const InputDecoration(labelText: "Filière", border: OutlineInputBorder()),
      value: _selectedFiliere,
      hint: Text(
        isFiliereEnabled && availableFilieres.isEmpty
            ? 'Aucune filière disponible'
            : 'Sélectionner une Filière',
      ),
      items: isFiliereEnabled
          ? availableFilieres.map((Filiere filiere) {
        return DropdownMenuItem<Filiere>(
          value: filiere,
          child: Text(filiere.name),
        );
      }).toList()
          : [],
      onChanged: isFiliereEnabled
          ? (Filiere? newValue) {
        setState(() => _selectedFiliere = newValue);
      }
          : null,
      validator: (value) => value == null ? 'Champ requis' : null,
    );
  }
}