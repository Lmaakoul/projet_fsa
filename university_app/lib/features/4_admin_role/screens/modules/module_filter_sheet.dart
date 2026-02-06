import 'package:flutter/material.dart';

class ModuleFilterSheet extends StatefulWidget {
  const ModuleFilterSheet({super.key});

  @override
  State<ModuleFilterSheet> createState() => _ModuleFilterSheetState();
}

class _ModuleFilterSheetState extends State<ModuleFilterSheet> {
  // Controllers and variables
  final _nomController = TextEditingController();
  String? _selectedFiliere;
  String? _selectedSemestre; // لاحظ أن التصميم يقول Semestre وليس Module

  // الألوان
  static const Color primaryButtonColor = Color(0xFF0A4F48);
  static const Color pageBackgroundColor = Color(0xFFF0EBF4);
  static const Color textFieldBorderColor = Color(0xFFC7BBDD);

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: pageBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- العنوان ---
          const Text(
            'Chercher un Module',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 25),

          // --- حقل الإدخال: module ---
          _buildTextField(controller: _nomController, label: 'module'), // العنوان module وليس Nom
          const SizedBox(height: 20),

          // --- القائمة المنسدلة: Filière ---
          _buildSingleSelectDropdown(
            label: 'Filière',
            value: _selectedFiliere,
            hint: 'Sélectionner une filière',
            items: ['Génie Logiciel', 'Réseaux Informatique'], // أضف خياراتك
            onChanged: (val) => setState(() => _selectedFiliere = val),
          ),
          const SizedBox(height: 20),

          // --- القائمة المنسدلة: Semestre ---
          _buildSingleSelectDropdown(
            label: 'Semestre', // العنوان Semestre
            value: _selectedSemestre,
            hint: 'Sélectionner un semestre',
            items: ['S1', 'S2', 'S3', 'S4', 'S5', 'S6'], // أضف خياراتك
            onChanged: (val) => setState(() => _selectedSemestre = val),
          ),
          const SizedBox(height: 30),

          // --- أزرار الإلغاء والفلترة ---
          _buildActionButtons(),
        ],
      ),
    );
  }

  // --- ويدجتس مساعدة ---

  Widget _buildTextField(
      {required TextEditingController controller, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[700], fontSize: 13),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: textFieldBorderColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryButtonColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleSelectDropdown({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[700], fontSize: 13),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey[600])),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: textFieldBorderColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryButtonColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // إلغاء
          },
          child: const Text(
            'Annuler',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
        const SizedBox(width: 15),
        ElevatedButton(
          onPressed: () {
            // TODO: قم بتطبيق الفلترة هنا
            Navigator.pop(context); // إغلاق الشيت
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryButtonColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Filtrer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}