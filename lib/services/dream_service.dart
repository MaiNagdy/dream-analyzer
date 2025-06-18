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
      final response = await _authService.authenticatedRequest(
        '/api/dreams/analyze',
        method: 'POST',
                  body: {
            'dreamText': dreamText,
            'mood_before': mood,
            'tags': tags,
          },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          return DreamAnalysis.fromJson(data);
        }
      } else {
        print('Dream analysis failed: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      print('Error analyzing dream: $e');
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
      } else {
        print('Get dream history failed: ${response.statusCode} - ${response.body}');
      }
      return [];
    } catch (e) {
      print('Error getting dream history: $e');
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
      print('Error deleting dream: $e');
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
      print('Error getting user stats: $e');
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
      print('Error getting popular tags: $e');
      return [];
    }
  }

  Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/health'));
      return response.statusCode == 200;
    } catch (e) {
      print('Server health check failed: $e');
      return false;
    }
  }
} 