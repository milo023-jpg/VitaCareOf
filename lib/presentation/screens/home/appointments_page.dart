import 'package:flutter/material.dart';
import 'package:vitacareof/data/datasources/appointments_datasource.dart';
import 'package:vitacareof/domain/entities/appointment.dart';

class AppointmentsPage extends StatelessWidget {
  final String? patientId;

  const AppointmentsPage({super.key, this.patientId});

  @override
  Widget build(BuildContext context) {
    final datasource = AppointmentsDatasource();

    return StreamBuilder<List<Appointment>>(
      stream: datasource.getAppointments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var appointments = snapshot.data!;

        // FILTRO POR PACIENTE
        if (patientId != null) {
          appointments = appointments
              .where((a) => a.patientId == patientId)
              .toList();
        }

        if (appointments.isEmpty) {
          return const Center(child: Text('No hay citas'));
        }

        // AGRUPACIÓN POR HORARIO
        final morning = appointments.where(_isMorning).toList();
        final afternoon = appointments.where(_isAfternoon).toList();
        final night = appointments.where(_isNight).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (morning.isNotEmpty)
              _Section(title: 'Mañana', appointments: morning),

            if (afternoon.isNotEmpty)
              _Section(title: 'Tarde', appointments: afternoon),

            if (night.isNotEmpty) _Section(title: 'Noche', appointments: night),
          ],
        );
      },
    );
  }

  // HORARIOS
  static bool _isMorning(Appointment a) => a.time.hour < 12;
  static bool _isAfternoon(Appointment a) =>
      a.time.hour >= 12 && a.time.hour < 18;
  static bool _isNight(Appointment a) => a.time.hour >= 18;
}

/// SECCIÓN (Mañana / Tarde / Noche)
class _Section extends StatelessWidget {
  final String title;
  final List<Appointment> appointments;

  const _Section({required this.title, required this.appointments});

  @override
  Widget build(BuildContext context) {
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

        ...appointments.map((a) => _AppointmentCard(a)),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// TARJETA DE CITA
class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentCard(this.appointment);

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
            appointment.time.format(context),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.title.isNotEmpty
                      ? appointment.title
                      : 'Sin titulo',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.patientName,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Switch (solo visual por ahora)
          Switch(value: false, onChanged: (_) {}),
        ],
      ),
    );
  }
}
