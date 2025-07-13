import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoggedIn = false;
  bool _isInitializing = true; // Changed from _isLoading, starts true
  bool _isLoading = false; // Added back for logout compatibility
  String? _lastError;
  int _credits = 0; // dream credits remaining

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitializing => _isInitializing; // Getter for the new state
  bool get isLoading => _isLoading; // Getter for legacy loading usage
  String? get lastError => _lastError;
  int get credits => _credits;

  // Initialize authentication state
  Future<void> init() async {
    // This now uses the _isInitializing flag
    if (!_isInitializing) {
      _isInitializing = true;
      notifyListeners();
    }
    
    _lastError = null;

    try {
      // Much shorter timeout for connectivity check
      final isServerReachable = await _authService.checkServerConnectivity()
          .timeout(const Duration(seconds: 2));

      if (!isServerReachable) {
        // Server not reachable, check local auth state immediately
        final token = await _authService.getToken();
        if (token != null) {
          // We have a token, try to get user data from local storage
          try {
            _user = await _authService.getUser();
            _isLoggedIn = _user != null;
          } catch (e) {
            _isLoggedIn = false;
            _user = null;
          }
        } else {
          _isLoggedIn = false;
          _user = null;
        }
      } else {
        // Server is reachable, do quick check
        try {
          final isLoggedInResult = await _authService.isLoggedIn()
              .timeout(const Duration(seconds: 3));
          
          _isLoggedIn = isLoggedInResult;
          
          if (_isLoggedIn) {
            try {
              _user = await _authService.getUser()
                  .timeout(const Duration(seconds: 3));
            } catch (e) {
              print('Failed to get user data: $e');
              // Keep logged in status but clear user data
              _user = null;
            }
          }
        } catch (e) {
          print('Auth check failed: $e');
          // Fall back to token check immediately
          final token = await _authService.getToken();
          _isLoggedIn = token != null;
          if (_isLoggedIn) {
            try {
              _user = await _authService.getUser();
            } catch (e) {
              _user = null;
            }
          }
        }
      }
    } catch (e) {
      // Handle timeout or other errors gracefully
      print('Auth initialization error: $e');
      _lastError = e.toString();
      
      // Always try to recover from local storage
      try {
        final token = await _authService.getToken();
        if (token != null) {
          _user = await _authService.getUser();
          _isLoggedIn = _user != null;
        } else {
          _isLoggedIn = false;
          _user = null;
        }
      } catch (e) {
        _isLoggedIn = false;
        _user = null;
      }
    }

    _isInitializing = false;
    notifyListeners();
  }

  // Login user
  Future<Map<String, dynamic>> login(String emailOrUsername, String password) async {
    // This method NO LONGER manages a global loading state.
    // The LoginScreen will manage its own loading indicator.
    _lastError = null;
    
    try {
      final result = await _authService.login(
        emailOrUsername: emailOrUsername,
        password: password,
      ).timeout(const Duration(seconds: 15));

      if (result['success']) {
        _isLoggedIn = true;
        _user = result['user'];
        _lastError = null;
        notifyListeners(); // IMPORTANT: Notify listeners only on success to trigger navigation
      } else {
        _lastError = result['message'];
        // On failure, we don't notify listeners globally.
        // We just return the result to the LoginScreen.
      }
      return result;
    } catch (e) {
      _lastError = e.toString();

      String errorMessage = 'مشكلة في الاتصال بالإنترنت. يرجى المحاولة مرة أخرى';
      if (e.toString().contains('timeout')) {
        errorMessage = 'انتهت مهلة الانتظار. يرجى المحاولة مرة أخرى';
      } else if (e.toString().contains('connection')) {
        errorMessage = 'مشكلة في الاتصال بالخادم';
      }

      return {
        'success': false,
        'message': errorMessage
      };
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
    // This method also no longer manages a global loading state.
    _lastError = null;

    try {
      final result = await _authService.register(
        email: email,
        username: username,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        gender: gender,
      ).timeout(const Duration(seconds: 15));

      if (result['success']) {
        _isLoggedIn = true;
        _user = result['user'];
        _lastError = null;
        notifyListeners(); // Notify on success
      } else {
        _lastError = result['message'];
      }

      return result;
    } catch (e) {
      _lastError = e.toString();

      String errorMessage = 'مشكلة في الاتصال بالإنترنت. يرجى المحاولة مرة أخرى';
      if (e.toString().contains('timeout')) {
        errorMessage = 'انتهت مهلة الانتظار. يرجى المحاولة مرة أخرى';
      } else if (e.toString().contains('connection')) {
        errorMessage = 'مشكلة في الاتصال بالخادم';
      }
      
      return {
        'success': false,
        'message': errorMessage
      };
    }
  }

  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout().timeout(const Duration(seconds: 10));
    } catch (e) {
      // Silent error handling for logout
      print('Logout error: $e');
    }

    _isLoggedIn = false;
    _user = null;
    _lastError = null;
    _isLoading = false;
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (!_isLoggedIn) return;
    
    try {
      final newUser = await _authService.getUser()
          .timeout(const Duration(seconds: 10));
      
      if (newUser != null) {
        _user = newUser;
        notifyListeners();
      }
    } catch (e) {
      print('Failed to refresh user: $e');
      // Don't logout on refresh failure, just keep existing user data
    }
  }

  // ----------- Credits helpers -----------
  void addCredits(int amount) {
    _credits += amount;
    notifyListeners();
  }

  bool consumeCredit() {
    if (_credits <= 0) return false;
    _credits -= 1;
    notifyListeners();
    return true;
  }

  // Clear error state
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  // Update user settings locally and persist to secure storage
  Future<void> updateUserSettings(Map<String, dynamic> settingsData) async {
    if (_user == null) return;

    // Create an updated copy of the user model
    _user = _user!.copyWith(
      gender: settingsData['gender'] as String?,
      ageRange: settingsData['age_range'] as String?,
      relationshipStatus: settingsData['relationship_status'] as String?,
      job: settingsData['job'] as String?,
      hobbies: settingsData['hobbies'] as String?,
      personality: settingsData['personality'] as String?,
      currentConcerns: settingsData['current_concerns'] as String?,
    );

    notifyListeners(); // Update UI immediately

    // Persist changes locally so they survive app restarts
    try {
      await _authService.saveUserData(_user!);
    } catch (e) {
      // Log but don't crash if secure-storage write fails
      print('Failed to persist user settings: $e');
    }
  }

  // Check if user is online
  Future<bool> checkConnectivity() async {
    try {
      return await _authService.checkServerConnectivity()
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      return false;
    }
  }
} 