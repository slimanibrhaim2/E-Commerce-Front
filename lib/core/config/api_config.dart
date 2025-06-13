class ApiConfig {
  // Base URLs for different environments
  static const String baseUrl = 'http://192.168.43.92:44372';
  
  
  // API Timeout settings
  static const int timeout = 3000; // 30 seconds
  
  // Default headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };
} 