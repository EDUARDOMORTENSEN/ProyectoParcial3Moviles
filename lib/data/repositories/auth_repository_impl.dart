import 'dart:async';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _authDatasource;

  AuthRepositoryImpl(this._authDatasource);

  @override
  Future<UserEntity> login(String email, String password) {
    return _authDatasource.login(email, password);
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String nombre,
    required double peso,
    required double altura,
  }) {
    return _authDatasource.register(
      email: email,
      password: password,
      nombre: nombre,
      peso: peso,
      altura: altura,
    );
  }

  @override
  Future<void> logout() {
    return _authDatasource.logout();
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    return _authDatasource.getCurrentUser();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _authDatasource.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _authDatasource.getCurrentUser();
    });
  }
}
