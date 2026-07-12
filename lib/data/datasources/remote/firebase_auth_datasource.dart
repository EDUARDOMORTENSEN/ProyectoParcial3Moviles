import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../../core/errors/exceptions.dart';

class FirebaseAuthDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDatasource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw AuthException('No se pudo iniciar sesión');
      }
      final doc = await _firestore
          .collection('usuarios')
          .doc(credential.user!.uid)
          .get();
      if (!doc.exists) {
        throw AuthException('Usuario no encontrado en la base de datos');
      }
      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code), code: e.code);
    }
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String nombre,
    required double peso,
    required double altura,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw AuthException('No se pudo crear la cuenta');
      }

      final userModel = UserModel(
        uid: credential.user!.uid,
        nombre: nombre,
        email: email,
        peso: peso,
        altura: altura,
        fechaRegistro: DateTime.now(),
      );

      await _firestore
          .collection('usuarios')
          .doc(credential.user!.uid)
          .set(userModel.toJson());

      // Initialize statistics document
      await _firestore
          .collection('estadisticas')
          .doc(credential.user!.uid)
          .set({
        'semana_actual': {
          'distancia_total': 0,
          'pasos_total': 0,
          'tiempo_total': 0,
          'entrenamientos': 0,
        },
        'mes_actual': {
          'distancia_total': 0,
          'pasos_total': 0,
          'tiempo_total': 0,
          'entrenamientos': 0,
        },
        'mejor_distancia': 0,
        'mejor_tiempo': 0,
        'racha_dias': 0,
      });

      // Initialize ranking document
      await _firestore
          .collection('ranking')
          .doc(credential.user!.uid)
          .set({
        'nombre': nombre,
        'foto_url': null,
        'distancia_total_km': 0,
        'pasos_total': 0,
        'entrenamientos_total': 0,
        'posicion': 0,
      });

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code), code: e.code);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('usuarios').doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String get currentUserId => _auth.currentUser?.uid ?? '';

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        return 'Error de autenticación: $code';
    }
  }
}
