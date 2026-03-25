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
import 'package:vitacareof/presentation/screens/medicines/new_medicine_page.dart';

/// Pantalla principal que sirve como contenedor maestro (Scaffold root) de la navegación interna.
/// 
/// Corresponde a la capa de Presentación. Utiliza un patrón de "Index Stack" (vía switch)
/// para renderizar sub-pantallas y mantener la navegación inferior. Adicionalmente,
/// gestiona el estado global compartido de "Filtro de Paciente".
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Dependencia a la capa de datos. Idealmente inyectada vía Provider o GetIt
  /// pero instanciada directamente por ahora.
  final _patientsDatasource = PatientsDatasource();

  /// Estado interno: lista completa de pacientes obtenidos en tiempo real.
  List<Patient> _patients = [];
  
  /// Estado interno: UID del paciente seleccionado en el filtro. 
  /// Si es nulo, significa que no hay filtro aplicado (muestran todos).
  String? filtroSeleccionado;
  
  /// Estado interno: Índice activo del `BottomNavigationBar`.
  int _paginaActual = 0;

  @override
  void initState() {
    super.initState();
    // Suscripción al stream de pacientes para mantener la lista actualizada
    // en tiempo real. Esta lista es crítica para el filtro horizontal.
    _patientsDatasource.getPatients().listen((patients) {
      if (mounted) {
        setState(() {
          _patients = patients;
        });
      }
    });
  }

  /// Devuelve dinámicamente el widget (página) correspondiente a la pestaña activa.
  /// 
  /// Inyecta el [filtroSeleccionado] en las sub-páginas para que estas
  /// modifiquen sus consultas en cascada.
  Widget _paginaActualWidget() {
    switch (_paginaActual) {
      case 0:
        return AppointmentsPage(patientId: filtroSeleccionado);
      case 1:
        return CalendarPage(patientId: filtroSeleccionado);
      case 2:
        return MedicinePage(patientId: filtroSeleccionado);
      case 3:
        // Cargar consejos no depende de un paciente específico en la app
        return const AdvicePage();
      default:
        return const SizedBox();
    }
  }

  /// Lanza un diálogo nativo pidiendo el nombre de un paciente nuevo.
  /// 
  /// Interactúa con el Datasource para aplicar el cambio en base de datos.
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
          // Renderiza el selector de pacientes únicamente si la pestaña
          // actual lo soporta (Citas, Calendario o Medicinas).
          if (_paginaActual == 0 || _paginaActual == 1 || _paginaActual == 2)
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
          
          // Renderizado dinámico de la página que ocupa el resto del espacio
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
      // SpeedDial para permitir acceso rápido a la creación de recursos
      // primarios (Citas o Medicinas), evitando navegación profunda.
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.assignment_add),
            label: 'Nueva cita',
            onTap: () {
              context.push('/appointments');
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.medication_outlined),
            label: 'Nuevo medicamento',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NewMedicinePage(patients: _patients),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
