import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:vitacareof/domain/entities/appointment.dart';
import 'package:vitacareof/domain/entities/medicine.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    // Solicitar permisos Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  int _getAppointmentBaseId(String id) {
    return 200000000 + (id.hashCode.abs() % 1000000) * 100;
  }

  int _getMedicineBaseId(String id) {
    return 100000000 + (id.hashCode.abs() % 1000000) * 100;
  }

  Future<void> cancelAppointmentNotifications(String id) async {
    final baseId = _getAppointmentBaseId(id);
    for (int i = 0; i < 10; i++) {
      await flutterLocalNotificationsPlugin.cancel(baseId + i);
    }
  }

  Future<void> cancelMedicineNotifications(String id) async {
    final baseId = _getMedicineBaseId(id);
    for (int i = 0; i < 64; i++) {
      await flutterLocalNotificationsPlugin.cancel(baseId + i);
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> scheduleAppointmentNotification(Appointment appointment) async {
    await cancelAppointmentNotifications(appointment.id);

    final appointmentDateTime = DateTime(
      appointment.date.year,
      appointment.date.month,
      appointment.date.day,
      appointment.time.hour,
      appointment.time.minute,
    );

    if (appointmentDateTime.isBefore(DateTime.now())) {
      return; 
    }

    final baseId = _getAppointmentBaseId(appointment.id);
    int offset = 0;

    Future<void> schedule(DateTime time, String body) async {
      if (time.isAfter(DateTime.now())) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          baseId + offset,
          'Cita Médica: ${appointment.title}',
          body,
          tz.TZDateTime.from(time, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'vitacare_appointments',
              'Citas Médicas',
              channelDescription: 'Recordatorios de citas',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        offset++;
      }
    }

    // 1 mes antes
    await schedule(appointmentDateTime.subtract(const Duration(days: 30)), 'Tu cita para ${appointment.patientName} es en 1 mes.');
    // 1 semana antes
    await schedule(appointmentDateTime.subtract(const Duration(days: 7)), 'Tu cita para ${appointment.patientName} es en 1 semana.');
    // 1 día antes
    await schedule(appointmentDateTime.subtract(const Duration(days: 1)), 'Tu cita para ${appointment.patientName} es mañana.');
    // 1 hora antes
    await schedule(appointmentDateTime.subtract(const Duration(hours: 1)), 'Tu cita para ${appointment.patientName} es en 1 hora.');
    // Hora exacta
    await schedule(appointmentDateTime, 'Es hora de tu cita para ${appointment.patientName}.');

    // Custom reminder
    if (appointment.customReminder != null && appointment.customReminder!.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        baseId + offset,
        'Recordatorio previo: ${appointment.title}',
        appointment.customReminderText ?? 'Acción requerida para tu cita con ${appointment.patientName}',
        tz.TZDateTime.from(appointment.customReminder!, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'vitacare_appointments_custom',
            'Recordatorios Previos',
            channelDescription: 'Avisos previos a la cita médica',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      offset++;
    }
  }

  Future<void> scheduleMedicineNotification(Medicine medicine) async {
    await cancelMedicineNotifications(medicine.id);

    if (!medicine.isActive) {
      return;
    }

    final baseId = _getMedicineBaseId(medicine.id);

    if (medicine.scheduleType == MedicineScheduleType.fixed && medicine.time != null) {
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        medicine.time!.hour,
        medicine.time!.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        baseId,
        'Hora de tu medicamento',
        'Debes tomar ${medicine.name} (${medicine.patientName})',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'vitacare_medicines',
            'Medicamentos',
            channelDescription: 'Recordatorios de medicamentos',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, 
      );
    } else if (medicine.scheduleType == MedicineScheduleType.interval && medicine.startTime != null && medicine.intervalHours != null) {
      
      final now = DateTime.now();
      DateTime nextTime = DateTime(
        now.year,
        now.month,
        now.day,
        medicine.startTime!.hour,
        medicine.startTime!.minute,
      );
      
      while (nextTime.isBefore(now)) {
        nextTime = nextTime.add(Duration(hours: medicine.intervalHours!));
      }

      // Schedule up to 60 occurrences ahead (e.g. 20 days if every 8 hrs)
      int occurrences = 60;
      for (int i = 0; i < occurrences; i++) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          baseId + i,
          'Hora de tu medicamento',
          'Debes tomar ${medicine.name} (${medicine.patientName})',
          tz.TZDateTime.from(nextTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'vitacare_interval',
              'Medicamentos Intervalo',
              channelDescription: 'Recordatorios de medicamentos por intervalo',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        nextTime = nextTime.add(Duration(hours: medicine.intervalHours!));
      }
    }
  }
}
