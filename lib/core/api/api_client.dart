import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'api_exception.dart';
import 'api_endpoints.dart';
import 'dart:io';

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  String? _jwtToken;

  ApiClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  void setToken(String? token) {
    _jwtToken = token;
  }

  /// Constructs a media URL for accessing files through the media API
  String getMediaUrl(String filePath) {
    if (filePath.isEmpty) return '';
    
    // Remove any leading slashes to avoid double slashes
    final cleanPath = filePath.startsWith('/') ? filePath.substring(1) : filePath;
    return '$baseUrl${ApiEndpoints.mediaFile}$cleanPath';
  }

  /// Constructs a category image URL for accessing category images
  String getCategoryImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    
    // Remove any leading slashes to avoid double slashes
    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '$baseUrl${ApiEndpoints.categoryImage}$cleanPath';
  }

  /// Constructs a user file URL for accessing user files (like profile photos)
  String getUserFileUrl(String filePath) {
    if (filePath.isEmpty) return '';
    
    // Remove any leading slashes to avoid double slashes
    final cleanPath = filePath.startsWith('/') ? filePath.substring(1) : filePath;
    // Add cache-busting parameter to ensure fresh images
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$baseUrl${ApiEndpoints.userFile}$cleanPath?t=$timestamp';
  }

  Map<String, String> _buildHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_jwtToken != null && _jwtToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_jwtToken';
    }
    return headers;
  }

  Map<String, String> buildMultipartHeaders() {
    final headers = <String, String>{};
    if (_jwtToken != null && _jwtToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_jwtToken';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final url = '$baseUrl$endpoint';
      print('ApiClient GET request to: $url');
      
      final response = await _client.get(
        Uri.parse(url),
        headers: _buildHeaders(),
      ).timeout(
        Duration(milliseconds: ApiConfig.timeout),
        onTimeout: () {
          throw ApiException.timeout();
        },
      );
      
      print('ApiClient GET response status: ${response.statusCode}');
      print('ApiClient GET response body: ${response.body}');
      
      return _handleResponse(response);
    } on http.ClientException {
      throw ApiException.connectionError();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.serverError('فشل في الاتصال بالخادم. يرجى المحاولة مرة أخرى لاحقاً.');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(),
        body: json.encode(data),
      ).timeout(
        Duration(milliseconds: ApiConfig.timeout),
        onTimeout: () {
          throw ApiException.timeout();
        },
      );
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      print('ApiClient POST ClientException: $e');
      throw ApiException.connectionError();
    } catch (e) {
      print('ApiClient POST Generic Exception: $e');
      if (e is ApiException) rethrow;
      throw ApiException.serverError('فشل في إرسال البيانات. يرجى المحاولة مرة أخرى لاحقاً.');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(),
        body: json.encode(data),
      ).timeout(
        Duration(milliseconds: ApiConfig.timeout),
        onTimeout: () {
          throw ApiException.timeout();
        },
      );
      return _handleResponse(response);
    } on http.ClientException {
      throw ApiException.connectionError();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.serverError('فشل في تحديث البيانات. يرجى المحاولة مرة أخرى لاحقاً.');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(),
      ).timeout(
        Duration(milliseconds: ApiConfig.timeout),
        onTimeout: () {
          throw ApiException.timeout();
        },
      );
      return _handleResponse(response);
    } on http.ClientException {
      throw ApiException.connectionError();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.serverError('فشل في حذف البيانات. يرجى المحاولة مرة أخرى لاحقاً.');
    }
  }

  Future<dynamic> uploadFile(String endpoint, File file, String fieldName) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );

      // Add headers
      request.headers.addAll(buildMultipartHeaders());

      // Add file
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        fieldName,
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(
        Duration(milliseconds: ApiConfig.timeout),
        onTimeout: () {
          throw ApiException.timeout();
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on http.ClientException {
      throw ApiException.connectionError();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.serverError('فشل في رفع الملف. يرجى المحاولة مرة أخرى لاحقاً.');
    }
  }

  Future<dynamic> postRaw(String endpoint, String rawBody) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(),
        body: rawBody,
      ).timeout(
        Duration(milliseconds: ApiConfig.timeout),
        onTimeout: () {
          throw ApiException.timeout();
        },
      );
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      print('ApiClient POST RAW ClientException: $e');
      throw ApiException.connectionError();
    } catch (e) {
      print('ApiClient POST RAW Generic Exception: $e');
      if (e is ApiException) rethrow;
      throw ApiException.serverError('فشل في إرسال البيانات. يرجى المحاولة مرة أخرى لاحقاً.');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final decoded = json.decode(response.body);
    
    // Check for business errors first, regardless of status code
    if (decoded is Map && decoded['success'] == false) {
      // Return backend business error as a response object
      return {
        'success': false,
        'message': decoded['message'],
        'data': decoded['data'],
        'resultStatus': decoded['resultStatus'],
        'errorType': decoded['errorType'],
      };
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else if (decoded is Map && decoded['message'] != null) {
      // Return backend business error as a response object
      return {
        'success': false,
        'message': decoded['message'],
        'data': decoded['data'],
        'resultStatus': decoded['resultStatus'],
        'errorType': decoded['errorType'],
      };
    } else {
      // Only throw for real server/network errors
      throw ApiException.serverError('حدث خطأ في الخادم. الرمز: [${response.statusCode}]', response.statusCode.toString());
    }
  }
} 