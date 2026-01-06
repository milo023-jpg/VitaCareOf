import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vitacareof/domain/entities/appointment.dart';

class AppointmentDetailPage extends StatelessWidget {
  static const name = 'appointment_detail';

  final Appointment appointment;

  const AppointmentDetailPage({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de la cita')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TÍTULO
            Text(
              appointment.title.isEmpty ? 'Sin título' : appointment.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // FECHA Y HORA
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(dateFormat.format(appointment.date)),
                const SizedBox(width: 16),
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(appointment.time.format(context)),
              ],
            ),

            const SizedBox(height: 24),

            _InfoCard(
              icon: Icons.person,
              title: 'Paciente',
              content: appointment.patientName,
            ),

            const SizedBox(height: 12),

            _InfoCard(
              icon: Icons.description,
              title: 'Descripción',
              content: appointment.description.isEmpty
                  ? 'Sin descripción'
                  : appointment.description,
            ),

            if (appointment.doctor != null) ...[
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.medical_services,
                title: 'Doctor',
                content: appointment.doctor!,
              ),
            ],

            if (appointment.location != null) ...[
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.location_on,
                title: 'Lugar',
                content: appointment.location!,
              ),
            ],

            if (appointment.notes != null) ...[
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.notes,
                title: 'Observaciones',
                content: appointment.notes!,
              ),
            ],
          ],
        ),
      ),
    );
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
                  Text(content, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
