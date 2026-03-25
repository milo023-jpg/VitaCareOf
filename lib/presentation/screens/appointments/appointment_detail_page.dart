import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vitacareof/domain/entities/appointment.dart';
import 'package:go_router/go_router.dart';

class AppointmentDetailPage extends StatefulWidget {
  static const name = 'appointment_detail';

  final Appointment appointment;

  const AppointmentDetailPage({super.key, required this.appointment});

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  late Appointment _appointment;

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
  }

  Future<void> _goToEdit() async {
    final updated = await context.push<Appointment>(
      '/edit_appointment',
      extra: _appointment,
    );

    if (!mounted || updated == null) return;

    setState(() {
      _appointment = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la cita'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _goToEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TÍTULO
            Text(
              _appointment.title.isEmpty ? 'Sin título' : _appointment.title,
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
                Text(dateFormat.format(_appointment.date)),
                const SizedBox(width: 16),
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(_appointment.time.format(context)),
              ],
            ),

            const SizedBox(height: 24),

            _InfoCard(
              icon: Icons.person,
              title: 'Paciente',
              content: _appointment.patientName,
            ),

            const SizedBox(height: 12),

            _InfoCard(
              icon: Icons.description,
              title: 'Descripción',
              content: _appointment.description.isEmpty
                  ? 'Sin descripción'
                  : _appointment.description,
            ),

            if (_appointment.doctor != null) ...[
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.medical_services,
                title: 'Doctor',
                content: _appointment.doctor!,
              ),
            ],

            if (_appointment.customReminder != null) ...[
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.notifications_active,
                title: _appointment.customReminderText != null 
                    ? 'Recordatorio: ${_appointment.customReminderText}' 
                    : 'Recordatorio Previo',
                content: DateFormat('dd MMMM yyyy • hh:mm a').format(_appointment.customReminder!),
              ),
            ],

            if (_appointment.location != null) ...[
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.location_on,
                title: 'Lugar',
                content: _appointment.location!,
              ),
            ],

            if (_appointment.notes != null) ...[
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.notes,
                title: 'Observaciones',
                content: _appointment.notes!,
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
