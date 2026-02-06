import 'package:flutter/material.dart';
import 'package:university_app/core/models/departement.dart';
import 'package:university_app/core/services/salle_service.dart';
import 'package:university_app/core/services/departement_service.dart';
import 'package:university_app/core/services/auth_service.dart';

class AddSalleScreen extends StatefulWidget {
  const AddSalleScreen({super.key});

  @override
  State<AddSalleScreen> createState() => _AddSalleScreenState();
}

class _AddSalleScreenState extends State<AddSalleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();
  final _buildingController = TextEditingController();
  final _capacityController = TextEditingController();

  final SalleService _salleService = SalleService();
  final DepartementService _departementService = DepartementService();
  final AuthService _authService = AuthService();

  String? _token;
  bool _isLoading = false;
  bool _isLoadingData = true;
  List<Departement> _departmentsList = [];
  Departement? _selectedDept;

  String _selectedDisplayType = "TP";
  final List<String> _displayTypes = ["Amphithéâtre", "Salle de Cours", "TP", "Salle Informatique", "Séminaire"];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = await _authService.getToken();
    if (token != null) {
      _token = token;
      try {
        final depts = await _departementService.getAllDepartements(token);
        if (mounted) setState(() => _departmentsList = depts);
      } catch (e) {
        print(e);
      }
    }
    if (mounted) setState(() => _isLoadingData = false);
  }

  // ✅ MAP TP -> LABORATORY
  String _mapTypeToApi(String val) {
    switch (val) {
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
    if (_selectedDept == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Département requis")));
      return;
    }

    setState(() => _isLoading = true);

    // ✅ FIXED: Sending departmentId and roomType
    bool success = await _salleService.createSalle(
      token: _token!,
      roomNumber: _codeController.text,
      building: _buildingController.text,
      capacity: int.tryParse(_capacityController.text) ?? 0,
      roomType: _mapTypeToApi(_selectedDisplayType), // ✅ Correct
      departmentId: _selectedDept!.id,               // ✅ Correct
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur ajout (Vérifiez les données)"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter Salle"), backgroundColor: const Color(0xFF113A47), foregroundColor: Colors.white),
      body: _isLoadingData ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _codeController, decoration: const InputDecoration(labelText: "Code", border: OutlineInputBorder()), validator: (v)=>v!.isEmpty?"Requis":null),
              const SizedBox(height: 15),
              DropdownButtonFormField(
                value: _selectedDept,
                decoration: const InputDecoration(labelText: "Département", border: OutlineInputBorder()),
                items: _departmentsList.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
                onChanged: (v) => setState(() => _selectedDept = v),
              ),
              const SizedBox(height: 15),
              TextFormField(controller: _buildingController, decoration: const InputDecoration(labelText: "Bâtiment", border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextFormField(controller: _capacityController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Capacité", border: OutlineInputBorder())),
              const SizedBox(height: 15),
              DropdownButtonFormField(
                value: _selectedDisplayType,
                items: _displayTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedDisplayType = v!),
                decoration: const InputDecoration(labelText: "Type", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 30),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isLoading ? null : _onSave, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF113A47), padding: const EdgeInsets.symmetric(vertical: 15)), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Ajouter", style: TextStyle(color: Colors.white)))),
            ],
          ),
        ),
      ),
    );
  }
}