class ApiConfig {
  // Base URLs for different environments
  static const String baseUrl = 'https://fakestoreapi.com';
  
  
  // API Timeout settings
  static const int timeout = 30000; // 30 seconds
  
  // Default headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };
} 