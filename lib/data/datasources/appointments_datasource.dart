import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitacareof/domain/entities/appointment.dart';
import 'package:vitacareof/services/notification_service.dart';

/// Datasource encargado de gestionar las citas médicas del usuario en Firebase Firestore.
/// 
/// Esta clase actúa como la capa de datos (Data Layer) especializada en 
/// el manejo de la colección `appointments` del usuario autenticado.
class AppointmentsDatasource {
  /// Instancia de Firestore para interactuar con la base de datos NoSQL.
  final _firestore = FirebaseFirestore.instance;
  
  /// Instancia de FirebaseAuth para asegurar que las operaciones se realicen 
  /// sobre los datos del usuario actual.
  final _auth = FirebaseAuth.instance;

  /// Obtiene el identificador único (UID) del usuario autenticado actual.
  /// 
  /// Lanza una excepción internamente si se llama cuando no hay un usuario autenticado.
  String get _uid => _auth.currentUser!.uid;

  /// Guarda una nueva cita médica en Firestore y programa su recordatorio.
  ///
  /// [appointment] es la entidad que contiene la información de la cita.
  /// Primero, guarda el documento y luego utiliza el ID generado por 
  /// Firestore para programar notificaciones locales para el usuario.
  Future<void> createAppointment(Appointment appointment) async {
    final docRef = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('appointments')
        .add(appointment.toMap());

    // Se reconstruye la entidad incluyendo el ID generado por Firestore
    // para poder programar correctamente la notificación local.
    final finalAppointment = Appointment(
      id: docRef.id,
      title: appointment.title,
      description: appointment.description,
      patientId: appointment.patientId,
      patientName: appointment.patientName,
      date: appointment.date,
      time: appointment.time,
      doctor: appointment.doctor,
      location: appointment.location,
      notes: appointment.notes,
      attachments: appointment.attachments,
      customReminder: appointment.customReminder,
      customReminderText: appointment.customReminderText,
    );
    
    await NotificationService().scheduleAppointmentNotification(finalAppointment);
  }

  /// Escucha los cambios en la colección de citas médicas en tiempo real.
  ///
  /// Retorna un [Stream] de listas de [Appointment] que la UI puede consumir 
  /// directamente. Transforma internamente cada documento Firestore a entidad de dominio.
  Stream<List<Appointment>> getAppointments() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('appointments')
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(Appointment.fromFirestore).toList(),
        );
  }

  /// Actualiza campos específicos de una cita médica existente.
  ///
  /// [id] es el identificador de la cita y [data] es un Map con los campos a modificar.
  Future<void> updateAppointment(String id, Map<String, dynamic> data) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('appointments')
        .doc(id)
        .update(data);
  }

  /// Elimina una cita médica de Firestore y cancela los recordatorios asociados.
  ///
  /// [appointmentId] es el identificador del documento a eliminar.
  Future<void> deleteAppointment(String appointmentId) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('appointments')
        .doc(appointmentId)
        .delete();

    // Cancela la notificación usando el hashcode generado originalmente a partir del ID.
    // También cancela notificaciones secundarias (por ejemplo, recordatorio custom vs normal).
    await NotificationService().cancelAppointmentNotifications(appointmentId);
  }

  /// Restaura o sobreescribe una cita completa usando su ID original.
  ///
  /// Útil para funcionalidades como "Deshacer" (Undo) donde la cita 
  /// ya tenía un ID y fue eliminada por error.
  Future<void> restoreAppointment(Appointment appointment) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('appointments')
        .doc(appointment.id)
        .set(appointment.toMap());
  }

  /// Actualiza los campos de una cita usando [data] para modificar en la BD.
  ///
  /// [id] es el identificador de la cita a actualizar.
  Future<void> updateAppointmentFields(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('appointments')
        .doc(id)
        .update(data);
  }
}
