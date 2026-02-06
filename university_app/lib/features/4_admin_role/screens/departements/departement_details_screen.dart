// ملف: lib/features/4_admin_role/screens/departements/departement_details_screen.dart
// (النسخة المصححة - مربوطة بـ API PUT)

import 'package:flutter/material.dart';
import 'package:university_app/core/models/departement.dart';
import 'package:university_app/core/services/departement_service.dart';

class DepartementDetailsScreen extends StatefulWidget {

  final Departement departement;
  final String token;

  const DepartementDetailsScreen({
    super.key,
    required this.departement,
    required this.token,
  });

  @override
  State<DepartementDetailsScreen> createState() => _DepartementDetailsScreenState();
}

class _DepartementDetailsScreenState extends State<DepartementDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController codeController;
  late TextEditingController descriptionController;

  final DepartementService _departementService = DepartementService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.departement.name);
    codeController = TextEditingController(text: widget.departement.code);
    descriptionController = TextEditingController(text: widget.departement.description ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    bool success = await _departementService.updateDepartement(
      token: widget.token,
      id: widget.departement.id, // L-ID l-qdim
      name: nameController.text, // L-ism l-jdid
      code: codeController.text, // L-code l-jdid
      description: descriptionController.text, // L-description l-jdid
    );

    if (mounted) setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true); // (Kanrj3o 'true' baš n-refresh-iw l-lista)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Échec de la modification. Veuillez réessayer."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A4F48); // (L-App Bar b'l-zrq)

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le département"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _onSave,
            tooltip: 'Enregistrer',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nom du département (Obligatoire)"),
                validator: (value) => (value == null || value.isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(labelText: "Code (Obligatoire)"),
                validator: (value) => (value == null || value.isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description (Optionnel)"),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                onPressed: _isLoading ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                label: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text("Enregistrer les modifications"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}