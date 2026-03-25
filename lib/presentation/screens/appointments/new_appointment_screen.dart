import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacareof/data/datasources/appointments_datasource.dart';
import 'package:vitacareof/data/datasources/patients_datasource.dart';
import 'package:vitacareof/domain/entities/appointment.dart';
import 'package:vitacareof/domain/entities/patient.dart';
import 'package:vitacareof/services/notifications_service.dart';

class NewAppointmentScreen extends StatefulWidget {
  static const name = 'new-appointment';

  const NewAppointmentScreen({super.key});

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final doctorController = TextEditingController();
  final locationController = TextEditingController();
  final notesController = TextEditingController();
  final customReminderTextController = TextEditingController();

  String? selectedPatientId;
  String? selectedPatientName;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime? customReminder;
  
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

    // Prueba Notificacion
    /* 
    Future.delayed(const Duration(seconds: 3), () {
      NotificationsService.showNotification(
        id: 1,
        title: 'Prueba',
        body: 'Notificación funcionando',
      );
    }); 
    */
  }

  Future<void> _selectPatient() async {
    if (_patients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay pacientes creados')),
      );
      return;
    }

    Patient? selectedPatient;
    if (selectedPatientId != null) {
      selectedPatient = _patients.cast<Patient?>().firstWhere(
            (p) => p?.id == selectedPatientId,
            orElse: () => null,
          );
    }

    final picked = await showDialog<Patient>(
      context: context,
      builder: (context) {
        Patient? localSelected = selectedPatient;
        return AlertDialog(
          title: const Text('Seleccionar paciente'),
          content: StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: _patients
                    .map(
                      (p) => RadioListTile<String>(
                        value: p.id,
                        groupValue: localSelected?.id,
                        title: Text(p.name),
                        onChanged: (_) => setState(() => localSelected = p),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, localSelected),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedPatientId = picked.id;
        selectedPatientName = picked.name;
      });
    }
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

  Future<void> _selectCustomReminder() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    setState(() {
      customReminder = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsDatasource = AppointmentsDatasource();

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
            onPressed: () async {
              if (selectedPatientId == null ||
                  selectedDate == null ||
                  selectedTime == null) {
                return;
              }

              final appointment = Appointment(
                id: '',
                title: titleController.text,
                description: descriptionController.text,
                patientId: selectedPatientId!,
                patientName: selectedPatientName!,
                date: selectedDate!,
                time: selectedTime!,
                doctor: doctorController.text.isNotEmpty
                    ? doctorController.text
                    : null,
                location: locationController.text.isNotEmpty
                    ? locationController.text
                    : null,
                notes: notesController.text.isNotEmpty
                    ? notesController.text
                    : null,
                customReminder: customReminder,
                customReminderText: customReminderTextController.text.isNotEmpty
                    ? customReminderTextController.text
                    : null,
              );

              await appointmentsDatasource.createAppointment(appointment);
              await NotificationsService.showNotification(
                id: appointment.hashCode,
                title: 'Nueva cita',
                body: 'Cita con ${appointment.patientName}',
              );
              context.pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _input('Nombre de la cita', controller: titleController),
            _input('Descripción', controller: descriptionController),

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
              buttonText: customReminder == null
                  ? '+'
                  : '${customReminder!.day}/${customReminder!.month}/${customReminder!.year} ${customReminder!.hour}:${customReminder!.minute.toString().padLeft(2, '0')}',
              onTap: _selectCustomReminder,
            ),

            if (customReminder != null)
              _input('Motivo del recordatorio (Ej. Autorización)', controller: customReminderTextController),

            _input('Nombre doctor (opcional)', controller: doctorController),
            _input(
              'Lugar de la cita (opcional)',
              controller: locationController,
            ),

            _selector(
              label: 'Adjuntos',
              buttonText: 'Adjuntar',
              icon: Icons.attach_file,
              onTap: () {},
            ),

            _input('Observaciones', maxLines: 3, controller: notesController),
          ],
        ),
      ),
    );
  }

  Widget _input(
    String label, {
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
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

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    doctorController.dispose();
    locationController.dispose();
    notesController.dispose();
    customReminderTextController.dispose();
    super.dispose();
  }
}
