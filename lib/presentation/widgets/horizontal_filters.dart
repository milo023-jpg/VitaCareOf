import 'package:flutter/material.dart';
import 'package:vitacareof/domain/entities/patient.dart';

class HorizontalFilters extends StatelessWidget {
  final List<Patient> patients;
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          /// 👉 Todos
          ChoiceChip(
            label: const Text('Todos'),
            selected: selectedPatient == null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onSelected: (_) => onSelected(null),
          ),

          const SizedBox(width: 8),

          /// 👉 Pacientes
          ...patients.map((patient) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(patient.name),
                selected: selectedPatient == patient.id,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (_) => onSelected(patient.id),
              ),
            );
          }),

          const SizedBox(width: 8),

          /// 👉 Botón +
          InkWell(
            onTap: onAddPatient,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(6),
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
