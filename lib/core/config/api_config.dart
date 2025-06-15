class ApiConfig {
  // Base URLs for different environments
  static const String baseUrl = 'http://192.168.96.112:44362';
  // static const String baseUrl = 'http://192.168.129.92:44362';

  
  // API Timeout settings
  static const int timeout = 30000; // 30 seconds
  
  // Default headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };
} 