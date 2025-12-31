import 'package:flutter/material.dart';
import 'package:vitacareof/data/datasources/medicines_datasource.dart';
import 'package:vitacareof/domain/entities/medicine.dart';

class MedicinePage extends StatelessWidget {
  final String? patientId;

  const MedicinePage({super.key, this.patientId});

  @override
  Widget build(BuildContext context) {
    final datasource = MedicinesDatasource();

    return StreamBuilder<List<Medicine>>(
      stream: datasource.getMedicines(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var medicines = snapshot.data!;

        // FILTRO POR PACIENTE
        if (patientId != null) {
          medicines = medicines.where((m) => m.patientId == patientId).toList();
        }

        if (medicines.isEmpty) {
          return const Center(child: Text('No hay medicamentos'));
        }

        // AGRUPACIÓN POR HORARIO
        final morning = medicines.where(_isMorning).toList();
        final afternoon = medicines.where(_isAfternoon).toList();
        final night = medicines.where(_isNight).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (morning.isNotEmpty) _Section(title: 'Mañana', medicines: morning),
            if (afternoon.isNotEmpty)
              _Section(title: 'Tarde', medicines: afternoon),
            if (night.isNotEmpty) _Section(title: 'Noche', medicines: night),
          ],
        );
      },
    );
  }

  static TimeOfDay _effectiveTime(Medicine m) {
    return (m.scheduleType == MedicineScheduleType.fixed)
        ? m.time!
        : m.startTime!;
  }

  // HORARIOS
  static bool _isMorning(Medicine m) => _effectiveTime(m).hour < 12;

  static bool _isAfternoon(Medicine m) =>
      _effectiveTime(m).hour >= 12 && _effectiveTime(m).hour < 18;

  static bool _isNight(Medicine m) => _effectiveTime(m).hour >= 18;

}

/// SECCIÓN (Mañana / Tarde / Noche)
class _Section extends StatelessWidget {
  final String title;
  final List<Medicine> medicines;

  const _Section({required this.title, required this.medicines});

  @override
  Widget build(BuildContext context) {
    final datasource = MedicinesDatasource();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_up, size: 18),
          ],
        ),
        const SizedBox(height: 8),
        ...medicines.map((m) => _MedicineCard(m, datasource)),
        const SizedBox(height: 24),
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
    return Container(
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
    );
  }
}
