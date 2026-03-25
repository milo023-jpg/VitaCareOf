import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  bool _previousExpanded = true;
  bool _todayExpanded = true;
  bool _weekExpanded = true;
  bool _monthExpanded = true;
  bool _futureExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
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
              if (groups.previous.isNotEmpty)
                _DateSection(
                  title: 'Citas anteriores',
                  expanded: _previousExpanded,
                  onToggle: () =>
                      setState(() => _previousExpanded = !_previousExpanded),
                  children: groups.previous,
                ),
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
                  onToggle: () =>
                      setState(() => _weekExpanded = !_weekExpanded),
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

    final weekStart = todayStart.subtract(
      Duration(days: todayStart.weekday - 1),
    ); // lunes
    final nextWeekStart = weekStart.add(const Duration(days: 7));

    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = (now.month == 12)
        ? DateTime(now.year + 1, 1, 1)
        : DateTime(now.year, now.month + 1, 1);

    final sorted = [...list]
      ..sort((a, b) => _asDateTime(a).compareTo(_asDateTime(b)));

    final previous = <Appointment>[];
    final today = <Appointment>[];
    final week = <Appointment>[];
    final month = <Appointment>[];
    final future = <Appointment>[];

    for (final a in sorted) {
      final dt = _asDateTime(a);

      if (dt.isBefore(todayStart)) {
        previous.add(a);
      } else if (!dt.isBefore(todayStart) && dt.isBefore(tomorrowStart)) {
        today.add(a);
      } else if (!dt.isBefore(weekStart) && dt.isBefore(nextWeekStart)) {
        week.add(a);
      } else if (!dt.isBefore(monthStart) && dt.isBefore(nextMonthStart)) {
        month.add(a);
      } else if (dt.isAfter(nextMonthStart) ||
          dt.isAtSameMomentAs(nextMonthStart)) {
        future.add(a);
      }
    }

    return _AppointmentGroups(
      previous: previous,
      today: today,
      week: week,
      month: month,
      future: future,
    );
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
  final List<Appointment> previous;
  final List<Appointment> today;
  final List<Appointment> week;
  final List<Appointment> month;
  final List<Appointment> future;

  _AppointmentGroups({
    required this.previous,
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: 6),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            itemBuilder: (context, index) {
              final appointment = children[index];
              return _AppointmentTile(appointment: appointment);
            },
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _AppointmentTile extends StatefulWidget {
  final Appointment appointment;
  const _AppointmentTile({required this.appointment});

  @override
  State<_AppointmentTile> createState() => _AppointmentTileState();
}

class _AppointmentTileState extends State<_AppointmentTile> {
  final _datasource = AppointmentsDatasource();
  bool isDone = false;

  static const _monthsEs = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  String _formatDateEs(DateTime date) {
    final month = _monthsEs[date.month - 1];
    return '$month ${date.day}';
  }

  String _formatDateTimeMillisEs(DateTime date) {
    final month = _monthsEs[date.month - 1];
    final min = date.minute.toString().padLeft(2, '0');
    final hr12 = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day} de $month, $hr12:$min $ampm';
  }

  Future<bool> _confirmAndDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('¿Eliminar esta cita?'),
          content: const Text('Esta acción eliminará la cita seleccionada.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return false;

    final appointment = widget.appointment;

    try {
      await _datasource.deleteAppointment(appointment.id);

      if (!mounted) return true;

      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Cita eliminada'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () async {
              try {
                await _datasource.restoreAppointment(appointment);
              } catch (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error al restaurar la cita'),
                  ),
                );
              }
            },
          ),
        ),
      );

      return true;
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar la cita')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _formatDateEs(widget.appointment.date);
    final subtitleText =
        '$dateText • ${widget.appointment.time.format(context)} • ${widget.appointment.patientName}';

    return Dismissible(
      key: ValueKey(widget.appointment.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmAndDelete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: () {
          context.push('/appointment_detail', extra: widget.appointment);
        },
        splashColor: Colors.blue,
        highlightColor: Colors.blue,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Boton de punto
              IconButton(
                onPressed: () {
                  setState(() {
                    isDone = !isDone;
                  });
                },
                icon: Icon(
                  isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                ),
              ),
              const SizedBox(width: 10),

              // iformacion de la cita
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.appointment.title.trim().isEmpty
                          ? 'Sin título'
                          : widget.appointment.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subtitleText,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.appointment.customReminder != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.notifications_active, size: 12, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.appointment.customReminderText != null
                                  ? '${widget.appointment.customReminderText} • ${_formatDateTimeMillisEs(widget.appointment.customReminder!)}'
                                  : 'Recordatorio: ${_formatDateTimeMillisEs(widget.appointment.customReminder!)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
