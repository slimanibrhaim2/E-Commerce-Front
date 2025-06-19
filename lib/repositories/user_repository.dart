import '../core/api/api_client.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import '../core/api/api_endpoints.dart';
import 'dart:io';

class UserRepository {
  final ApiClient apiClient;

  UserRepository(this.apiClient);

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
    print('User profile response: ' + response.toString());
    return ApiResponse(
      data: User.fromJson(response['data'] as Map<String, dynamic>),
      message: response['message'] as String?,
    );
  }

  // Update current user profile
  Future<ApiResponse<User>> updateCurrentUserProfile(User user) async {
    try {
      final response = await apiClient.put(ApiEndpoints.userProfile, user.toJson());
      print('Update profile response: ' + response.toString());
      
      if (response == null) {
        throw Exception('Failed to update profile: No response from server');
      }

      final responseData = response['data'];
      if (responseData == null) {
        return ApiResponse(
          data: user, // Return the original user object if no data in response
          message: response['message'] as String? ?? 'Profile updated successfully',
        );
      }

      if (responseData is! Map<String, dynamic>) {
        throw Exception('Invalid response format from server');
      }

      return ApiResponse(
        data: User.fromJson(responseData),
        message: response['message'] as String?,
      );
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