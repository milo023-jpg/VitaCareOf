import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitacareof/domain/entities/medicine.dart';
import 'package:vitacareof/services/notification_service.dart';

/// Datasource encargado de gestionar los medicamentos del usuario en Firebase Firestore.
/// 
/// Esta clase actúa como la capa de datos (Data Layer) especializada en 
/// el manejo de la colección `medicines` del usuario autenticado, implementando
/// operaciones CRUD básicas y la programación de recordatorios.
class MedicinesDatasource {
  /// Instancia de Firestore para interactuar con la base de datos NoSQL.
  final _firestore = FirebaseFirestore.instance;
  
  /// Instancia de FirebaseAuth para asegurar que las operaciones se realicen 
  /// sobre los datos del usuario actual de manera segura.
  final _auth = FirebaseAuth.instance;

  /// Obtiene el identificador único (UID) del usuario autenticado actual.
  /// 
  /// Necesario para estructurar las rutas de Firestore por usuario.
  String get _uid => _auth.currentUser!.uid;

  /// Guarda un nuevo medicamento en Firestore y programa su recordatorio.
  ///
  /// [medicine] es la entidad del dominio que contiene toda la configuración
  /// del medicamento. Al guardarse, se recupera el ID asignado por Firestore
  /// para poder asociar correctamente las notificaciones.
  Future<void> createMedicine(Medicine medicine) async {
    final docRef = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('medicines')
        .add(medicine.toMap());

    // Se reconstruye la entidad con el ID generado en backend para programar
    // de manera unívoca la notificación local, posibilitando luego su cancelación.
    final finalMedicine = Medicine(
        id: docRef.id,
        name: medicine.name,
        patientId: medicine.patientId,
        patientName: medicine.patientName,
        scheduleType: medicine.scheduleType,
        durationType: medicine.durationType,
        createdAt: medicine.createdAt,
        time: medicine.time,
        repeat: medicine.repeat,
        daysOfWeek: medicine.daysOfWeek,
        intervalHours: medicine.intervalHours,
        startTime: medicine.startTime,
        durationDays: medicine.durationDays,
        endDate: medicine.endDate,
        isActive: medicine.isActive,
        description: medicine.description,
        type: medicine.type,
    );
    await NotificationService().scheduleMedicineNotification(finalMedicine);
  }

  /// Escucha los cambios en la colección de medicamentos en tiempo real.
  ///
  /// Retorna un [Stream] de listas de [Medicine] que la interfaz de usuario
  /// consumirá para mostrar la lista de medicamentos actualizados.
  Stream<List<Medicine>> getMedicines() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('medicines')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Medicine.fromFirestore).toList());
  }

  /// Cambia rápidamente el estado activo/inactivo de un medicamento.
  ///
  /// [medicine] es el medicamento y [value] el nuevo estado booleano.
  Future<void> toggleMedicine(Medicine medicine, bool value) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('medicines')
        .doc(medicine.id)
        .update({'isActive': value});
        
    final updatedMedicine = medicine.copyWith(isActive: value);
    await NotificationService().scheduleMedicineNotification(updatedMedicine);
  }

  /// Actualiza campos específicos de un medicamento existente.
  ///
  /// [id] es el identificador del documento y [data] es un Map con los campos a modificar.
  Future<void> updateMedicine(String id, Map<String, dynamic> data) async {
  await _firestore
      .collection('users')
      .doc(_uid)
      .collection('medicines')
      .doc(id)
      .update(data);
}

/// Elimina un medicamento de Firestore y cancela sus recordatorios programados.
///
/// [id] es el identificador del documento a eliminar.
Future<void> deleteMedicine(String id) async {
  await _firestore
      .collection('users')
      .doc(_uid)
      .collection('medicines')
      .doc(id)
      .delete();
      
  // Al eliminar de la base de datos es vital limpiar las notificaciones locales
  // para evitar enviar alertas "fantasma" de medicamentos que ya no existen.
  await NotificationService().cancelMedicineNotifications(id);
}

}
