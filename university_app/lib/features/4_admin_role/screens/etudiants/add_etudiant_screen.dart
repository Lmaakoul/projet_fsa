import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:university_app/core/models/selection_models.dart';
import 'package:university_app/core/services/selection_service.dart';
import 'package:university_app/core/services/student_service.dart';
// لا نحتاج لـ GroupService هنا لأننا سنستخدم StudentService للربط
// import 'package:university_app/core/services/group_service.dart';

class AddEtudiantScreen extends StatefulWidget {
  final String token;

  const AddEtudiantScreen({
    super.key,
    required this.token,
  });

  @override
  State<AddEtudiantScreen> createState() => _AddEtudiantScreenState();
}

class _AddEtudiantScreenState extends State<AddEtudiantScreen> {
  final _formKey = GlobalKey<FormState>();

  // القائمة الثابتة (كما طلبت)
  static const List<String> FIXED_NIVEAUX = [
    "LICENCE",
    "MASTER",
    "DEUG",
    "LP",
    "DOCTORAT",
    "Licence d'excellence",
    "Master d'excellence",
  ];

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cneController = TextEditingController();
  final _cinController = TextEditingController();
  final _passwordController = TextEditingController(text: "fsa123456");
  final _dateController = TextEditingController();

  // Services
  late final SelectionService _selectionService;
  late final StudentService _studentService;

  // Data Lists
  List<FiliereSimple> _filieresList = [];
  List<SemestreSimple> _semestresList = [];
  List<ModuleSimple> _modulesList = [];
  List<GroupeSimple> _groupesList = [];

  // Selection Variables
  String? _selectedNiveau;
  String? _selectedFiliereId;
  String? _selectedSemestreId;
  String? _selectedModuleId;
  String? _selectedGroupeId;

  // Loading States
  bool _isLoadingFilieres = false;
  bool _isLoadingSemestres = false;
  bool _isLoadingModules = false;
  bool _isLoadingGroupes = false;
  bool _isLoading = false;

  static const Color primaryAppBarColor = Color(0xFF0A4F48);
  static const Color pageBackgroundColor = Color(0xFFF7F7F7);
  static const Color textFieldBorderColor = Color(0xFFDDE2E5);

