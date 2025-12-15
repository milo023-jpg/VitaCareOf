import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewAppointmentScreen extends StatelessWidget {
  static const name = 'new-appointment';

  const NewAppointmentScreen({super.key});

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
              buttonText: 'Seleccionar',
              onTap: () {},
            ),

            const SizedBox(height: 12),

            _selector(label: 'Fecha', buttonText: 'Seleccionar', onTap: () {}),

            _selector(label: 'Hora', buttonText: '00:00 a.m.', onTap: () {}),

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
