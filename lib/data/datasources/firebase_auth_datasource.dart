import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitacareof/domain/entities/user_entity.dart';

/// Datasource que encapsula la lógica de autenticación directa con Firebase.
/// 
/// Pertenece a la capa de datos (Data Layer). Se encarga de traducir
/// las respuestas nativas del SDK de Firebase Auth a entidades de la
/// capa de dominio estable ([UserEntity]). 
class FirebaseAuthDatasource {
  /// Instancia principal del SDK de Firebase Auth, inyectada por el constructor.
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDatasource(this._firebaseAuth);

  /// Autentica de forma asíncrona usando credenciales básicas.
  /// 
  /// Devuelve nil (null) si el proceso falla o se aborta inesperademente, 
  /// o retorna el objeto de dominio [UserEntity] en caso de éxito.
  Future<UserEntity?> login(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    // Early return: Si el usuario es nulo por algún error no detectado
    if (user == null) return null;

    return UserEntity(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  /// Crea una nueva cuenta por correo electrónico y opcionalmente añade un nombre.
  /// 
  /// [displayName] se utiliza para actualizar el perfil del usuario recién creado 
  /// antes de retornarlo, lo que evita desincronizaciones visuales.
  Future<UserEntity?> register(String email, String password, String? displayName) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    // Early Return si falla la creación silenciosamente
    if (user == null) return null;

    // Actualizar el displayName si se proporciona para rellenar
    // correctamente la información de su perfil desde el primer momento.
    if (displayName != null && displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
      await user.reload();
    }

    return UserEntity(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName ?? user.displayName,
    );
  }

  /// Invalida y cierra la sesión actual limpiando las credenciales persistentes.
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// Recupera sincrónicamente al usuario actualmente en sesión.
  /// 
  /// Retorna un [UserEntity] si existe una sesión válida, o nulo si no hay.
  /// Este método es fundamental para validar el estado de auth global durante
  /// el arranque de la app (splash/auth checks).
  UserEntity? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    return UserEntity(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }
}
