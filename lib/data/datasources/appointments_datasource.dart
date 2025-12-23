import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitacareof/domain/entities/appointment.dart';

class AppointmentsDatasource {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // Guardar cita
  Future<void> createAppointment(Appointment appointment) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('appointments')
        .add(appointment.toMap());
  }

  // Escuchar citas
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
}
