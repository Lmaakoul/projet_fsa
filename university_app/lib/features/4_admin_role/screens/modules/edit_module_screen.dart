// ملف: lib/features/4_admin_role/screens/modules/edit_module_screen.dart

import 'package:flutter/material.dart';
import 'package:university_app/core/models/semestre.dart';
import 'package:university_app/core/models/professor.dart';
import 'package:university_app/core/models/module.dart';
import 'package:university_app/core/services/semestre_service.dart';
import 'package:university_app/core/services/professor_service.dart';
import 'package:university_app/core/services/module_service.dart';

class EditModuleScreen extends StatefulWidget {
  final String token;
  final Module module;

  const EditModuleScreen({super.key, required this.token, required this.module});

  @override
  State<EditModuleScreen> createState() => _EditModuleScreenState();
}

class _EditModuleScreenState extends State<EditModuleScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _codeController;
  late TextEditingController _creditsController;
  late TextEditingController _passingGradeController;

  late Future<List<Semestre>> _semestresFuture;
  late Future<List<Professor>> _professorsFuture;

  String? _selectedSemestreId;
  late List<String> _selectedProfessorIds;

  final _moduleService = ModuleService();
  final _semestreService = SemestreService();
  final _professorService = ProfessorService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.module.title);
    _codeController = TextEditingController(text: widget.module.code);
    _creditsController = TextEditingController(text: widget.module.credits.toString());
    _passingGradeController = TextEditingController(text: widget.module.passingGrade.toString());
    _selectedSemestreId = widget.module.semesterId;
    _selectedProfessorIds = widget.module.professors.map((p) => p.id).toList();

    _loadDropdowns();
  }

  void _loadDropdowns() {
    _semestresFuture = _semestreService.getAllSemestres(widget.token);
    _professorsFuture = _professorService.getAllProfessors(widget.token);
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSemestreId == null) return;

    setState(() => _isLoading = true);

    bool success = await _moduleService.updateModule(
      token: widget.token,
      id: widget.module.id,
      title: _titleController.text,
      code: _codeController.text,
      semesterId: _selectedSemestreId!,
      credits: int.tryParse(_creditsController.text) ?? 0,
      passingGrade: double.tryParse(_passingGradeController.text) ?? 10.0,
      professorIds: _selectedProfessorIds,
    );

    if (mounted) setState(() => _isLoading = false);
    if (mounted && success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le Module"),
        backgroundColor: const Color(0xFF113A47),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
          future: Future.wait([_semestresFuture, _professorsFuture]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text("Erreur de chargement des listes."));
            }

            final List<Semestre> semestres = snapshot.data![0] as List<Semestre>;
            final List<Professor> professors = snapshot.data![1] as List<Professor>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: "Titre du Module", border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(labelText: "Code", border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _creditsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Crédits", border: OutlineInputBorder()),
                            validator: (v) => v!.isEmpty ? "Requis" : null,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            controller: _passingGradeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Note de passage", border: OutlineInputBorder()),
                            validator: (v) => v!.isEmpty ? "Requis" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedSemestreId,
                      hint: const Text("Semestre"),
                      isExpanded: true,
                      items: semestres.map((s) => DropdownMenuItem(value: s.id, child: Text("${s.name} (${s.filiereName ?? ''})", overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _selectedSemestreId = v),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      validator: (v) => v == null ? "Requis" : null,
                    ),
                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      hint: const Text("Ajouter un Enseignant..."),
                      items: professors.map((p) => DropdownMenuItem(value: p.id, child: Text(p.fullName))).toList(),
                      onChanged: (v) {
                        if (v != null && !_selectedProfessorIds.contains(v)) {
                          setState(() => _selectedProfessorIds.add(v));
                        }
                      },
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    Wrap(
                      spacing: 8.0,
                      children: _selectedProfessorIds.map((profId) {
                        final profName = professors.firstWhere((p) => p.id == profId, orElse: () => Professor(id: '', fullName: 'N/A', email: '', departmentId: '', enabled: false, firstName: '', lastName: '')).fullName;
                        return Chip(
                          label: Text(profName),
                          onDeleted: () => setState(() => _selectedProfessorIds.remove(profId)),
                        );
                      }).toList(),
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