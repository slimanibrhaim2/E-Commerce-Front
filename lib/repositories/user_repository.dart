import '../core/api/api_client.dart';
import '../models/user.dart';
import '../core/api/api_response.dart';
import '../core/api/api_endpoints.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UserRepository {
  final ApiClient apiClient;

  UserRepository(this.apiClient);

  void setToken(String? token) {
    apiClient.setToken(token);
  }

  // Upload profile image
  Future<ApiResponse<String>> uploadProfileImage(File imageFile) async {
    try {
      final response = await apiClient.uploadFile(
        '/api/users/profile-image',
        imageFile,
        'profileImage',
      );
      
      return ApiResponse<String>(
        data: response['imageUrl'] as String? ?? response['data'] as String?,
        message: response['message'] as String?,
        success: response['success'] ?? true,
      );
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Fetch current user profile
  Future<ApiResponse<User>> fetchUserProfile() async {
    final response = await apiClient.get(ApiEndpoints.userProfile);
    print('User profile response: $response');
    return ApiResponse(
      data: User.fromJson(response['data'] as Map<String, dynamic>),
      message: response['message'] as String?,
    );
  }

  // Update current user profile
  Future<ApiResponse<User>> updateCurrentUserProfile(User user, {File? profileImage}) async {
    try {
      var uri = Uri.parse('${apiClient.baseUrl}${ApiEndpoints.userProfile}');
      print('Updating profile at: $uri');
      print('User data: ${user.toJson()}');
      print('Profile image: ${profileImage?.path}');
      
      var request = http.MultipartRequest('PUT', uri);

      // Add headers (including auth if needed)
      request.headers.addAll(apiClient.buildMultipartHeaders());
      print('Request headers: ${request.headers}');

      // Add text fields
      request.fields['FirstName'] = user.firstName ?? '';
      request.fields['MiddleName'] = user.middleName ?? '';
      request.fields['LastName'] = user.lastName ?? '';
      request.fields['PhoneNumber'] = user.phoneNumber ?? '';
      request.fields['Email'] = user.email ?? '';
      request.fields['Description'] = user.description ?? '';
      if (profileImage != null) {
        // If uploading a new image, ProfilePhoto should be empty
        request.fields['ProfilePhoto'] = '';
        print('Setting ProfilePhoto to empty for new image upload');
      } else {
        // If not uploading a new image, keep the current value
        request.fields['ProfilePhoto'] = user.profilePhoto ?? '';
        print('Keeping existing ProfilePhoto: ${user.profilePhoto}');
      }

      print('Request fields: ${request.fields}');

      // Add image if present
      if (profileImage != null) {
        print('Adding image file: ${profileImage.path}');
        
        // Determine MIME type based on file extension
        String mimeType = 'image/png'; // default
        final extension = profileImage.path.split('.').last.toLowerCase();
        switch (extension) {
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          case 'png':
            mimeType = 'image/png';
            break;
          case 'gif':
            mimeType = 'image/gif';
            break;
        }
        
        print('Detected MIME type: $mimeType for file extension: $extension');
        
        request.files.add(await http.MultipartFile.fromPath(
          'profileImage', 
          profileImage.path,
          contentType: MediaType.parse(mimeType),
        ));
        print('Image file added successfully with MIME type: $mimeType');
      }

      // Send request
      print('Sending request...');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print('Profile upload response: \nStatus: ${response.statusCode}\nBody: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        return ApiResponse(
          data: data['data'] != null && data['data'] is Map<String, dynamic>
              ? User.fromJson(data['data'])
              : user, // fallback to the user you sent
          message: data['message'],
          success: data['success'] ?? true,
          resultStatus: data['resultStatus'] as int?,
        );
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
  
  // Delete current user profile
  Future<ApiResponse<void>> deleteCurrentUserProfile() async {
    final response = await apiClient.delete(ApiEndpoints.userProfile);
    return ApiResponse(
      message: response['message'] as String?,
    );
  }

  // Register user with OTP (step 1)
  Future<ApiResponse<void>> registerUser(User user) async {
    final response = await apiClient.post(
      ApiEndpoints.register,
      {"userDTO": user.toJson()},
    );
    return ApiResponse.fromJson(response);
  }

  // Verify OTP (step 2)
  Future<ApiResponse<String>> verifyOtp(String phoneNumber, String otp) async {
    final response = await apiClient.post(
      ApiEndpoints.verifyOtp,
      {"phoneNumber": phoneNumber, "otp": otp},
    );
    // Assume JWT is returned as 'token' in response or in data
    return ApiResponse<String>(
      data: response['token'] as String? ?? response['data'] as String?,
      message: response['message'] as String?,
      success: response['success'] ?? true,
      resultStatus: response['resultStatus'] as int?,
    );
  }

  // Login (step 1)
  Future<ApiResponse<void>> login(String phoneNumber) async {
    final response = await apiClient.post(
      ApiEndpoints.login,
      {"phoneNumber": phoneNumber},
    );
    return ApiResponse.fromJson(response);
  }

  // Verify OTP for login (step 2)
  Future<ApiResponse<String>> verifyLoginOtp(String phoneNumber, String otp) async {
    final response = await apiClient.post(
      ApiEndpoints.verifyOtp,
      {"phoneNumber": phoneNumber, "otp": otp},
    );
    return ApiResponse<String>(
      data: response['token'] as String? ?? response['data'] as String?,
      message: response['message'] as String?,
      success: response['success'] ?? true,
      resultStatus: response['resultStatus'] as int?,
    );
  }

  Future<String> refreshToken(String oldToken) async {
    final response = await apiClient.post(
      '/auth/refresh',
      {'token': oldToken},
    );
    return response['token'];
  }
} 