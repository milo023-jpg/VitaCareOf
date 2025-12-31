import 'package:flutter/material.dart';
import 'package:vitacareof/data/datasources/appointments_datasource.dart';
import 'package:vitacareof/domain/entities/appointment.dart';

class AppointmentsPage extends StatefulWidget {
  final String? patientId; // null = Todos
  const AppointmentsPage({super.key, this.patientId});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final _datasource = AppointmentsDatasource();

  bool _todayExpanded = true;
  bool _weekExpanded = true;
  bool _monthExpanded = true;
  bool _futureExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F6F8),
      child: StreamBuilder<List<Appointment>>(
        stream: _datasource.getAppointments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var appointments = snapshot.data ?? [];

          // ✅ filtro por paciente (viene desde HomeScreen)
          if (widget.patientId != null) {
            appointments = appointments
                .where((a) => a.patientId == widget.patientId)
                .toList();
          }

          if (appointments.isEmpty) {
            return const Center(child: Text('No hay citas'));
          }

          final groups = _groupByDate(appointments);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (groups.today.isNotEmpty)
                _DateSection(
                  title: 'Hoy',
                  expanded: _todayExpanded,
                  onToggle: () =>
                      setState(() => _todayExpanded = !_todayExpanded),
                  children: groups.today,
                ),
              if (groups.week.isNotEmpty)
                _DateSection(
                  title: 'Esta semana',
                  expanded: _weekExpanded,
                  onToggle: () => setState(() => _weekExpanded = !_weekExpanded),
                  children: groups.week,
                ),
              if (groups.month.isNotEmpty)
                _DateSection(
                  title: 'Este mes',
                  expanded: _monthExpanded,
                  onToggle: () =>
                      setState(() => _monthExpanded = !_monthExpanded),
                  children: groups.month,
                ),
              if (groups.future.isNotEmpty)
                _DateSection(
                  title: 'Futuro',
                  expanded: _futureExpanded,
                  onToggle: () =>
                      setState(() => _futureExpanded = !_futureExpanded),
                  children: groups.future,
                ),
            ],
          );
        },
      ),
    );
  }

  _AppointmentGroups _groupByDate(List<Appointment> list) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    final weekStart =
        todayStart.subtract(Duration(days: todayStart.weekday - 1)); // lunes
    final nextWeekStart = weekStart.add(const Duration(days: 7));

    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = (now.month == 12)
        ? DateTime(now.year + 1, 1, 1)
        : DateTime(now.year, now.month + 1, 1);

    final sorted = [...list]..sort((a, b) => _asDateTime(a).compareTo(_asDateTime(b)));

    final today = <Appointment>[];
    final week = <Appointment>[];
    final month = <Appointment>[];
    final future = <Appointment>[];

    for (final a in sorted) {
      final dt = _asDateTime(a);

      if (dt.isAfter(todayStart) && dt.isBefore(tomorrowStart)) {
        today.add(a);
      } else if (dt.isAfter(weekStart) && dt.isBefore(nextWeekStart)) {
        week.add(a);
      } else if (dt.isAfter(monthStart) && dt.isBefore(nextMonthStart)) {
        month.add(a);
      } else if (dt.isAfter(nextMonthStart) ||
          dt.isAtSameMomentAs(nextMonthStart)) {
        future.add(a);
      } else {
        // borde: citas pasadas del mes actual (si te interesa, luego hacemos sección "Pasadas")
        if (dt.year == now.year && dt.month == now.month) {
          month.add(a);
        }
      }
    }

    return _AppointmentGroups(today: today, week: week, month: month, future: future);
  }

  DateTime _asDateTime(Appointment a) {
    return DateTime(
      a.date.year,
      a.date.month,
      a.date.day,
      a.time.hour,
      a.time.minute,
    );
  }
}

class _AppointmentGroups {
  final List<Appointment> today;
  final List<Appointment> week;
  final List<Appointment> month;
  final List<Appointment> future;

  _AppointmentGroups({
    required this.today,
    required this.week,
    required this.month,
    required this.future,
  });
}

class _DateSection extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Appointment> children;

  const _DateSection({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
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
                  expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 18,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: 6),
          ...children.map((a) => _AppointmentTile(a)),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  const _AppointmentTile(this.appointment);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.title.trim().isEmpty ? 'Sin título' : appointment.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      appointment.time.format(context),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 8),
                    Text('•', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.patientName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
