// ملف: lib/features/4_admin_role/screens/filieres/add_filiere_screen.dart
// (النسخة المصححة: تستخدم قائمة Niveaux ثابتة ومستقلة)

import 'package:flutter/material.dart';
import 'package:university_app/core/models/departement.dart';
import 'package:university_app/core/services/departement_service.dart';
import 'package:university_app/core/services/filiere_service.dart';
// 🛑 لم نعد نحتاج SelectionService لاستدعاء getNiveaux
// import 'package:university_app/core/services/selection_service.dart';

class AddFiliereScreen extends StatefulWidget {
  final String token;
  const AddFiliereScreen({super.key, required this.token});

  @override
  State<AddFiliereScreen> createState() => _AddFiliereScreenState();
}

class _AddFiliereScreenState extends State<AddFiliereScreen> {
  final _formKey = GlobalKey<FormState>();

  // 🛑 القائمة الثابتة للمستويات (Niveaux) المطلوبة
  static const List<String> FIXED_NIVEAUX = [
    "LICENCE", // 💡 نستخدم الحروف الكبيرة هنا لمطابقة ما يتوقعه الـ API (وفق Swagger)
    "MASTER",
    "DEUG",
    "LP",
    "DOCTORAT",
    // يجب إضافة "Licence d'excellence" و "Master d'excellence"
    // إذا كانتا ضمن القيم الفعلية التي يتوقعها الـ API عند الإرسال.
    "Licence d'excellence",
    "Master d'excellence",
  ];

  // Controllers
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _durationController = TextEditingController();

  // Dropdowns
  String? _selectedNiveau;
  String? _selectedDepartementId;

  // Services
  late final FiliereService _filiereService;
  late final DepartementService _departementService;

  // Lists
  // 🛑 أصبحنا نحتاج فقط قائمة الأقسام (Departements)
  late Future<List<Departement>> _departementsFuture;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _filiereService = FiliereService();
    _departementService = DepartementService();
    _loadDepartments();
  }

  // 🛑 دالة تحميل الأقسام فقط
  void _loadDepartments() {
    _departementsFuture = _departementService.getAllDepartements(widget.token);
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedNiveau == null || _selectedDepartementId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sélectionnez un niveau et un département")));
      return;
    }

    // 💡 التحقق من حقل المدة
    int? duration = int.tryParse(_durationController.text);
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez entrer une durée valide en années.")));
      return;
    }

    setState(() => _isLoading = true);

    // 💡 نرسل القيمة الثابتة المختارة
    bool success = await _filiereService.createFiliere(
      token: widget.token,
      name: _nameController.text,
      code: _codeController.text,
      degreeType: _selectedNiveau!, // نستخدم القيمة الثابتة هنا
      departmentId: _selectedDepartementId!,
      durationYears: duration,
    );

    if (mounted) setState(() => _isLoading = false);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Filière ajoutée avec succès!"), backgroundColor: Colors.green));
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Échec de l'ajout de la filière."), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter une Filière"),
        backgroundColor: const Color(0xFF113A47),
        foregroundColor: Colors.white,
      ),
      // 🛑 FutureBuilder الآن ينتظر تحميل الأقسام فقط
      body: FutureBuilder<List<Departement>>(
          future: _departementsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              print("Erreur: ${snapshot.error}");
              return const Center(child: Text("Erreur de chargement des départements."));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Aucun département trouvé."));
            }

            final List<Departement> departements = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // --- Champs الإدخال ---
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Nom de la filière", border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(labelText: "Code (ex: SMI)", border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Durée (en années, ex: 3)", border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.isEmpty || int.tryParse(v) == null || int.parse(v) <= 0) ? "Veuillez entrer une durée valide" : null,
                    ),
                    const SizedBox(height: 20),

                    // 🛑 Dropdown NIVEAU (يستخدم القائمة الثابتة)
                    DropdownButtonFormField<String>(
                      value: _selectedNiveau,
                      hint: const Text("Niveau (DEUG, Licence...)"),
                      // 💡 نستخدم القائمة الثابتة مباشرة
                      items: FIXED_NIVEAUX.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _selectedNiveau = v),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      validator: (v) => v == null ? "Requis" : null,
                    ),
                    const SizedBox(height: 15),

                    // Dropdown DÉPARTEMENT
                    DropdownButtonFormField<String>(
                      value: _selectedDepartementId,
                      hint: const Text("Département"),
                      items: departements.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _selectedDepartementId = v),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      validator: (v) => v == null ? "Requis" : null,
                    ),
                    const SizedBox(height: 30),

                    // Bouton Enregistrer
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