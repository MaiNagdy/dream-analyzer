import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../config/app_config.dart';
import 'package:intl/intl.dart';

class AuthService {
  static String get baseUrl => AppConfig.baseUrl;
  static const _storage = FlutterSecureStorage();
  
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  // Translate error messages to Arabic
  String _translateError(String error, {String? statusCode}) {
    final errorLower = error.toLowerCase();
    
    // Registration errors
    if (errorLower.contains('email already') || errorLower.contains('already registered') || 
        errorLower.contains('email exists') || errorLower.contains('duplicate')) {
      return 'البريد الإلكتروني مسجل مسبقاً. يرجى تسجيل الدخول أو استخدام بريد إلكتروني آخر';
    }
    
    if (errorLower.contains('username already') || errorLower.contains('username exists')) {
      return 'اسم المستخدم مستخدم مسبقاً. يرجى اختيار اسم مستخدم آخر';
    }
    
    // Login errors
    if (errorLower.contains('invalid credentials') || errorLower.contains('wrong password') ||
        errorLower.contains('incorrect password') || errorLower.contains('incorrect password')) {
      return 'كلمة المرور غير صحيحة. يرجى المحاولة مرة أخرى';
    }
    
    if (errorLower.contains('user not found') || errorLower.contains('no user found') ||
        errorLower.contains('user does not exist') || errorLower.contains('email not found')) {
      return 'لم يتم العثور على المستخدم. يرجى التحقق من البيانات أو إنشاء حساب جديد';
    }
    
    if (errorLower.contains('account disabled') || errorLower.contains('user disabled')) {
      return 'الحساب معطل. يرجى التواصل مع الدعم الفني';
    }
    
    // Network errors
    if (errorLower.contains('network') || errorLower.contains('connection') ||
        errorLower.contains('timeout') || errorLower.contains('unable to connect')) {
      return 'مشكلة في الاتصال بالإنترنت. يرجى المحاولة مرة أخرى';
    }
    
    // Server errors
    if (statusCode == '500' || errorLower.contains('internal server')) {
      return 'خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً';
    }
    
    if (statusCode == '400' || errorLower.contains('bad request')) {
      return 'بيانات غير صحيحة. يرجى التحقق من المعلومات المدخلة';
    }
    
    if (statusCode == '403' || errorLower.contains('forbidden')) {
      return 'غير مسموح لك بالوصول. يرجى التواصل مع الدعم الفني';
    }
    
    // Validation errors
    if (errorLower.contains('email format') || errorLower.contains('invalid email')) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    
    if (errorLower.contains('password') && errorLower.contains('length')) {
      return 'كلمة المرور قصيرة جداً. يجب أن تكون 6 أحرف على الأقل';
    }
    
    if (errorLower.contains('username') && errorLower.contains('length')) {
      return 'اسم المستخدم قصير جداً. يجب أن يكون 3 أحرف على الأقل';
    }
    
    // Generic errors
    if (errorLower.contains('registration failed') || errorLower.contains('signup failed')) {
      return 'فشل في إنشاء الحساب. يرجى المحاولة مرة أخرى';
    }
    
    // Note: we intentionally removed the generic "login failed" catch-all
    // so that specific translations like "incorrect password" or
    // "user not found" are shown instead. Unrecognised login errors will
    // fall through to the generic unexpected-error message below.
    
    // If no specific translation found, return a generic Arabic message
    return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    try {
      final requestBody = {
          'email': email,
          'username': username,
          'password': password,
          'first_name': fullName?.split(' ').first,
          'last_name': fullName != null && fullName.split(' ').length > 1 ? fullName.split(' ').skip(1).join(' ') : null,
          'phone_number': phoneNumber,
          'date_of_birth': dateOfBirth != null
              ? DateFormat('yyyy-MM-dd').format(dateOfBirth)
              : null,
          'gender': gender,
        };
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 10)); // Add timeout
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Save tokens and user data
        await _saveAuthData(
          data['access_token'],
          data['refresh_token'],
          data['user'],
        );
        return {'success': true, 'user': User.fromJson(data['user'])};
      } else {
        String errorMessage = 'فشل في إنشاء الحساب';
        
        try {
          final data = jsonDecode(response.body);
          if (data['message'] != null) {
            errorMessage = _translateError(data['message'], statusCode: response.statusCode.toString());
          } else if (data['error'] != null) {
            errorMessage = _translateError(data['error'], statusCode: response.statusCode.toString());
          }
        } catch (e) {
          errorMessage = _translateError('Registration failed', statusCode: response.statusCode.toString());
        }
        
        return {
          'success': false, 
          'message': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('🔴 AuthService.login() exception: $e');
      final result = {
        'success': false, 
        'message': _translateError('Network error: $e'),
      };
      print('🔴 Returning exception result: $result');
      return result;
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      print('🔵 AuthService.login() called');
      print('🔵 Server URL: $baseUrl/api/auth/login');
      print('🔵 Request body: ${jsonEncode({
        'email_or_username': emailOrUsername,
        'password': '***',
      })}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email_or_username': emailOrUsername,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10)); // Add timeout

      print('🔵 Server response received:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Body: ${response.body}');
      print('   Headers: ${response.headers}');

      if (response.statusCode == 200) {
        print('🟢 Login successful (status 200)');
        final data = jsonDecode(response.body);
        // Save tokens and user data
        await _saveAuthData(
          data['access_token'],
          data['refresh_token'],
          data['user'],
        );
        return {'success': true, 'user': User.fromJson(data['user'])};
      } else {
        print('🔴 Login failed with status: ${response.statusCode}');
        String errorMessage = 'فشل في تسجيل الدخول';
        
        try {
          final data = jsonDecode(response.body);
          print('🔴 Error response data: $data');
          if (data['message'] != null) {
            errorMessage = _translateError(data['message'], statusCode: response.statusCode.toString());
          } else if (data['error'] != null) {
            errorMessage = _translateError(data['error'], statusCode: response.statusCode.toString());
          }
        } catch (e) {
          print('🔴 Failed to parse error response: $e');
          errorMessage = _translateError('Login failed', statusCode: response.statusCode.toString());
        }
        
        final result = {
          'success': false, 
          'message': errorMessage,
          'statusCode': response.statusCode,
        };
        print('🔴 Returning error result: $result');
        return result;
      }
    } catch (e) {
      return {
        'success': false, 
        'message': _translateError('Network error: $e'),
      };
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/api/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      // Silent logout - don't expose errors to user
    } finally {
      await _clearAuthData();
    }
  }

  // Get stored token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Get stored user
  Future<User?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Check if server is reachable
  Future<bool> checkServerConnectivity() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 2)); // Very short timeout
      
      return response.statusCode == 200;
    } catch (e) {
      print('Server connectivity check failed: $e');
      return false;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      if (token == null) return false;
      
      // For faster startup, just check if we have a token
      // Skip server validation during initialization
      return true;
    } catch (e) {
      print('isLoggedIn check failed: $e');
      return false;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: _tokenKey, value: data['access_token']);
        return true;
      }
    } catch (e) {
      // Silent error handling for production
    }
    return false;
  }

  // Save authentication data
  Future<void> _saveAuthData(String accessToken, String refreshToken, Map<String, dynamic> userData) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userKey, value: jsonEncode(userData));
  }

  // Clear authentication data
  Future<void> _clearAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }

  // Save ONLY the user object locally (without touching tokens)
  Future<void> saveUserData(User user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  // Make authenticated HTTP request
  Future<http.Response> authenticatedRequest(String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    String? token = await getToken();
    
    if (token == null) {
      throw Exception('لم يتم العثور على رمز المصادقة. يرجى تسجيل الدخول أولاً');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    http.Response response;
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          response = await http.get(uri, headers: headers);
      }

      // If unauthorized, try to refresh token
      if (response.statusCode == 401) {
        // Token expired, attempting to refresh
        if (await refreshToken()) {
          token = await getToken();
          headers['Authorization'] = 'Bearer $token';
          
          switch (method.toUpperCase()) {
            case 'POST':
              response = await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
              break;
            case 'PUT':
              response = await http.put(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
              break;
            case 'DELETE':
              response = await http.delete(uri, headers: headers);
              break;
            default:
              response = await http.get(uri, headers: headers);
          }
        } else {
          // If refresh failed, clear auth data and throw exception
          await _clearAuthData();
          throw Exception('انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى');
        }
      }

      return response;
    } catch (e) {
      // Request error occurred
      if (e is http.ClientException) {
        throw Exception('خطأ في الشبكة: غير قادر على الاتصال بالخادم. يرجى التحقق من الاتصال');
      }
      rethrow;
    }
  }

  // Subscription-related methods
  Future<Map<String, dynamic>?> getSubscriptionStatus() async {
    try {
      final response = await authenticatedRequest('/api/subscriptions/status');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Failed to get subscription status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Get subscription status error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifySubscription(String productId, String purchaseToken) async {
    try {
      final response = await authenticatedRequest('/api/subscriptions/verify', 
        method: 'POST',
        body: {
          'productId': productId,
          'purchaseToken': purchaseToken,
        });
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Failed to verify subscription: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Verify subscription error: $e');
      return null;
    }
  }

  Future<bool> cancelSubscription() async {
    try {
      final response = await authenticatedRequest('/api/subscriptions/cancel', method: 'POST');
      
      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Failed to cancel subscription: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Cancel subscription error: $e');
      return false;
    }
  }
} 