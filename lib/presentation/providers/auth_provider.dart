import 'package:flutter/material.dart';
import 'package:vitacareof/data/datasources/firebase_auth_datasource.dart';
import 'package:vitacareof/domain/entities/user_entity.dart';

/// Provider encargado del manejo global del estado de autenticación.
/// 
/// Actúa en la capa de Presentación interactuando directamente con el 
/// [FirebaseAuthDatasource]. Notifica a los widgets dependientes (consumidores)
/// cada vez que el usuario inicia sesión, se registra o cierra sesión.
class AuthNotifier extends ChangeNotifier {
  /// Dependencia hacia la capa de datos inyectada exteriormente.
  final FirebaseAuthDatasource _authDatasource;

  /// Mantiene en memoria los datos del usuario autenticado actualmente.
  UserEntity? _user;

  /// Bandera para mostrar indicadores de carga en la UI durante flujos asíncronos.
  bool _isLoading = false;

  /// Getter público para acceder al usuario actual sin permitir mutación directa.
  UserEntity? get user => _user;

  /// Getter público para conocer si hay una llamada de red en curso.
  bool get isLoading => _isLoading;

  AuthNotifier(this._authDatasource) {
    // Cargar usuario actual al iniciar la aplicación sincrónicamente
    _user = _authDatasource.getCurrentUser();
  }

  /// Inicia sesión con correo y contraseña.
  /// 
  /// Desencadena cambios de estado (`isLoading` a true/false).
  /// Retorna un `bool` que la pantalla de Login evalúa para decidir
  /// si navega al Home (true) o si mantiene al usuario mostrando un error (false).
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final loggedUser = await _authDatasource.login(email, password);

      _user = loggedUser;
      _isLoading = false;
      notifyListeners();

      return _user != null;
    } catch (e) {
      debugPrint("❌ Error en login: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Registra un nuevo usuario asociándolo a Firebase.
  /// 
  /// Sincroniza el [displayName] elegido con Firebase internamente.
  /// Retorna `true` si la operación concluye exitosamente permitiendo
  /// la navegación hacia la pantalla principal.
  Future<bool> register(String email, String password, String displayName) async {
    try {
      _isLoading = true;
      notifyListeners();

      final newUser = await _authDatasource.register(email, password, displayName);

      _user = newUser;
      _isLoading = false;
      notifyListeners();

      return _user != null;
    } catch (e) {
      debugPrint("❌ Error en register: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Limpia la sesión viva y notifica a los listeners.
  ///
  /// Típicamente esto causa que un [GoRouter] o un wrapper superior de auth
  /// expulse al usuario instantáneamente a la pantalla de Login.
  Future<void> logout() async {
    try {
      await _authDatasource.logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error en logout: $e");
    }
  }

  /// Actualiza los datos de la memoria forzando una consulta local nueva.
  /// 
  /// Útil si el usuario edita su perfil (ej. cambia su nombre de display
  /// desde ProfileScreen) y necesitamos que el Drawer/AppBar se enteren.
  void refreshUser() {
    _user = _authDatasource.getCurrentUser();
    notifyListeners();
  }
}
