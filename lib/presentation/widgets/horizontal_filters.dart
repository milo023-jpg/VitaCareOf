import 'package:flutter/material.dart';

class HorizontalFilters extends StatelessWidget {
  final List<String> patients;
  final String? selectedPatient;
  final ValueChanged<String?> onSelected;
  final VoidCallback onAddPatient;

  const HorizontalFilters({
    super.key,
    required this.patients,
    required this.selectedPatient,
    required this.onSelected,
    required this.onAddPatient,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          /// 👉 Filtro "Todos"
          ChoiceChip(
            label: const Text('Todos'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            selected: selectedPatient == null,
            onSelected: (_) => onSelected(null),
          ),

          const SizedBox(width: 8),

          /// 👉 Chips de pacientes
          ...patients.map((patient) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(patient),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(20),
                ),
                selected: selectedPatient == patient,
                onSelected: (_) => onSelected(patient),
              ),
            );
          }),

          const SizedBox(width: 8),

          /// 👉 Botón +
          InkWell(
            onTap: onAddPatient,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
