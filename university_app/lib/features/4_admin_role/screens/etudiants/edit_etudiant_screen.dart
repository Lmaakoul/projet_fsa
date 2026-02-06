import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:university_app/core/models/student.dart';
import 'package:university_app/core/services/student_service.dart';
import 'package:university_app/core/models/selection_models.dart';
import 'package:university_app/core/services/selection_service.dart';

class EditEtudiantScreen extends StatefulWidget {
  final String token;
  final Student studentToEdit;

  const EditEtudiantScreen({
    super.key,
    required this.token,
    required this.studentToEdit,
  });

  @override
  State<EditEtudiantScreen> createState() => _EditEtudiantScreenState();
}

class _EditEtudiantScreenState extends State<EditEtudiantScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Controllers ---
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cneController = TextEditingController();
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // --- Services ---
  late final StudentService _studentService;
  late final SelectionService _selectionService;

  // --- Data & State ---
  List<FiliereSimple> _filieresList = [];
  List<GroupSimple> _groupsList = [];
  final List<String> _niveaux = ["DEUG", "LICENCE", "LP", "MASTER", "DOCTORAT"];

  String? _selectedNiveau;
  String? _selectedFiliereId;
  String? _selectedGroupId;

  bool _isLoading = false;
  bool _isLoadingDetails = true;
  bool _isLoadingFilieres = false;
  bool _isLoadingGroups = false;

  // --- Colors (Theme Prof) ---
  // نفس اللون الأخضر الغامق المستخدم في واجهة الأستاذ
  static const Color primaryColor = Color(0xFF0A4F48);
  static const Color pageBackgroundColor = Color(0xFFF7F7F7);
  static const Color cardBackgroundColor = Colors.white;
  static const Color borderColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _studentService = StudentService();
    _selectionService = SelectionService();

    // 1. تعبئة البيانات الأولية
    _emailController.text = widget.studentToEdit.email;
    _cneController.text = widget.studentToEdit.cne;
    _selectedFiliereId = widget.studentToEdit.filiereId;

    // 2. تحميل التفاصيل الكاملة
    _loadFullStudentDetails();
  }

  Future<void> _loadFullStudentDetails() async {
    try {
      final fullStudent = await _studentService.getStudentById(widget.token, widget.studentToEdit.id);
      if (fullStudent != null && mounted) {
        setState(() {
          _firstNameController.text = fullStudent.firstName ?? "";
          _lastNameController.text = fullStudent.lastName ?? "";
          _cinController.text = fullStudent.cin ?? "";
          _dateController.text = fullStudent.dateOfBirth ?? "";

          if (fullStudent.filiereId != null) {
            _selectedFiliereId = fullStudent.filiereId;
            // محاولة تخمين المستوى (اختياري) أو تركه ليختاره المستخدم
            // _onNiveauChanged("LICENCE");
            _fetchGroups(fullStudent.filiereId!);
          }
        });
      }
    } catch (e) {
      print("⚠️ Error loading details: $e");
    } finally {
      if (mounted) setState(() => _isLoadingDetails = false);
    }
  }

  // --- Dropdown Logic ---
  Future<void> _onNiveauChanged(String? niveau) async {
    if (niveau == null) return;
    setState(() {
      _selectedNiveau = niveau;
      _isLoadingFilieres = true;
      _filieresList = [];
      _selectedFiliereId = null;
      _selectedGroupId = null;
    });

    try {
      final filieres = await _selectionService.getFilieresByNiveau(widget.token, niveau);
      if (mounted) setState(() => _filieresList = filieres);
    } finally {
      if (mounted) setState(() => _isLoadingFilieres = false);
    }
  }

  Future<void> _onFiliereChanged(String? filiereId) async {
    if (filiereId == null) return;
    setState(() {
      _selectedFiliereId = filiereId;
      _selectedGroupId = null;
    });
    await _fetchGroups(filiereId);
  }

  Future<void> _fetchGroups(String filiereId) async {
    setState(() => _isLoadingGroups = true);
    try {
      final groups = await _studentService.getGroupsByFiliere(widget.token, filiereId);
      if (mounted) setState(() => _groupsList = groups);
    } finally {
      if (mounted) setState(() => _isLoadingGroups = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime(2000),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor, // لون التقويم
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFiliereId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Veuillez sélectionner une filière"), backgroundColor: Colors.orange)
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = await _studentService.updateStudent(
      token: widget.token,
      studentId: widget.studentToEdit.id,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      cne: _cneController.text,
      cin: _cinController.text,
      dateOfBirth: _dateController.text,
      filiereId: _selectedFiliereId!,
      groupId: _selectedGroupId,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Échec de la mise à jour"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor, // ✅ لون البروفيسور
        elevation: 0,
        title: const Text('Modifier un Étudiant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)
        ),
      ),
      body: _isLoadingDetails
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- القسم الأول: المعلومات الشخصية ---
              _buildSectionTitle("Informations Personnelles"),
              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                  children: [
                    _buildTextField(controller: _firstNameController, label: 'Prénom (First Name)'),
                    const SizedBox(height: 15),
                    _buildTextField(controller: _lastNameController, label: 'Nom (Last Name)'),
                    const SizedBox(height: 15),
                    _buildTextField(controller: _emailController, label: 'Email', isEmail: true),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(controller: _cneController, label: 'CNE')),
                        const SizedBox(width: 15),
                        Expanded(child: _buildTextField(controller: _cinController, label: 'CIN')),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      cursorColor: primaryColor,
                      decoration: _inputDecoration("Date de Naissance").copyWith(
                        suffixIcon: const Icon(Icons.calendar_today, color: primaryColor),
                      ),
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // --- القسم الثاني: المعلومات الأكاديمية ---
              _buildSectionTitle("Informations Académiques"),
              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                  children: [
                    // A. Niveau
                    DropdownButtonFormField<String>(
                      value: _selectedNiveau,
                      hint: const Text("Sélectionner le Niveau"),
                      items: _niveaux.map((lvl) => DropdownMenuItem(value: lvl, child: Text(lvl))).toList(),
                      onChanged: _onNiveauChanged,
                      decoration: _inputDecoration("Niveau"),
                      icon: const Icon(Icons.arrow_drop_down, color: primaryColor),
                    ),
                    const SizedBox(height: 15),

                    // B. Filiere
                    _isLoadingFilieres
                        ? const Center(child: LinearProgressIndicator(color: primaryColor))
                        : DropdownButtonFormField<String>(
                      value: (_filieresList.isNotEmpty && _filieresList.any((f) => f.id == _selectedFiliereId))
                          ? _selectedFiliereId
                          : null,
                      hint: const Text("Sélectionner la Filière *"),
                      items: _filieresList.map((f) => DropdownMenuItem(value: f.id, child: Text(f.nom, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: _onFiliereChanged,
                      decoration: _inputDecoration("Filière *"),
                      validator: (v) => (_selectedFiliereId == null) ? "Requis" : null,
                      isExpanded: true,
                      icon: const Icon(Icons.school, color: primaryColor),
                    ),
                    const SizedBox(height: 15),

                    // C. Group
                    _isLoadingGroups
                        ? const Center(child: LinearProgressIndicator(color: primaryColor))
                        : DropdownButtonFormField<String>(
                      value: _selectedGroupId,
                      hint: const Text("Assigner à un Groupe (Optionnel)"),
                      items: _groupsList.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                      onChanged: (v) => setState(() => _selectedGroupId = v),
                      decoration: _inputDecoration("Groupe"),
                      isExpanded: true,
                      icon: const Icon(Icons.group, color: primaryColor),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // زر الحفظ
              ElevatedButton(
                onPressed: _isLoading ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, // ✅ لون البروفيسور
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: primaryColor.withOpacity(0.4),
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('ENREGISTRER LES MODIFICATIONS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Styles Helper ---

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, color: primaryColor, margin: const EdgeInsets.only(right: 8)),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor)),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: const Color(0xFFF9F9F9), // لون خلفية خفيف جداً داخل الحقل
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEEEEEE), width: 1)),

      // ✅ التركيز (Focus) يأخذ اللون الأخضر الخاص بالبروفيسور
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryColor, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 1)),

      floatingLabelStyle: const TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      cursorColor: primaryColor, // ✅ لون المؤشر
      decoration: _inputDecoration(label),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Requis';
        if (isEmail && !value.contains('@')) return 'Email invalide';
        return null;
      },
    );
  }
}