import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitacareof/domain/entities/patient.dart';

/// Datasource encargado de la gestión de pacientes en Firebase Firestore.
/// 
/// Corresponde a la capa de datos (Data Layer). Centraliza la lógica para
/// crear, leer e iterar sobre los pacientes asociados a un usuario médico/cuidador.
class PatientsDatasource {
  /// Cliente de Firestore para comunicación abstracta con la base de datos de documentos.
  final _firestore = FirebaseFirestore.instance;

  /// Cliente de FirebaseAuth para verificar el contexto del usuario actual.
  final _auth = FirebaseAuth.instance;

  /// Retorna el UID del usuario que ha iniciado sesión actualmente.
  String get _uid => _auth.currentUser!.uid;

  /// Helper privado que obtiene la referencia directa a la colección `patients` 
  /// del usuario actual, facilitando la construcción de consultas seguras por usuario.
  CollectionReference<Map<String, dynamic>> get _patientsRef =>
      _firestore.collection('users').doc(_uid).collection('patients');

  /// Abre un stream persistente con los pacientes del usuario activo.
  /// 
  /// Convierte los documentos crudos de Firestore en listas de entidades [Patient].
  /// Muy útil para reaccionar a cambios en tiempo real dentro de la UI.
  Stream<List<Patient>> getPatients() {
    return _patientsRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                // Es vital pasar el doc.id para la correcta manipulación de la entidad
                Patient.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();
    });
  }

  /// Añade un nuevo paciente asíncronamente con un timestamp inicial.
  /// 
  /// [name] es el identificador visual del paciente. El ID del documento 
  /// se generará y asignará automáticamente a través de Firebase.
  Future<void> addPatient(String name) async {
    await _patientsRef.add({'name': name, 'createdAt': Timestamp.now()});
  }
}
