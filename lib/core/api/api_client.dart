import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'api_exception.dart';
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

  Map<String, String> _buildHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_jwtToken != null && _jwtToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_jwtToken';
    }
    return headers;
  }

  Map<String, String> _buildMultipartHeaders() {
    final headers = <String, String>{};
    if (_jwtToken != null && _jwtToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_jwtToken';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(),
      ).timeout(
        Duration(milliseconds: ApiConfig.timeout),
        onTimeout: () {
          throw ApiException.timeout();
        },
      );
      return _handleResponse(response);
    } on http.ClientException catch (e) {
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
    } on http.ClientException catch (e) {
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
    } on http.ClientException catch (e) {
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
      request.headers.addAll(_buildMultipartHeaders());

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
    } on http.ClientException catch (e) {
      throw ApiException.connectionError();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.serverError('فشل في رفع الملف. يرجى المحاولة مرة أخرى لاحقاً.');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final decoded = json.decode(response.body);
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