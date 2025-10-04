import 'package:flutter/material.dart';
import 'package:vitacareof/data/datasources/firebase_auth_datasource.dart';
import 'package:vitacareof/domain/entities/user_entity.dart';


class AuthNotifier extends ChangeNotifier {
  final FirebaseAuthDatasource _authDatasource;

  UserEntity? _user;
  bool _isLoading = false;

  UserEntity? get user => _user;
  bool get isLoading => _isLoading;

  AuthNotifier(this._authDatasource) {
    // Cargar usuario actual al iniciar
    _user = _authDatasource.getCurrentUser();
  }

  /// 🔹 Iniciar sesión
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

  /// 🔹 Registrar usuario nuevo
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

  /// 🔹 Cerrar sesión
  Future<void> logout() async {
    try {
      await _authDatasource.logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error en logout: $e");
    }
  }
}
