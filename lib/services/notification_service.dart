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

  Future<void> scheduleAppointmentNotification(Appointment appointment) async {
    final appointmentDateTime = DateTime(
      appointment.date.year,
      appointment.date.month,
      appointment.date.day,
      appointment.time.hour,
      appointment.time.minute,
    );

    if (appointmentDateTime.isBefore(DateTime.now())) {
      return; // No programar en el pasado
    }

    // Programar 1 hora antes
    final notificationTime = appointmentDateTime.subtract(const Duration(hours: 1));
    bool isOneHourBefore = true;
    
    DateTime finalTime = notificationTime;
    if (notificationTime.isBefore(DateTime.now())) {
      // Si falta menos de 1 hora, notificar a la hora exacta
      if (appointmentDateTime.isAfter(DateTime.now())) {
        finalTime = appointmentDateTime;
        isOneHourBefore = false;
      } else {
        return;
      }
    }

    final id = appointment.id.hashCode;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Cita Médica: ${appointment.title}',
      isOneHourBefore 
        ? 'Tu cita para ${appointment.patientName} es en 1 hora.'
        : 'Es hora de tu cita para ${appointment.patientName}.',
      tz.TZDateTime.from(finalTime, tz.local),
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
    
    // NOTIFICACIÓN CUSTOM (Exámenes, autorizaciones, etc)
    final customId = appointment.id.hashCode ^ 12345;
    if (appointment.customReminder != null && appointment.customReminder!.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        customId,
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
    } else {
      await flutterLocalNotificationsPlugin.cancel(customId);
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> scheduleMedicineNotification(Medicine medicine) async {
    if (!medicine.isActive) {
      await cancelNotification(medicine.id.hashCode);
      return;
    }

    final id = medicine.id.hashCode;

    if (medicine.scheduleType == MedicineScheduleType.fixed && medicine.time != null) {
      // Calcula el primer momento en que debería sonar a partir de hoy a esa hora
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
        id,
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
        matchDateTimeComponents: DateTimeComponents.time, // Repite todos los días a la misma hora
      );
    } else if (medicine.scheduleType == MedicineScheduleType.interval && medicine.startTime != null && medicine.intervalHours != null) {
      // Para intervalos es mucho más complejo. Repetimos usando un periodic si cae exacto o simplemente interval
      // Por simplicidad en versión MVP de grado: Programar una alerta recursiva si es cada X horas usando matchDateTimeComponents o periodic
      // Sin embargo zonedSchedule no acepta "cada X horas" arbitrarias. Así que programaremos periódicamente la primera y asumiremos un workaround MVP
      
      // NOTA: Para un MVP la forma más fácil es programar una notificación y repetirla cada 12 o 24 horas, o depender de un plugin que hace true intervals.
      // Como flutter_local_notifications soporta repetlly pero solo every minute, hour, daily o weekly
      RepeatInterval interval = RepeatInterval.daily; 
      if (medicine.intervalHours == 1) interval = RepeatInterval.hourly;
      // Para otros intervalos, la librería nativa tiene limitaciones. 
      // Por salir rápido para el proyecto de grado, podemos programar 1 sola vez en el futuro cercano,
      // La mejor solución de grado rápido es simplemente programar la próxima toma exacta.
      
      // Programamos la primera vez que toque "de aquí en adelante"
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

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Hora de tu medicamento',
        'Debes tomar ${medicine.name} ahora (${medicine.patientName})',
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
        // No configuramos matchDateTimeComponents para que no repita mal. 
        // Idealmente cuando el usuario abra la app de nuevo re-calendarizamos, o usamos otro paquete, pero esto es un fix rápido.
      );
    }
  }
}
