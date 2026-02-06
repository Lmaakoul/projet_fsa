import 'package:flutter/material.dart';
import 'package:university_app/core/theme/app_colors.dart';
class CustomDropdown<T> extends StatefulWidget {
  final String labelText;
  final List<T> items;
  final T? value;
  final Function(T?) onChanged;

  const CustomDropdown({
    super.key,
    required this.labelText,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  late T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value; // Initialiser avec la valeur initiale
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.selectedNavItemColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5), // Espacement entre le label et le bouton
        Container(
          width: 300, // Largeur fixe
          height: 44, // Hauteur plus grande pour l'input
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryTextColor, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: PopupMenuButton<T>(
            onSelected: (T newValue) {
              setState(() {
                _selectedValue = newValue;
              });
              widget.onChanged(newValue); // Appeler la fonction onChanged
            },
            itemBuilder: (BuildContext context) {
              return widget.items.map((T item) {
                return PopupMenuItem<T>(
                  value: item,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.selectedNavItemColor, // Couleur de fond de l'item
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                );
              }).toList();
            },
            offset: const Offset(0, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(29),
            ),
            color: Colors.grey[300],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    _selectedValue?.toString() ?? 'Sélectionner une option',
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedValue == null
                          ? AppColors.primaryTextColor
                          : AppColors.drawerHeaderColor,
                      fontWeight: _selectedValue == null
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: AppColors.primaryTextColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
