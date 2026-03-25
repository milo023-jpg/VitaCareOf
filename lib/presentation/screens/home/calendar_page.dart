import 'package:flutter/material.dart';
import 'package:vitacareof/domain/entities/appointment.dart';
import 'package:vitacareof/data/datasources/appointments_datasource.dart';
import 'package:go_router/go_router.dart';

class CalendarPage extends StatefulWidget {
  final String? patientId;
  const CalendarPage({super.key, this.patientId});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _appointmentsDS = AppointmentsDatasource();
  
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  static const _monthsEs = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
  static const _weekdays = ['dom', 'lun', 'mar', 'mié', 'jue', 'vie', 'sáb'];

  void _changeMonth(int delta) {
    setState(() {
      int year = _focusedMonth.year;
      int month = _focusedMonth.month + delta;
      if (month < 1) { month = 12; year--; }
      else if (month > 12) { month = 1; year++; }
      _focusedMonth = DateTime(year, month, 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: StreamBuilder<List<Appointment>>(
        stream: _appointmentsDS.getAppointments(),
        builder: (context, snapshot) {
          List<Appointment> allAppointments = snapshot.data ?? [];
          if (widget.patientId != null) {
            allAppointments = allAppointments.where((a) => a.patientId == widget.patientId).toList();
          }

          // Filtramos las seleccionadas
          final selectedAppointments = allAppointments.where((a) => _isSameDay(a.date, _selectedDate)).toList();

          return Column(
            children: [
              // HEADER CALENDARIO
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Column(
                    children: [
                      // Controles Mes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(icon: const Icon(Icons.arrow_back_ios, size: 16), onPressed: () => _changeMonth(-1)),
                          const SizedBox(width: 10),
                          Text(
                            '${_monthsEs[_focusedMonth.month - 1]}, ${_focusedMonth.year}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                          ),
                          const SizedBox(width: 10),
                          IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 16), onPressed: () => _changeMonth(1)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Días de la semana
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _weekdays.map((w) => Text(w, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 13))).toList(),
                      ),
                      const SizedBox(height: 12),
                      // Grilla de días
                      _buildGrid(allAppointments, now),
                    ],
                  ),
                ),
              ),

              // LISTA INFERIOR
              Expanded(
                child: selectedAppointments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('No hay recordatorios asignados\npara este día', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6), fontSize: 15)),
                            const SizedBox(height: 12),
                            Text('da click en + para agregar\nnuevos recordatorios', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4), fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: selectedAppointments.length,
                        itemBuilder: (context, i) {
                          final app = selectedAppointments[i];
                          return Card(
                            color: Theme.of(context).colorScheme.surface,
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              onTap: () => context.push('/appointment_detail', extra: app),
                              leading: Container(width: 16, height: 16, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blue, width: 3))),
                              title: Text(app.title.isEmpty ? 'Sin Título' : app.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${app.time.format(context)} • ${app.patientName}'),
                              trailing: Icon(Icons.chevron_right, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3)),
                            ),
                          );
                        },
                      ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildGrid(List<Appointment> allAppts, DateTime now) {
    int daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    int firstWeekday = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday; 
    int offset = firstWeekday == 7 ? 0 : firstWeekday; // domingo = 0

    int totalCells = offset + daysInMonth;
    int rows = (totalCells / 7).ceil();

    List<Widget> gridRows = [];
    for (int r = 0; r < rows; r++) {
      List<Widget> rowCells = [];
      for (int c = 0; c < 7; c++) {
        int index = r * 7 + c;
        if (index < offset || index >= offset + daysInMonth) {
          rowCells.add(const Expanded(child: SizedBox(height: 48)));
        } else {
          int day = index - offset + 1;
          DateTime thisDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
          bool isSelected = _isSameDay(thisDate, _selectedDate);
          bool hasAppointments = allAppts.any((a) => _isSameDay(a.date, thisDate));
          bool isToday = _isSameDay(thisDate, now);

          rowCells.add(Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDate = thisDate),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 48,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 15,
                        color: isSelected ? Colors.white : (isToday ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium?.color),
                        fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (hasAppointments)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 5, height: 5,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      )
                    else 
                      const SizedBox(height: 7), // Mantener el espaciado
                  ],
                ),
              ),
            ),
          ));
        }
      }
      gridRows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: rowCells));
    }

    return Column(children: gridRows);
  }
}
