import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

// Obtener todos los usuarios
Future<List> getUsuarios() async {
  List usuarios = [];

  CollectionReference collectionReferenceUsuarios = db.collection('usuarios');

  QuerySnapshot queryUsuarios = await collectionReferenceUsuarios.get();

  for (var doc in queryUsuarios.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final usuario = {"name": data['name'], "uid": doc.id};
    usuarios.add(usuario);
  }

  return usuarios;
}

// Guardar nombre
Future<void> addUsuarios(String name) async {
  await db.collection("usuarios").add({"name": name});
}

// Actualizar nombre
Future<void> updateUsuarios(String uid, String newName) async {
  await db.collection("usuarios").doc(uid).update({"name": newName});
}

// Borrar datos de Firebase
Future<void> deleteUsuarios(String uid) async {
  await db.collection("usuarios").doc(uid).delete();
}
