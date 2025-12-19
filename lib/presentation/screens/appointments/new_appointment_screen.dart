import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacareof/data/datasources/patients_datasource.dart';
import 'package:vitacareof/domain/entities/patient.dart';

class NewAppointmentScreen extends StatefulWidget {
  static const name = 'new-appointment';

  const NewAppointmentScreen({super.key});

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  String? selectedPatientId;
  String? selectedPatientName;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<Patient> _patients = [];
  final _patientsDatasource = PatientsDatasource();

  @override
  void initState() {
    super.initState();

    _patientsDatasource.getPatients().listen((patients) {
      setState(() {
        _patients = patients;
      });
    });
  }

  void _selectPatient() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        if (_patients.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No hay pacientes creados')),
          );
        }

        return ListView.builder(
          itemCount: _patients.length,
          itemBuilder: (context, index) {
            final patient = _patients[index];

            return ListTile(
              title: Text(patient.name),
              onTap: () {
                setState(() {
                  selectedPatientId = patient.id;
                  selectedPatientName = patient.name;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva cita'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.pop(); // Cancelar
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Aquí luego va Provider para guardar
              context.pop(); // Finalizar
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _input('Nombre de la cita'),
            _input('Descripción'),

            const SizedBox(height: 12),

            _selector(
              label: 'Paciente',
              buttonText: selectedPatientName ?? 'Seleccionar',
              onTap: _selectPatient,
            ),

            const SizedBox(height: 12),

            _selector(
              label: 'Fecha',
              buttonText: selectedDate == null
                  ? 'Seleccionar'
                  : '${selectedDate!.day} / ${selectedDate!.month} / ${selectedDate!.year}',
              onTap: () => _selectDate(),
            ),

            _selector(
              label: 'Hora',
              buttonText: selectedTime == null
                  ? 'seleccionar'
                  : selectedTime!.format(context),
              onTap: () => _selectTime(),
            ),

            _selector(
              label: 'Recordatorio anterior',
              buttonText: '+',
              onTap: () {},
            ),

            _input('Nombre doctor (opcional)'),
            _input('Lugar de la cita (opcional)'),

            _selector(
              label: 'Adjuntos',
              buttonText: 'Adjuntar',
              icon: Icons.attach_file,
              onTap: () {},
            ),

            _input('Observaciones', maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _selector({
    required String label,
    required String buttonText,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ),
          TextButton.icon(
            onPressed: onTap,
            icon: icon != null ? Icon(icon) : const SizedBox(),
            label: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
