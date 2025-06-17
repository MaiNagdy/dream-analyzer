import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  // Initialize authentication state
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        _user = await _authService.getUser();
      }
    } catch (e) {
      print('Auth init error: $e');
      _isLoggedIn = false;
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login user
  Future<Map<String, dynamic>> login(String emailOrUsername, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(
        emailOrUsername: emailOrUsername,
        password: password,
      );

      if (result['success']) {
        _isLoggedIn = true;
        _user = result['user'];
      }

      _isLoading = false;
      notifyListeners();
      
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'خطأ في الشبكة: $e'};
    }
  }

  // Register user
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.register(
        email: email,
        username: username,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );

      if (result['success']) {
        _isLoggedIn = true;
        _user = result['user'];
      }

      _isLoading = false;
      notifyListeners();
      
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'خطأ في الشبكة: $e'};
    }
  }

  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (e) {
      print('Logout error: $e');
    }

    _isLoggedIn = false;
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUser() async {
    try {
      _user = await _authService.getUser();
      notifyListeners();
    } catch (e) {
      print('User refresh error: $e');
    }
  }
} 