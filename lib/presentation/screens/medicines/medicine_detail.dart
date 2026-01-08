import 'package:flutter/material.dart';
import 'package:vitacareof/domain/entities/medicine.dart';

class MedicineDetail extends StatelessWidget {
  static const name = 'medicine_detail';
  final Medicine medicine;

  const MedicineDetail({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineSmall;

    return Scaffold(
      appBar: AppBar(title: const Text('Medicamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TÍTULO
            Text(
              medicine.name,
              style: titleStyle?.copyWith(fontWeight: FontWeight.bold),
            ),

            if (medicine.type != null) ...[
              const SizedBox(height: 4),
              Text(
                medicine.type!,
                style: const TextStyle(color: Colors.black54),
              ),
            ],

            const SizedBox(height: 20),

            // PACIENTE
            _InfoCard(
              icon: Icons.person,
              title: 'Paciente',
              content: medicine.patientName,
            ),

            const SizedBox(height: 12),

            // FRECUENCIA
            _InfoCard(
              icon: Icons.schedule,
              title: 'Frecuencia',
              content: _buildSchedule(context),
            ),

            const SizedBox(height: 12),

            // DURACIÓN
            _InfoCard(
              icon: Icons.calendar_today,
              title: 'Duración',
              content: _buildDuration(),
            ),

            if (medicine.description != null) ...[
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.notes,
                title: 'Descripción',
                content: medicine.description!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // -------------------------
  // HELPERS
  // -------------------------

  String _buildSchedule(BuildContext context) {
    if (medicine.scheduleType == MedicineScheduleType.fixed) {
      final time = medicine.time!.format(context);
      return 'Todos los días a las $time';
    } else {
      final start = medicine.startTime!.format(context);
      return 'Cada ${medicine.intervalHours} horas desde las $start';
    }
  }

  String _buildDuration() {
    switch (medicine.durationType) {
      case MedicineDurationType.indefinite:
        return 'Indefinido';
      case MedicineDurationType.days:
        return '${medicine.durationDays} días';
      case MedicineDurationType.until:
        final d = medicine.endDate!;
        return 'Hasta ${d.day}/${d.month}/${d.year}';
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(content, style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
