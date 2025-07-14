import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/dream_analysis.dart';
import '../config/app_config.dart';
import 'auth_service.dart';

class DreamService {
  final AuthService _authService = AuthService();
  
  static String get baseUrl => AppConfig.baseUrl;
  
  Future<DreamAnalysis?> analyzeDream(String dreamText, {String? mood, List<String>? tags}) async {
    try {
      // Ensure user has credits
      final authProviderUser = await _authService.getUser();
      // We just check local storage; proper implementation should query provider

      // Add user context for better AI analysis if available
      String? context;
      try {
        final user = await _authService.getUser();
        if (user != null) {
          context = user.getAIContext();
        }
        debugPrint('👉 Context sent to server: $context');   // أضِف هذا السطر

      } catch (_) {
        // Ignore errors getting user context
      }

      final response = await _authService.authenticatedRequest(
        '/api/dreams/analyze',
        method: 'POST',
        body: {
          'dreamText': dreamText,
          'mood_before': mood,
          'tags': tags,
          if (context != null && context.isNotEmpty) 'context': context,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          return DreamAnalysis.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      // Silent error handling for production
      return null;
    }
  }

  Future<List<DreamAnalysis>> getDreamHistory({int limit = 10, int offset = 0}) async {
    try {
      final response = await _authService.authenticatedRequest(
        '/api/dreams?per_page=$limit&page=${(offset ~/ limit) + 1}',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> dreams = data['dreams'];
          return dreams.map((dream) => DreamAnalysis.fromHistoryJson(dream)).toList();
        }
      }
      return [];
    } catch (e) {
      // Silent error handling for production
      return [];
    }
  }

  Future<bool> deleteDream(String dreamId) async {
    try {
      final response = await _authService.authenticatedRequest(
        '/api/dreams/$dreamId',
        method: 'DELETE',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      // Silent error handling for production
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserStats() async {
    try {
      final response = await _authService.authenticatedRequest(
        '/api/auth/stats',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['stats'];
        }
      }
      return null;
    } catch (e) {
      // Silent error handling for production
      return null;
    }
  }

  Future<List<String>> getPopularTags() async {
    try {
      // This could be implemented in the backend later
      return [
        'كابوس',
        'طيران',
        'مطاردة',
        'ماء',
        'أصدقاء',
        'عائلة',
        'عمل',
        'مدرسة',
        'سفر',
        'حب',
      ];
    } catch (e) {
      // Silent error handling for production
      return [];
    }
  }

  Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/health'))
          .timeout(const Duration(seconds: 2)); // Very short timeout
      return response.statusCode == 200;
    } catch (e) {
      // Silent error handling for production
      return false;
    }
  }
} 