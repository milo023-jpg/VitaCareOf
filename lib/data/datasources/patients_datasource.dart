import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitacareof/domain/entities/patient.dart';

class PatientsDatasource {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _patientsRef =>
      _firestore.collection('users').doc(_uid).collection('patients');

  Stream<List<Patient>> getPatients() {
    return _patientsRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                Patient.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Future<void> addPatient(String name) {
    return _patientsRef.add({'name': name, 'createdAt': Timestamp.now()});
  }
}
