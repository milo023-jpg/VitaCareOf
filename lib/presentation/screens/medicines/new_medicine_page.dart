import 'package:flutter/material.dart';
import 'package:vitacareof/data/datasources/medicines_datasource.dart';
import 'package:vitacareof/domain/entities/medicine.dart';
import 'package:vitacareof/domain/entities/patient.dart';

class NewMedicinePage extends StatefulWidget {
  final List<Patient> patients;

  const NewMedicinePage({super.key, required this.patients});

  @override
  State<NewMedicinePage> createState() => _NewMedicinePageState();
}

class _NewMedicinePageState extends State<NewMedicinePage> {
  final _ds = MedicinesDatasource();

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  Patient? _selectedPatient;

  MedicineScheduleType _scheduleType = MedicineScheduleType.fixed;

  // fixed
  TimeOfDay _fixedTime = const TimeOfDay(hour: 8, minute: 0);

  // interval
  int _intervalHours = 8;
  TimeOfDay _startTime = const TimeOfDay(hour: 6, minute: 0);

  // duración
  MedicineDurationType _durationType = MedicineDurationType.indefinite;
  int _durationDays = 7;
  DateTime? _endDate;

  String? _type; // opcional (tipo de medicamento)

  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool forFixed}) async {
    final initial = forFixed ? _fixedTime : _startTime;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;

    setState(() {
      if (forFixed) {
        _fixedTime = picked;
      } else {
        _startTime = picked;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final initial = _endDate ?? now.add(const Duration(days: 7));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked == null) return;
    setState(() => _endDate = picked);
  }

  Future<void> _save() async {
    if (_saving) return;

    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _toast('Escribe el nombre del medicamento');
      return;
    }
    if (_selectedPatient == null) {
      _toast('Selecciona un paciente');
      return;
    }

    // validación duración
    if (_durationType == MedicineDurationType.days && _durationDays <= 0) {
      _toast('Los días deben ser mayor a 0');
      return;
    }
    if (_durationType == MedicineDurationType.until && _endDate == null) {
      _toast('Selecciona la fecha final');
      return;
    }

    setState(() => _saving = true);

    try {
      final med = Medicine(
        id: '',
        name: name,
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        type: _type,
        patientId: _selectedPatient!.id,
        patientName: _selectedPatient!.name,
        scheduleType: _scheduleType,
        durationType: _durationType,
        createdAt: DateTime.now(),
        // fixed
        time: _scheduleType == MedicineScheduleType.fixed ? _fixedTime : null,
        repeat: _scheduleType == MedicineScheduleType.fixed
            ? MedicineRepeatType.daily
            : null,
        // interval
        intervalHours: _scheduleType == MedicineScheduleType.interval
            ? _intervalHours
            : null,
        startTime: _scheduleType == MedicineScheduleType.interval
            ? _startTime
            : null,
        // duración
        durationDays: _durationType == MedicineDurationType.days
            ? _durationDays
            : null,
        endDate: _durationType == MedicineDurationType.until ? _endDate : null,
      );

      await _ds.createMedicine(med);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _toast('Error guardando medicamento');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Nuevo Medicamento'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Frecuencia
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Frecuencia',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                SegmentedButton<MedicineScheduleType>(
                  segments: const [
                    ButtonSegment(
                      value: MedicineScheduleType.fixed,
                      label: Text('Hora fija'),
                    ),
                    ButtonSegment(
                      value: MedicineScheduleType.interval,
                      label: Text('Cada X horas'),
                    ),
                  ],
                  selected: {_scheduleType},
                  onSelectionChanged: (set) {
                    setState(() => _scheduleType = set.first);
                  },
                ),
                const SizedBox(height: 14),
                if (_scheduleType == MedicineScheduleType.fixed)
                  _RowPick(
                    label: 'Hora',
                    value: _fixedTime.format(context),
                    onTap: () => _pickTime(forFixed: true),
                  )
                else ...[
                  _RowPick(
                    label: 'Inicia a las',
                    value: _startTime.format(context),
                    onTap: () => _pickTime(forFixed: false),
                  ),
                  const SizedBox(height: 10),
                  _RowPick(
                    label: 'Cada',
                    value: '$_intervalHours horas',
                    onTap: () async {
                      final picked = await _pickIntervalDialog(
                        context,
                        _intervalHours,
                      );
                      if (picked != null)
                        setState(() => _intervalHours = picked);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Se repetirá 24/7 a partir de la hora inicial.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Datos
          _Card(
            child: Column(
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Medicamento',
                    border: InputBorder.none,
                  ),
                ),
                const Divider(height: 1),
                TextField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Descripción (opcional)',
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Tipo + Paciente
          _Card(
            child: Column(
              children: [
                _RowPick(
                  label: 'Tipo de medicamento',
                  value: _type ?? 'Seleccionar',
                  valueMuted: _type == null,
                  onTap: () async {
                    final picked = await _pickTypeDialog(context, _type);
                    if (picked != null) setState(() => _type = picked);
                  },
                ),
                const Divider(height: 1),
                _RowPick(
                  label: 'Paciente',
                  value: _selectedPatient?.name ?? 'Seleccionar',
                  valueMuted: _selectedPatient == null,
                  onTap: () async {
                    final picked = await _pickPatientDialog(
                      context,
                      widget.patients,
                      _selectedPatient,
                    );
                    if (picked != null)
                      setState(() => _selectedPatient = picked);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Duración
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Duración',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                SegmentedButton<MedicineDurationType>(
                  segments: const [
                    ButtonSegment(
                      value: MedicineDurationType.indefinite,
                      label: Text('Indefinido'),
                    ),
                    ButtonSegment(
                      value: MedicineDurationType.days,
                      label: Text('Por días'),
                    ),
                    ButtonSegment(
                      value: MedicineDurationType.until,
                      label: Text('Hasta fecha'),
                    ),
                  ],
                  selected: {_durationType},
                  onSelectionChanged: (set) {
                    setState(() => _durationType = set.first);
                  },
                ),
                const SizedBox(height: 12),
                if (_durationType == MedicineDurationType.days)
                  _RowPick(
                    label: 'Días',
                    value: '$_durationDays',
                    onTap: () async {
                      final picked = await _pickDaysDialog(
                        context,
                        _durationDays,
                      );
                      if (picked != null)
                        setState(() => _durationDays = picked);
                    },
                  ),
                if (_durationType == MedicineDurationType.until)
                  _RowPick(
                    label: 'Fecha final',
                    value: _endDate == null
                        ? 'Seleccionar'
                        : _formatDate(_endDate!),
                    valueMuted: _endDate == null,
                    onTap: _pickEndDate,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------
// UI Helpers
// --------------------

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}

class _RowPick extends StatelessWidget {
  final String label;
  final String value;
  final bool valueMuted;
  final VoidCallback onTap;

  const _RowPick({
    required this.label,
    required this.value,
    this.valueMuted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: valueMuted ? Colors.black38 : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------
// Dialogs
// --------------------

Future<int?> _pickIntervalDialog(BuildContext context, int current) async {
  final options = [4, 6, 8, 12];
  int selected = current;

  return showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cada cuántas horas'),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...options.map(
                (h) => RadioListTile<int>(
                  value: h,
                  groupValue: selected,
                  title: Text('$h horas'),
                  onChanged: (v) => setState(() => selected = v!),
                ),
              ),
              const Divider(),
              Row(
                children: [
                  const Text('Otro:'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: selected.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n > 0 && n <= 24) {
                          selected = n;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, selected),
          child: const Text('Aceptar'),
        ),
      ],
    ),
  );
}

Future<int?> _pickDaysDialog(BuildContext context, int current) async {
  int selected = current;

  return showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Duración (días)'),
      content: StatefulBuilder(
        builder: (context, setState) {
          return TextFormField(
            initialValue: selected.toString(),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final n = int.tryParse(v);
              if (n != null && n > 0) setState(() => selected = n);
            },
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, selected),
          child: const Text('Aceptar'),
        ),
      ],
    ),
  );
}

Future<String?> _pickTypeDialog(BuildContext context, String? current) async {
  final types = ['Tableta', 'Cápsula', 'Jarabe', 'Gotas', 'Inyección', 'Otro'];
  String? selected = current;

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Tipo de medicamento'),
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: types
              .map(
                (t) => RadioListTile<String>(
                  value: t,
                  groupValue: selected,
                  title: Text(t),
                  onChanged: (v) => setState(() => selected = v),
                ),
              )
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, selected ?? 'Otro'),
          child: const Text('Aceptar'),
        ),
      ],
    ),
  );
}

Future<Patient?> _pickPatientDialog(
  BuildContext context,
  List<Patient> patients,
  Patient? current,
) async {
  Patient? selected = current;

  return showDialog<Patient>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Seleccionar paciente'),
      content: StatefulBuilder(
        builder: (context, setState) => SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: patients
                .map(
                  (p) => RadioListTile<String>(
                    value: p.id,
                    groupValue: selected?.id,
                    title: Text(p.name),
                    onChanged: (_) => setState(() => selected = p),
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
          onPressed: () => Navigator.pop(context, selected),
          child: const Text('Aceptar'),
        ),
      ],
    ),
  );
}
