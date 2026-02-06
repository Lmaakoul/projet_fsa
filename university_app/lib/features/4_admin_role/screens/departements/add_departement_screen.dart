// ملف: lib/features/4_admin_role/screens/departements/add_departement_screen.dart
// (النسخة المصححة - مربوطة مع الـ Backend)

import 'package:flutter/material.dart';
import 'package:university_app/core/services/departement_service.dart';

class AddDepartementScreen extends StatefulWidget {
  final String token;

  const AddDepartementScreen({
    super.key,
    required this.token,
  });

  @override
  State<AddDepartementScreen> createState() => _AddDepartementScreenState();
}

class _AddDepartementScreenState extends State<AddDepartementScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final descriptionController = TextEditingController();

  final DepartementService _departementService = DepartementService();
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return; // Ila l-form maṣ7i7š, kan7bso
    }

    setState(() => _isLoading = true);

    bool success = await _departementService.createDepartement(
      token: widget.token,
      name: nameController.text,
      code: codeController.text,
      description: descriptionController.text,
    );

    if (mounted) setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true); // (Kanrj3o 'true' baš n-refresh-iw l-lista)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Échec de la création. Veuillez réessayer."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un département"),
        backgroundColor: Colors.teal, // (L-App Bar b'l-khdr)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form( // (Zdna Form hna)
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
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                label: _isLoading
                    ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                )
                    : const Text("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}