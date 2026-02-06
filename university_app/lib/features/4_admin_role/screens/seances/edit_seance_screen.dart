// ملف: lib/features/4_admin_role/screens/seances/edit_seance_screen.dart
// (النسخة المصححة - كتصلح المشكل ديال 'null')

import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // (ما غنحتاجوش هادا دابا)

class EditSeanceScreen extends StatefulWidget {
  final Map<String, dynamic> seance;
  const EditSeanceScreen({super.key, required this.seance});

  @override
  State<EditSeanceScreen> createState() => _EditSeanceScreenState();
}

class _EditSeanceScreenState extends State<EditSeanceScreen> {
  // Controllers and Variables
  String? _selectedModule;
  String? _selectedEnseignant;
  String? _selectedGroupe;
  late TextEditingController _salleController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedHeureDebut;
  TimeOfDay? _selectedHeureFin;

  final _formKey = GlobalKey<FormState>();

  // Colors
  static const Color primaryAppBarColor = Color(0xFF0A4F48);
  static const Color pageBackgroundColor = Color(0xFFF7F7F7);
  static const Color textFieldBorderColor = Color(0xFFDDE2E5);

  // ==========================================
  // 1. هادي هي الليستات لي غنخدمو بيها
  // ==========================================
  final List<String> _modulesList = ['UML et Analyse', 'Programmation 2', 'Base de données', 'Algorithmique 1', 'Sécurité', 'Physique 2', 'Botanique'];
  final List<String> _enseignantsList = ['Hicham El Amrani', 'Fatima Zahra', 'Ahmed Karim', 'Amina Kabbaj', 'Karim Bennani', 'Nadia Alami'];
  final List<String> _groupesList = ['GL1', 'GL2', 'RI1', 'RI2', 'PHY-M1', 'BIO-G1', 'BIO-G2'];

  @override
  void initState() {
    super.initState();

    // ==========================================
    // 2. هادا هو التعديل لي كيصلح المشكل
    // ==========================================

    // كنتأكدو أن القيمة كاينة فالليستة، إلا ما كانتش، كنرجعو null
    String? module = widget.seance['module'] as String?;
    _selectedModule = _modulesList.contains(module) ? module : null;

    String? enseignant = widget.seance['enseignant'] as String?;
    _selectedEnseignant = _enseignantsList.contains(enseignant) ? enseignant : null;

    String? groupe = widget.seance['groupe'] as String?;
    _selectedGroupe = _groupesList.contains(groupe) ? groupe : null;

    // كنتأكدو أن النص ماشي null
    _salleController = TextEditingController(text: widget.seance['salle'] ?? '');

    // --- تحويل التاريخ والوقت (مع التأكد من null) ---
    try {
      final dateString = widget.seance['date'] as String?;
      if (dateString != null && dateString.isNotEmpty) {
        List<String> dateParts = dateString.split('/');
        if (dateParts.length == 3) {
          _selectedDate = DateTime(int.parse(dateParts[2]), int.parse(dateParts[1]), int.parse(dateParts[0]));
        }
      }
    } catch(e) { _selectedDate = null; print("Error parsing date: $e");}

    try {
      final timePartsDebutStr = widget.seance['heureDebut'] as String?;
      if (timePartsDebutStr != null && timePartsDebutStr.isNotEmpty) {
        List<String> timePartsDebut = timePartsDebutStr.split(':');
        if (timePartsDebut.length == 2) {
          _selectedHeureDebut = TimeOfDay(hour: int.parse(timePartsDebut[0]), minute: int.parse(timePartsDebut[1]));
        }
      }

      final timePartsFinStr = widget.seance['heureFin'] as String?;
      if (timePartsFinStr != null && timePartsFinStr.isNotEmpty) {
        List<String> timePartsFin = timePartsFinStr.split(':');
        if (timePartsFin.length == 2) {
          _selectedHeureFin = TimeOfDay(hour: int.parse(timePartsFin[0]), minute: int.parse(timePartsFin[1]));
        }
      }
    } catch(e) { _selectedHeureDebut = null; _selectedHeureFin = null; print("Error parsing time: $e");}
    // ==========================================
  }


  @override
  void dispose() {
    _salleController.dispose();
    super.dispose();
  }

