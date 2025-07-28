import 'package:http/http.dart' as http;

class AppConfig {
  static const String _productionBaseUrl = 'https://dream-analyzer-backend-429952025254.us-central1.run.app'; // Your Google Cloud Run deployment
  static const String _developmentBaseUrl = 'http://localhost:5000';
  static const String _emulatorBaseUrl = 'http://10.0.2.2:5000';
  
  // Set this to true for production/app store, false for local testing
  static const bool useProductionBackend = true; // Changed back to true for app store
  
  // Network timeout settings
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration requestTimeout = Duration(seconds: 15);
  static const Duration shortTimeout = Duration(seconds: 5);
  
  static String get baseUrl {
    if (useProductionBackend) {
      return _productionBaseUrl;
    }
    
    // For development/testing - use emulator URL for Android emulator
    return _emulatorBaseUrl;
  }
  
  // Alternative method to auto-detect environment
  static String get autoDetectBaseUrl {
    if (useProductionBackend) {
      return _productionBaseUrl;
    }
    
    // Check if running on real device vs emulator
    // This is a simple heuristic - you might want to improve this
    try {
      return _emulatorBaseUrl; // Default to emulator for development
    } catch (e) {
      return _developmentBaseUrl;
    }
  }
  
  // Network connectivity check
  static Future<bool> checkConnectivity() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(shortTimeout);
      
      final code = response.statusCode;
      // Some servers return 405 Method Not Allowed if /api/health exists
      // but only accepts POST. Treat 200 (OK) or 405 (Method Not Allowed)
      // as "server is reachable" so the app does not show offline erroneously.
      return code == 200 || code == 405;
    } catch (e) {
      return false;
    }
  }
  
  // Get server status with details
  static Future<Map<String, dynamic>> getServerStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(shortTimeout);
      
      if (response.statusCode == 200) {
        return {
          'online': true,
          'statusCode': response.statusCode,
          'message': 'Server is healthy',
        };
      } else {
        return {
          'online': false,
          'statusCode': response.statusCode,
          'message': 'Server returned error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'online': false,
        'statusCode': null,
        'message': 'Connection failed: ${e.toString()}',
      };
    }
  }
} 