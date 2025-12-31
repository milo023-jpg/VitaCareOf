import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitacareof/domain/entities/medicine.dart';

class MedicinesDatasource {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  Future<void> createMedicine(Medicine medicine) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('medicines')
        .add(medicine.toMap());
  }

  Stream<List<Medicine>> getMedicines() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('medicines')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Medicine.fromFirestore).toList());
  }

  Future<void> toggleMedicine(String id, bool value) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('medicines')
        .doc(id)
        .update({'isActive': value});
  }

  Future<void> updateMedicine(String id, Map<String, dynamic> data) async {
  await _firestore
      .collection('users')
      .doc(_uid)
      .collection('medicines')
      .doc(id)
      .update(data);
}

Future<void> deleteMedicine(String id) async {
  await _firestore
      .collection('users')
      .doc(_uid)
      .collection('medicines')
      .doc(id)
      .delete();
}

}
