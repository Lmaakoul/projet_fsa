// ملف: lib/features/4_admin_role/screens/filieres/edit_filiere_screen.dart

import 'package:flutter/material.dart';
import 'package:university_app/core/models/departement.dart';
import 'package:university_app/core/models/filiere.dart';
import 'package:university_app/core/models/selection_models.dart';
import 'package:university_app/core/services/departement_service.dart';
import 'package:university_app/core/services/selection_service.dart';
import 'package:university_app/core/services/filiere_service.dart';

class EditFiliereScreen extends StatefulWidget {
  final String token;
  final Filiere filiere; // Kaystqbl l-Filiere kamla

  const EditFiliereScreen({super.key, required this.token, required this.filiere});

  @override
  State<EditFiliereScreen> createState() => _EditFiliereScreenState();
}

class _EditFiliereScreenState extends State<EditFiliereScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _durationController;

  String? _selectedNiveau;
  String? _selectedDepartementId;

  late final FiliereService _filiereService;
  late final SelectionService _selectionService;
  late final DepartementService _departementService;

  late Future<List<EnumResponse>> _niveauxFuture;
  late Future<List<Departement>> _departementsFuture;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _filiereService = FiliereService();
    _selectionService = SelectionService();
    _departementService = DepartementService();

    // Kan3mro l-form b'l-data l-qdima
    _nameController = TextEditingController(text: widget.filiere.name);
    _codeController = TextEditingController(text: widget.filiere.code);
    _durationController = TextEditingController(text: widget.filiere.durationYears.toString());
    _selectedNiveau = widget.filiere.degreeType;
    _selectedDepartementId = widget.filiere.departmentId;

    _loadDropdowns();
  }

  void _loadDropdowns() {
    _niveauxFuture = _selectionService.getNiveaux(widget.token);
    _departementsFuture = _departementService.getAllDepartements(widget.token);
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedNiveau == null || _selectedDepartementId == null) return;

    setState(() => _isLoading = true);

    bool success = await _filiereService.updateFiliere(
      token: widget.token,
      id: widget.filiere.id, // L-ID l-qdim
      name: _nameController.text,
      code: _codeController.text,
      degreeType: _selectedNiveau!,
      departmentId: _selectedDepartementId!,
      durationYears: int.tryParse(_durationController.text) ?? 0,
    );

    if (mounted) setState(() => _isLoading = false);
    if (mounted && success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier la Filière"),
        backgroundColor: const Color(0xFF113A47),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
          future: Future.wait([_niveauxFuture, _departementsFuture]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text("Erreur de chargement des listes."));
            }

            final List<EnumResponse> niveaux = snapshot.data![0] as List<EnumResponse>;
            final List<Departement> departements = snapshot.data![1] as List<Departement>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Nom de la filière", border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(labelText: "Code", border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Durée (en années)", border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedNiveau,
                      hint: const Text("Niveau"),
                      items: niveaux.map((e) => DropdownMenuItem(value: e.value, child: Text(e.label))).toList(),
                      onChanged: (v) => setState(() => _selectedNiveau = v),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      validator: (v) => v == null ? "Requis" : null,
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartementId,
                      hint: const Text("Département"),
                      items: departements.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _selectedDepartementId = v),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      validator: (v) => v == null ? "Requis" : null,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF113A47),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Enregistrer"),
                    ),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }
}