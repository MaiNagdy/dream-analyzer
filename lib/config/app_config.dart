class AppConfig {
  static const String _productionBaseUrl = 'https://your-app-name.railway.app'; // Replace with your deployed URL
  static const String _developmentBaseUrl = 'http://localhost:5000';
  static const String _emulatorBaseUrl = 'http://10.0.2.2:5000';
  
  // Set this to true when you want to use the production backend
  static const bool useProductionBackend = true; // Change this to use production
  
  static String get baseUrl {
    if (useProductionBackend) {
      return _productionBaseUrl;
    }
    
    // For development/testing
    return _developmentBaseUrl;
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
} 