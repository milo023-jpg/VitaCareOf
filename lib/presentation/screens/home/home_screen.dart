import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacareof/data/datasources/patients_datasource.dart';
import 'package:vitacareof/domain/entities/patient.dart';
import 'package:vitacareof/presentation/screens/home/advice_page.dart';
import 'package:vitacareof/presentation/screens/home/appointments_page.dart';
import 'package:vitacareof/presentation/screens/home/calendar_page.dart';
import 'package:vitacareof/presentation/screens/home/medicine_page.dart';
import 'package:vitacareof/presentation/widgets/horizontal_filters.dart';
import 'package:vitacareof/presentation/widgets/side_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _patientsDatasource = PatientsDatasource();

  List<Patient> _patients = [];
  String? filtroSeleccionado;
  int _paginaActual = 0;

  @override
  void initState() {
    super.initState();

    _patientsDatasource.getPatients().listen((patients) {
      setState(() {
        _patients = patients;
      });
    });
  }

  // 🔹 Selección dinámica de página (IMPORTANTE)
  Widget _paginaActualWidget() {
    switch (_paginaActual) {
      case 0:
        return AppointmentsPage(patientId: filtroSeleccionado);
      case 1:
        return const CalendarPage();
      case 2:
        return const MedicinePage();
      case 3:
        return const AdvicePage();
      default:
        return const SizedBox();
    }
  }

  void _mostrarDialogoNuevoPaciente() {
    showDialog(
      context: context,
      builder: (context) {
        String nombre = '';

        return AlertDialog(
          title: const Text('Nuevo paciente'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nombre del paciente'),
            onChanged: (value) => nombre = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nombre.trim().isNotEmpty) {
                  await _patientsDatasource.addPatient(nombre.trim());
                }
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(),
      appBar: AppBar(title: const Text('VitaCare')),
      body: Column(
        children: [
          HorizontalFilters(
            patients: _patients,
            selectedPatient: filtroSeleccionado,
            onSelected: (value) {
              setState(() {
                filtroSeleccionado = value;
              });
            },
            onAddPatient: _mostrarDialogoNuevoPaciente,
          ),
          Expanded(child: _paginaActualWidget()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _paginaActual,
        onTap: (index) {
          setState(() {
            _paginaActual = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Citas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medicinas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Consejos',
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.assignment_add),
            label: 'Nueva cita',
            onTap: () {
              context.push('/appointments');
            },
          ),
        ],
      ),
    );
  }
}
