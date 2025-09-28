import 'package:flutter/material.dart';
import 'package:vitacareof/data/datasources/firebase_auth_datasource.dart';
import 'package:vitacareof/domain/entities/user_entity.dart';

class AuthNotifier extends ChangeNotifier {
  final FirebaseAuthDatasource _authDatasource;

  UserEntity? _user;
  UserEntity? get user => _user;

  AuthNotifier(this._authDatasource);

  Future<void> login(String email, String password) async {
    _user = await _authDatasource.login(email, password);
    notifyListeners();
  }

  Future<void> logout() async {
    await _authDatasource.logout();
    _user = null;
    notifyListeners();
  }

  void loadCurrentUser() {
    _user = _authDatasource.getCurrentUser();
    notifyListeners();
  }
}
