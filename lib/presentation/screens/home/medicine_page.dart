import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacareof/data/datasources/medicines_datasource.dart';
import 'package:vitacareof/domain/entities/medicine.dart';

class MedicinePage extends StatefulWidget {
  final String? patientId;

  const MedicinePage({super.key, this.patientId});

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  final datasource = MedicinesDatasource();

  bool _morningExpanded = true;
  bool _afternoonExpanded = true;
  bool _nightExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F6F8),
      child: StreamBuilder<List<Medicine>>(
        stream: datasource.getMedicines(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var medicines = snapshot.data!;

          // FILTRO POR PACIENTE
          if (widget.patientId != null) {
            medicines =
                medicines.where((m) => m.patientId == widget.patientId).toList();
          }

          if (medicines.isEmpty) {
            return const Center(child: Text('No hay medicamentos'));
          }

          // AGRUPACIÓN POR HORARIO
          final morning = medicines.where(_isMorning).toList();
          final afternoon = medicines.where(_isAfternoon).toList();
          final night = medicines.where(_isNight).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (morning.isNotEmpty)
                _Section(
                  title: 'Mañana',
                  expanded: _morningExpanded,
                  onToggle: () =>
                      setState(() => _morningExpanded = !_morningExpanded),
                  medicines: morning,
                ),
              if (afternoon.isNotEmpty)
                _Section(
                  title: 'Tarde',
                  expanded: _afternoonExpanded,
                  onToggle: () =>
                      setState(() => _afternoonExpanded = !_afternoonExpanded),
                  medicines: afternoon,
                ),
              if (night.isNotEmpty)
                _Section(
                  title: 'Noche',
                  expanded: _nightExpanded,
                  onToggle: () =>
                      setState(() => _nightExpanded = !_nightExpanded),
                  medicines: night,
                ),
            ],
          );
        },
      ),
    );
  }

  static TimeOfDay _effectiveTime(Medicine m) {
    return (m.scheduleType == MedicineScheduleType.fixed) ? m.time! : m.startTime!;
  }

  static bool _isMorning(Medicine m) => _effectiveTime(m).hour < 12;

  static bool _isAfternoon(Medicine m) =>
      _effectiveTime(m).hour >= 12 && _effectiveTime(m).hour < 18;

  static bool _isNight(Medicine m) => _effectiveTime(m).hour >= 18;
}

/// SECCIÓN (Mañana / Tarde / Noche)
class _Section extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Medicine> medicines;

  const _Section({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.medicines,
  });

  @override
  Widget build(BuildContext context) {
    final datasource = MedicinesDatasource();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: 6),
          ...medicines.map((m) => _MedicineCard(m, datasource)),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

String _displayTime(BuildContext context, Medicine medicine) {
  if (medicine.scheduleType == MedicineScheduleType.fixed) {
    return medicine.time!.format(context);
  } else {
    return medicine.startTime!.format(context);
  }
}

/// TARJETA DE MEDICAMENTO
class _MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final MedicinesDatasource datasource;

  const _MedicineCard(this.medicine, this.datasource);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/medicine_detail', extra: medicine);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Hora
            Text(
              _displayTime(context, medicine),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name.isNotEmpty ? medicine.name : 'Sin título',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medicine.patientName,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // Switch funcional (activa/desactiva en Firestore)
            Switch(
              value: medicine.isActive,
              onChanged: (value) {
                datasource.toggleMedicine(medicine.id, value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