  // --- دوال اختيار التاريخ والوقت ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030)); if (picked != null && picked != _selectedDate) { setState(() { _selectedDate = picked; }); }
  }
  Future<void> _selectTime(BuildContext context, bool isDebut) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: (isDebut ? _selectedHeureDebut : _selectedHeureFin) ?? TimeOfDay.now()); if (picked != null) { setState(() { if (isDebut) _selectedHeureDebut = picked; else _selectedHeureFin = picked; }); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryAppBarColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Modifier la Séance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle('Détails de la Séance'),
                const SizedBox(height: 15),

                // ==========================================
                // 3. كنستعملو الليستات الجديدة هنا
                // ==========================================
                _buildDropdown(label: 'Module *', value: _selectedModule, hint: 'Sélectionner le module', items: _modulesList, onChanged: (val) => setState(() => _selectedModule = val)),
                const SizedBox(height: 15),
                _buildDropdown(label: 'Enseignant *', value: _selectedEnseignant, hint: 'Sélectionner l\'enseignant', items: _enseignantsList, onChanged: (val) => setState(() => _selectedEnseignant = val)),
                const SizedBox(height: 15),
                _buildDropdown(label: 'Groupe *', value: _selectedGroupe, hint: 'Sélectionner le groupe', items: _groupesList, onChanged: (val) => setState(() => _selectedGroupe = val)),
                // ==========================================

                const SizedBox(height: 15),
                _buildTextField(controller: _salleController, label: 'Salle *', validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null),
                const SizedBox(height: 15),

                // (اختيار التاريخ والوقت كيبقى كيفما هو)
                _buildDateTimePicker(label: 'Date *', text: _selectedDate == null ? 'Choisir la date' : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}", onTap: () => _selectDate(context), validator: (val) => _selectedDate == null ? 'Veuillez choisir une date' : null),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: _buildDateTimePicker(label: 'Heure Début *', text: _selectedHeureDebut == null ? 'Choisir' : _selectedHeureDebut!.format(context), onTap: () => _selectTime(context, true), validator: (val) => _selectedHeureDebut == null ? 'Requis' : null)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildDateTimePicker(label: 'Heure Fin *', text: _selectedHeureFin == null ? 'Choisir' : _selectedHeureFin!.format(context), onTap: () => _selectTime(context, false), validator: (val) => _selectedHeureFin == null ? 'Requis' : null)),
                  ],
                ),

                const SizedBox(height: 40),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- (ويدجتس مساعدة كتبقى كيفما هي) ---
  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87));
  }
  Widget _buildTextField({required TextEditingController controller, required String label, FormFieldValidator<String>? validator, TextInputType? keyboardType}) {
    return TextFormField(controller: controller, keyboardType: keyboardType, decoration: _inputDecoration(label), validator: validator);
  }
  Widget _buildDropdown({required String label, required String? value, required String hint, required List<String> items, required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(value: value, hint: Text(hint, style: TextStyle(color: Colors.grey[600])), items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: onChanged, decoration: _inputDecoration(label), validator: (val) => val == null ? 'Veuillez sélectionner une option' : null);
  }
  Widget _buildDateTimePicker({required String label, required String text, required VoidCallback onTap, FormFieldValidator<String>? validator}) {
    return TextFormField(readOnly: true, controller: TextEditingController(text: text), onTap: onTap, decoration: _inputDecoration(label).copyWith(suffixIcon: const Icon(Icons.calendar_month_outlined, color: Colors.grey)), validator: validator);
  }
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(labelText: label, labelStyle: TextStyle(color: Colors.grey[700], fontSize: 14), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), filled: true, fillColor: Colors.white, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: textFieldBorderColor, width: 1.5)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryAppBarColor, width: 1.5)), errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 1.5)), focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 1.5)));
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler', style: TextStyle(color: Colors.grey, fontSize: 16))),
        const SizedBox(width: 15),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final updatedSeance = {
                "id": widget.seance['id'],
                "module": _selectedModule!,
                "enseignant": _selectedEnseignant!,
                "groupe": _selectedGroupe!,
                "salle": _salleController.text,
                "date": "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                "heureDebut": _selectedHeureDebut!.format(context),
                "heureFin": _selectedHeureFin!.format(context),
              };
              Navigator.pop(context, updatedSeance);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires (*)'), backgroundColor: Colors.red),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryAppBarColor, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Enregistrer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}