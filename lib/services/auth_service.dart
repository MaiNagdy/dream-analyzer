import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../config/app_config.dart';

class AuthService {
  static String get baseUrl => AppConfig.baseUrl;
  static const _storage = FlutterSecureStorage();
  
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

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
          'date_of_birth': dateOfBirth?.toIso8601String(),
          'gender': gender,
        };

      print('--- Sending Registration Request ---');
      print('URL: $baseUrl/api/auth/register');
      print('Body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('--- Received Registration Response ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        // Save tokens and user data
        await _saveAuthData(
          data['access_token'],
          data['refresh_token'],
          data['user'],
        );
        return {'success': true, 'user': User.fromJson(data['user'])};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      print('--- Registration Error ---');
      print('Caught exception: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email_or_username': emailOrUsername,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Save tokens and user data
        await _saveAuthData(
          data['access_token'],
          data['refresh_token'],
          data['user'],
        );
        return {'success': true, 'user': User.fromJson(data['user'])};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
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
      print('Logout error: $e');
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

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
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
      print('Token refresh error: $e');
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

  // Make authenticated HTTP request
  Future<http.Response> authenticatedRequest(String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    String? token = await getToken();
    
    if (token == null) {
      throw Exception('No authentication token found. Please login first.');
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
        print('Token expired, attempting to refresh...');
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
          throw Exception('Authentication failed. Please login again.');
        }
      }

      return response;
    } catch (e) {
      print('Request error: $e');
      if (e is http.ClientException) {
        throw Exception('Network error: Unable to connect to server. Please check your connection.');
      }
      rethrow;
    }
  }
} 