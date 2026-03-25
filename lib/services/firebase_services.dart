import 'package:cloud_firestore/cloud_firestore.dart';

/// Instancia de Firestore que provee el punto de entrada para las operaciones CRUD.
FirebaseFirestore db = FirebaseFirestore.instance;

/// Servicio auxiliar legacy/simple para obtener y parsear de la colección `usuarios`.
/// 
/// Retorna una lista de Map integrando explícitamente el `uid` en cada objeto.
Future<List> getUsuarios() async {
  List usuarios = [];

  CollectionReference collectionReferenceUsuarios = db.collection('usuarios');

  // Lee toda la colección de una vez sin escuchar streams
  QuerySnapshot queryUsuarios = await collectionReferenceUsuarios.get();

  for (var doc in queryUsuarios.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final usuario = {"name": data['name'], "uid": doc.id};
    usuarios.add(usuario);
  }

  return usuarios;
}

/// Añade un nuevo documento en la colección `usuarios` con un ID generado automáticamente.
Future<void> addUsuarios(String name) async {
  await db.collection("usuarios").add({"name": name});
}

/// Actualiza específicamente el campo "name" de un usuario identificado por su [uid].
/// 
/// Esto no reemplaza todo el documento, útil para parches incrementales.
Future<void> updateUsuarios(String uid, String newName) async {
  await db.collection("usuarios").doc(uid).update({"name": newName});
}

/// Elimina destructivamente el documento del usuario en Firebase correspondiente al [uid].
Future<void> deleteUsuarios(String uid) async {
  await db.collection("usuarios").doc(uid).delete();
}
