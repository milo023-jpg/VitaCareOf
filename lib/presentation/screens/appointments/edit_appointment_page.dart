import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacareof/data/datasources/appointments_datasource.dart';
import 'package:vitacareof/data/datasources/patients_datasource.dart';
import 'package:vitacareof/domain/entities/appointment.dart';
import 'package:vitacareof/domain/entities/patient.dart';
import 'package:vitacareof/services/notification_service.dart';

class EditAppointmentPage extends StatefulWidget {
  static const name = 'edit-appointment';

  final Appointment appointment;

  const EditAppointmentPage({super.key, required this.appointment});

  @override
  State<EditAppointmentPage> createState() => _EditAppointmentPageState();
}

class _EditAppointmentPageState extends State<EditAppointmentPage> {
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

    // ✅ precargar campos con la cita existente
    final a = widget.appointment;
    titleController.text = a.title;
    descriptionController.text = a.description;
    doctorController.text = a.doctor ?? '';
    locationController.text = a.location ?? '';
    notesController.text = a.notes ?? '';

    selectedPatientId = a.patientId;
    selectedPatientName = a.patientName;
    selectedDate = a.date;
    selectedTime = a.time;
    customReminder = a.customReminder;
    customReminderTextController.text = a.customReminderText ?? '';

    _patientsDatasource.getPatients().listen((patients) {
      if (!mounted) return;
      setState(() => _patients = patients);
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
      setState(() => selectedDate = pickedDate);
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() => selectedTime = pickedTime);
    }
  }

  Future<void> _selectCustomReminder() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: customReminder ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: customReminder != null
          ? TimeOfDay.fromDateTime(customReminder!)
          : TimeOfDay.now(),
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
        title: const Text('Editar cita'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              if (selectedPatientId == null ||
                  selectedPatientName == null ||
                  selectedDate == null ||
                  selectedTime == null) {
                return;
              }

              final updated = Appointment(
                id: widget.appointment.id, // ✅ IMPORTANTE: conservar id
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

              final router = GoRouter.of(context);

              await appointmentsDatasource.updateAppointment(
                updated.id,
                updated.toMap(),
              );

              await NotificationService().scheduleAppointmentNotification(updated);

              if (!mounted) return;
              router.pop(updated);
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
              onTap: _selectDate,
            ),

            _selector(
              label: 'Hora',
              buttonText:
                  selectedTime == null ? 'Seleccionar' : selectedTime!.format(context),
              onTap: _selectTime,
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
            _input('Lugar de la cita (opcional)', controller: locationController),

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