  @override
  void initState() {
    super.initState();
    _studentService = StudentService();
    _selectionService = SelectionService();
    // تحديد تاريخ افتراضي
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 365 * 18)));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _cneController.dispose();
    _cinController.dispose();
    _passwordController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // --- Logic Cascade ---

  Future<void> _onNiveauChanged(String? newValue) async {
    if (newValue == null) return;
    setState(() {
      _selectedNiveau = newValue;
      _filieresList = []; _selectedFiliereId = null;
      _semestresList = []; _selectedSemestreId = null;
      _modulesList = []; _selectedModuleId = null;
      _groupesList = []; _selectedGroupeId = null;
      _isLoadingFilieres = true;
    });

    try {
      _filieresList = await _selectionService.getFilieresByNiveau(widget.token, newValue);
    } catch (e) {
      print("Erreur chargement filieres: $e");
    }

    setState(() => _isLoadingFilieres = false);
  }

  Future<void> _onFiliereChanged(String? newValue) async {
    if (newValue == null) return;
    setState(() {
      _selectedFiliereId = newValue;
      _semestresList = []; _selectedSemestreId = null;
      _modulesList = []; _selectedModuleId = null;
      _groupesList = []; _selectedGroupeId = null;
      _isLoadingSemestres = true;
    });
    try {
      _semestresList = await _selectionService.getSemestresByFiliere(widget.token, newValue);
    } catch (e) { print(e); }
    setState(() => _isLoadingSemestres = false);
  }

  Future<void> _onSemestreChanged(String? newValue) async {
    if (newValue == null) return;
    setState(() {
      _selectedSemestreId = newValue;
      _modulesList = []; _selectedModuleId = null;
      _groupesList = []; _selectedGroupeId = null;
      _isLoadingModules = true;
    });
    try {
      _modulesList = await _selectionService.getModulesBySemestre(widget.token, newValue);
    } catch (e) { print(e); }
    setState(() => _isLoadingModules = false);
  }

  Future<void> _onModuleChanged(String? newValue) async {
    if (newValue == null) return;
    setState(() {
      _selectedModuleId = newValue;
      _groupesList = []; _selectedGroupeId = null;
      _isLoadingGroupes = true;
    });
    try {
      _groupesList = await _selectionService.getGroupesByModule(widget.token, newValue);
    } catch (e) { print(e); }
    setState(() => _isLoadingGroupes = false);
  }

  void _onGroupeChanged(String? newValue) {
    setState(() => _selectedGroupeId = newValue);
  }

  // --- Date Picker ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // --- Save Action ---
  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate() || _selectedFiliereId == null || _selectedGroupeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs (y compris les sélections)"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 1️⃣ الخطوة الأولى: إنشاء الطالب
    String? newStudentId = await _studentService.createStudent(
      token: widget.token,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      cne: _cneController.text,
      cin: _cinController.text,
      dateOfBirth: _dateController.text,
      filiereId: _selectedFiliereId!,
      password: _passwordController.text,
    );

    // 2️⃣ الخطوة الثانية: ربط الطالب بالمجموعة باستخدام StudentService
    if (newStudentId != null) {
      // ✅✅✅ التصحيح هنا: استخدام assignStudentToGroup بدلاً من enrollStudentsInGroup
      bool assigned = await _studentService.assignStudentToGroup(
        token: widget.token,
        studentId: newStudentId,     // ID الطالب الجديد
        groupId: _selectedGroupeId!, // ID المجموعة المختارة
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (assigned) {
          // نجاح كامل
          Navigator.pop(context, true);
        } else {
          // الطالب أنشئ لكن فشل ربطه بالمجموعة
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Étudiant créé, mais échec de l'affectation au groupe."), backgroundColor: Colors.orange),
          );
          Navigator.pop(context, true); // نغلق الصفحة لأن الطالب تم إنشاؤه على أي حال
        }
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de la création. (Vérifiez CNE/Email uniques)"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryAppBarColor,
        title: const Text('Ajouter un Étudiant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(controller: _firstNameController, label: 'Prénom (First Name)'),
              const SizedBox(height: 15),
              _buildTextField(controller: _lastNameController, label: 'Nom (Last Name)'),
              const SizedBox(height: 15),
              _buildTextField(controller: _emailController, label: 'Email (Obligatoire)', isEmail: true),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildTextField(controller: _cneController, label: 'CNE (Obligatoire)')),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField(controller: _cinController, label: 'CIN (Obligatoire)')),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: _inputDecoration("Date de Naissance").copyWith(
                  suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                ),
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              const SizedBox(height: 15),
              _buildTextField(controller: _passwordController, label: 'Mot de passe (Défaut)', isPassword: true),
              const SizedBox(height: 25),

              // --- Dropdowns ---

              _buildDropdownString(
                label: 'Niveau *',
                value: _selectedNiveau,
                hint: 'Choisir le niveau',
                items: FIXED_NIVEAUX,
                onChanged: _onNiveauChanged,
              ),
              const SizedBox(height: 15),

              _buildDropdownSimple(
                label: 'Filière *',
                value: _selectedFiliereId,
                hint: _isLoadingFilieres ? 'Chargement...' : 'Choisir la filière',
                items: _filieresList,
                onChanged: _selectedNiveau == null ? null : _onFiliereChanged,
              ),
              const SizedBox(height: 15),

              _buildDropdownSimple(
                label: 'Semestre *',
                value: _selectedSemestreId,
                hint: _isLoadingSemestres ? 'Chargement...' : 'Choisir le semestre',
                items: _semestresList,
                onChanged: _selectedFiliereId == null ? null : _onSemestreChanged,
              ),
              const SizedBox(height: 15),

              _buildDropdownSimple(
                label: 'Module *',
                value: _selectedModuleId,
                hint: _isLoadingModules ? 'Chargement...' : 'Choisir le module',
                items: _modulesList,
                onChanged: _selectedSemestreId == null ? null : _onModuleChanged,
              ),
              const SizedBox(height: 15),

              _buildDropdownSimple(
                label: 'Groupe *',
                value: _selectedGroupeId,
                hint: _isLoadingGroupes ? 'Chargement...' : 'Choisir le groupe',
                items: _groupesList,
                onChanged: _selectedModuleId == null ? null : _onGroupeChanged,
                isGroupe: true,
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryAppBarColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Enregistrer', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: textFieldBorderColor, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryAppBarColor, width: 1.5)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, bool isPassword = false, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: _inputDecoration(label),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Champ requis';
        if (isEmail && !value.contains('@')) return 'Email invalide';
        return null;
      },
    );
  }

  Widget _buildDropdownString({
    required String label, required String? value, required String hint,
    required List<String> items, required ValueChanged<String?>? onChanged
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      isExpanded: true,
      decoration: _inputDecoration(label),
      validator: (val) => val == null ? 'Requis' : null,
    );
  }

  Widget _buildDropdownSimple({
    required String label, required String? value, required String hint,
    required List<dynamic> items, required ValueChanged<String?>? onChanged,
    bool isGroupe = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item.id,
          child: Text(isGroupe ? (item as GroupeSimple).code : item.nom, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
      isExpanded: true,
      decoration: _inputDecoration(label),
      validator: (val) => val == null ? 'Requis' : null,
    );
  }
}