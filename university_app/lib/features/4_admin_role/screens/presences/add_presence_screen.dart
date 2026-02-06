// ملف: lib/features/4_admin_role/screens/presences/add_presence_screen.dart
// (النسخة الكاملة والمصححة - الفانكشنز داخل الكلاس)

import 'package:flutter/material.dart';

class AddPresenceScreen extends StatefulWidget {
  const AddPresenceScreen({super.key});

  @override
  State<AddPresenceScreen> createState() => _AddPresenceScreenState();
}

class _AddPresenceScreenState extends State<AddPresenceScreen> {
  // Controllers and Variables
  String? _selectedEtudiant;
  String? _selectedSeance;
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  String? _selectedStatut = 'Présent';

  final _formKey = GlobalKey<FormState>();

  // Colors
  static const Color primaryAppBarColor = Color(0xFF0A4F48);
  static const Color pageBackgroundColor = Color(0xFFF7F7F7);
  static const Color textFieldBorderColor = Color(0xFFDDE2E5);

  // --- دوال اختيار التاريخ والوقت ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() { _selectedDate = picked; });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedStartTime) {
      setState(() { _selectedStartTime = picked; });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? _selectedStartTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedEndTime) {
      setState(() { _selectedEndTime = picked; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryAppBarColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Marquer Présence/Absence', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle('Informations Requises'),
                const SizedBox(height: 15),

                _buildDropdown(label: 'Étudiant *', value: _selectedEtudiant, hint: 'Sélectionner l\'étudiant', items: ['Ahmed Alami', 'Fatima Benali', 'Youssef Cherkaoui'], onChanged: (val) => setState(() => _selectedEtudiant = val)),
                const SizedBox(height: 15),
                _buildDropdown(label: 'Séance / Module *', value: _selectedSeance, hint: 'Sélectionner la séance ou le module', items: ['UML et Analyse (S1)', 'Programmation 2 (S2)', 'Base de données (S3)'], onChanged: (val) => setState(() => _selectedSeance = val)),
                const SizedBox(height: 15),
                _buildDateTimePicker(
                  label: 'Date *',
                  text: _selectedDate == null ? 'Choisir la date' : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                  onTap: () => _selectDate(context),
                  validator: (val) => _selectedDate == null ? 'Veuillez choisir une date' : null,
                ),

                const SizedBox(height: 15),
                _buildTimePicker(
                  label: 'Heure de Début *',
                  text: _selectedStartTime == null ? 'Choisir l\'heure' : _selectedStartTime!.format(context),
                  onTap: () => _selectStartTime(context),
                  validator: (val) => _selectedStartTime == null ? 'Veuillez choisir une heure' : null,
                ),
                const SizedBox(height: 15),
                _buildTimePicker(
                  label: 'Heure de Fin *',
                  text: _selectedEndTime == null ? 'Choisir l\'heure' : _selectedEndTime!.format(context),
                  onTap: () => _selectEndTime(context),
                  validator: (val) => _selectedEndTime == null ? 'Veuillez choisir une heure' : null,
                ),

                const SizedBox(height: 15),
                _buildDropdown(label: 'Statut *', value: _selectedStatut, hint: 'Choisir le statut', items: ['Présent', 'Absent', 'Justifié'], onChanged: (val) => setState(() => _selectedStatut = val)),

                const SizedBox(height: 40),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =================================================================
  // --- [تصحيح] هاد الفانكشنز دابا ولاو لداخل ديال الكلاس ---
  // =================================================================

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  Widget _buildDropdown({required String label, required String? value, required String hint, required List<String> items, required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(
        value: value,
        hint: Text(hint, style: TextStyle(color: Colors.grey[600])),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        decoration: _inputDecoration(label),
        validator: (val) => val == null ? 'Veuillez sélectionner une option' : null
    );
  }

  Widget _buildDateTimePicker({required String label, required String text, required VoidCallback onTap, FormFieldValidator<String>? validator}) {
    return TextFormField(
        readOnly: true,
        controller: TextEditingController(text: text),
        onTap: onTap,
        decoration: _inputDecoration(label).copyWith(
            suffixIcon: const Icon(Icons.calendar_month_outlined, color: Colors.grey)
        ),
        validator: validator
    );
  }

  Widget _buildTimePicker({required String label, required String text, required VoidCallback onTap, FormFieldValidator<String>? validator}) {
    return TextFormField(
        readOnly: true,
        controller: TextEditingController(text: text),
        onTap: onTap,
        decoration: _inputDecoration(label).copyWith(
            suffixIcon: const Icon(Icons.access_time_outlined, color: Colors.grey)
        ),
        validator: validator
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: textFieldBorderColor, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryAppBarColor, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 1.5))
    );
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
              String moduleName = _selectedSeance?.split(' (')[0] ?? 'N/A';

              String startTime = _selectedStartTime!.format(context);
              String endTime = _selectedEndTime!.format(context);
              String heureRange = "$startTime - $endTime";

              final newPresence = {
                "id": DateTime.now().millisecondsSinceEpoch.toString(),
                "etudiant": _selectedEtudiant!,
                "module": moduleName,
                "seance_id": _selectedSeance?.split('(')[1].replaceAll(')', '') ?? 'N/A',
                "date": "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                "statut": _selectedStatut!,
                "details": {
                  "groupe": "N/A",
                  "heure": heureRange
                }
              };
              Navigator.pop(context, newPresence);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires (*)'), backgroundColor: Colors.red));
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryAppBarColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
          ),
          child: const Text('Ajouter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
} // <-- هادي هي النهاية ديال الكلاس _AddPresenceScreenState