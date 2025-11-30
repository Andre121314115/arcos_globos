import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      _authService.authStateChanges.listen((user) async {
        try {
          if (user != null) {
            _currentUser = await _authService.getCurrentUserData();
          } else {
            _currentUser = null;
          }
          notifyListeners();
        } catch (e) {
          debugPrint('Error en authStateChanges: $e');
          _currentUser = null;
          notifyListeners();
        }
      });
      
      if (_authService.currentUser != null) {
        try {
          _currentUser = await _authService.getCurrentUserData();
          notifyListeners();
        } catch (e) {
          debugPrint('Error al obtener usuario actual: $e');
        }
      }
    } catch (e) {
      debugPrint('Error en _init: $e');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    UserRole role = UserRole.client,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
      );
    } catch (e) {
      debugPrint('Error en signUp: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.signIn(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Error en signIn: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}

