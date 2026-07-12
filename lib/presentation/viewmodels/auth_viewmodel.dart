import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRepository _authRepository;

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthViewModel({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _authRepository = authRepository;

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  Future<void> checkAuthState() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authRepository.getCurrentUser();
    } catch (e) {
      _currentUser = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _loginUseCase(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
    required double peso,
    required double altura,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _registerUseCase(
        email: email,
        password: password,
        nombre: nombre,
        peso: peso,
        altura: altura,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _logoutUseCase();
      _currentUser = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
