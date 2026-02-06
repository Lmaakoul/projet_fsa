import 'package:flutter/material.dart';

class PresenceFilterSheet extends StatefulWidget {
  const PresenceFilterSheet({super.key});
  @override
  State<PresenceFilterSheet> createState() => _PresenceFilterSheetState();
}

class _PresenceFilterSheetState extends State<PresenceFilterSheet> {
  final _etudiantController = TextEditingController();
  String? _selectedModule;
  String? _selectedGroupe;
  DateTime? _selectedDateDebut;
  DateTime? _selectedDateFin;
  String? _selectedStatut;

  static const Color primaryButtonColor = Color(0xFF0A4F48);
  static const Color pageBackgroundColor = Color(0xFFF0EBF4);
  static const Color textFieldBorderColor = Color(0xFFC7BBDD);

  @override
  void dispose() {
    _etudiantController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isDebut) async { /* ... الكود الكامل ... */
    final DateTime? picked = await showDatePicker(context: context, initialDate: (isDebut ? _selectedDateDebut : _selectedDateFin) ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030)); if (picked != null) { setState(() { if (isDebut) _selectedDateDebut = picked; else _selectedDateFin = picked; }); }
  }
  String _formatDate(DateTime? date) { if (date == null) return 'Choisir la date'; return "${date.day}/${date.month}/${date.year}"; }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(color: pageBackgroundColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column( mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Chercher une Présence', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(height: 25),
        _buildTextField(controller: _etudiantController, label: 'Étudiant (Nom ou Prénom)'), const SizedBox(height: 20),
        _buildDropdown(label: 'Module', value: _selectedModule, hint: 'Tous les modules', items: ['UML et Analyse', 'Programmation 2', 'Base de données'], onChanged: (val) => setState(() => _selectedModule = val)), const SizedBox(height: 20),
        _buildDropdown(label: 'Groupe', value: _selectedGroupe, hint: 'Tous les groupes', items: ['GL1', 'GL2', 'RI1', 'RI2'], onChanged: (val) => setState(() => _selectedGroupe = val)), const SizedBox(height: 20),
        Row( children: [
          Expanded(child: _buildDateTimePicker(label: 'Date Début', text: _formatDate(_selectedDateDebut), onTap: () => _selectDate(context, true))), const SizedBox(width: 15),
          Expanded(child: _buildDateTimePicker(label: 'Date Fin', text: _formatDate(_selectedDateFin), onTap: () => _selectDate(context, false))),
        ],), const SizedBox(height: 20),
        _buildDropdown(label: 'Statut', value: _selectedStatut, hint: 'Tous les statuts', items: ['Présent', 'Absent', 'Justifié'], onChanged: (val) => setState(() => _selectedStatut = val)), const SizedBox(height: 30),
        _buildActionButtons(),
      ],),
    );
  }

  // --- الدوال المساعدة (مع الكود الفعلي) ---
  Widget _buildTextField({required TextEditingController controller, required String label}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 13)), const SizedBox(height: 4), TextFormField(controller: controller, decoration: _inputDecoration(label))]);
  }
  Widget _buildDropdown({required String label, required String? value, required String hint, required List<String> items, required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(value: value, hint: Text(hint, style: TextStyle(color: Colors.grey[600])), items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: onChanged, decoration: _inputDecoration(label));
  }
  Widget _buildDateTimePicker({required String label, required String text, required VoidCallback onTap}) {
    return TextFormField(readOnly: true, controller: TextEditingController(text: text), onTap: onTap, decoration: _inputDecoration(label).copyWith(suffixIcon: const Icon(Icons.calendar_month_outlined, color: Colors.grey)));
  }
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(labelText: label, labelStyle: TextStyle(color: Colors.grey[700], fontSize: 14), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), filled: true, fillColor: Colors.white, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: textFieldBorderColor, width: 1.5)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryButtonColor, width: 1.5)), errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 1.5)), focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 1.5)));
  }

  Widget _buildActionButtons() {
    return Row( mainAxisAlignment: MainAxisAlignment.end, children: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler', style: TextStyle(color: Colors.grey, fontSize: 16))), const SizedBox(width: 15),
      ElevatedButton(
        onPressed: () { Navigator.pop(context); /* TODO: Apply filter */ },
        style: ElevatedButton.styleFrom(backgroundColor: primaryButtonColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: const Text('Filtrer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    ],);
  }
}