import 'package:flutter/material.dart';
import 'package:university_app/core/models/salle.dart';
import 'package:university_app/core/models/departement.dart';
import 'package:university_app/core/services/salle_service.dart';
import 'package:university_app/core/services/departement_service.dart';

class EditSalleScreen extends StatefulWidget {
  final String token;
  final Salle salle;
  const EditSalleScreen({super.key, required this.token, required this.salle});

  @override
  State<EditSalleScreen> createState() => _EditSalleScreenState();
}

class _EditSalleScreenState extends State<EditSalleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _buildingController;
  late TextEditingController _capacityController;

  final SalleService _salleService = SalleService();
  final DepartementService _departementService = DepartementService();

  List<Departement> _depts = [];
  Departement? _selectedDept;
  String _selectedType = "Amphithéâtre";
  final List<String> _types = ["Amphithéâtre", "Salle de Cours", "TP", "Salle Informatique", "Séminaire"];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.salle.code);
    _buildingController = TextEditingController(text: widget.salle.building ?? "");
    _capacityController = TextEditingController(text: widget.salle.capacity.toString());
    _selectedType = _mapApiToDisplay(widget.salle.type);
    _loadDepts();
  }

  Future<void> _loadDepts() async {
    try {
      final data = await _departementService.getAllDepartements(widget.token);
      setState(() {
        _depts = data;
        try {
          _selectedDept = data.firstWhere((d) => d.name == widget.salle.departmentName);
        } catch (_) {
          if (data.isNotEmpty) _selectedDept = data.first;
        }
      });
    } catch (_) {}
  }

  String _mapApiToDisplay(String api) {
    switch (api) {
      case "LABORATORY": return "TP";
      case "AMPHITHEATER": return "Amphithéâtre";
      case "CLASSROOM": return "Salle de Cours";
      case "COMPUTER_LAB": return "Salle Informatique";
      case "SEMINAR_ROOM": return "Séminaire";
      default: return "Salle de Cours";
    }
  }

  String _mapDisplayToApi(String display) {
    switch (display) {
      case "TP": return "LABORATORY";
      case "Amphithéâtre": return "AMPHITHEATER";
      case "Salle de Cours": return "CLASSROOM";
      case "Salle Informatique": return "COMPUTER_LAB";
      case "Séminaire": return "SEMINAR_ROOM";
      default: return "CLASSROOM";
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDept == null) return;

    bool success = await _salleService.updateSalle(
      token: widget.token,
      salleId: widget.salle.id,
      roomNumber: _codeController.text,
      building: _buildingController.text,
      capacity: int.tryParse(_capacityController.text) ?? 0,
      roomType: _mapDisplayToApi(_selectedType), // ✅ Correct
      departmentId: _selectedDept!.id,           // ✅ Correct
    );

    if (mounted) {
      if (success) Navigator.pop(context, true);
      else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur modification"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier Salle"), backgroundColor: const Color(0xFF113A47), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _codeController, decoration: const InputDecoration(labelText: "Code", border: OutlineInputBorder())),
              const SizedBox(height: 15),
              DropdownButtonFormField(
                value: _selectedDept,
                decoration: const InputDecoration(labelText: "Département", border: OutlineInputBorder()),
                items: _depts.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
                onChanged: (v) => setState(() => _selectedDept = v),
              ),
              const SizedBox(height: 15),
              TextFormField(controller: _buildingController, decoration: const InputDecoration(labelText: "Bâtiment", border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextFormField(controller: _capacityController, decoration: const InputDecoration(labelText: "Capacité", border: OutlineInputBorder())),
              const SizedBox(height: 15),
              DropdownButtonFormField(
                value: _selectedType,
                decoration: const InputDecoration(labelText: "Type", border: OutlineInputBorder()),
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 30),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _onSave, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF113A47), padding: const EdgeInsets.symmetric(vertical: 15)), child: const Text("Enregistrer", style: TextStyle(color: Colors.white)))),
            ],
          ),
        ),
      ),
    );
  }
}