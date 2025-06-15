import '../core/api/api_client.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import '../core/api/api_endpoints.dart';

class UserRepository {
  final ApiClient apiClient;

  UserRepository(this.apiClient);

  // Fetch current user profile
  Future<ApiResponse<User>> fetchUserProfile() async {
    final response = await apiClient.get(ApiEndpoints.userProfile);
    return ApiResponse(
      data: User.fromJson(response),
      message: response['message'] as String?,
    );
  }

  // Update current user profile
  Future<ApiResponse<User>> updateUserProfile(User user) async {
    final response = await apiClient.put(ApiEndpoints.userProfile, user.toJson());
    return ApiResponse(
      data: User.fromJson(response),
      message: response['message'] as String?,
    );
  }

  // Create a new user
  Future<ApiResponse<User>> createUser(User user) async {
    final response = await apiClient.post(ApiEndpoints.users, user.toJson());
    return ApiResponse(
      data: User.fromJson(response['user'] ?? response),
      message: response['message'] as String?,
    );
  }

  // List users with pagination
  Future<ApiResponse<List<User>>> listUsers({int pageNumber = 1, int pageSize = 10}) async {
    final response = await apiClient.get(
      '${ApiEndpoints.users}?pageNumber=$pageNumber&pageSize=$pageSize',
    );
    List<User> users;
    if (response is List) {
      users = response.map((json) => User.fromJson(json)).toList();
    } else if (response is Map && response['items'] is List) {
      users = (response['items'] as List).map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Invalid response format');
    }
    return ApiResponse(
      data: users,
      message: response['message'] as String?,
    );
  }

  // Get user by ID
  Future<ApiResponse<User>> getUserById(String id) async {
    final response = await apiClient.get('${ApiEndpoints.userDetail}$id');
    return ApiResponse(
      data: User.fromJson(response),
      message: response['message'] as String?,
    );
  }

  // Update user by ID
  Future<ApiResponse<User>> updateUser(String id, User user) async {
    final response = await apiClient.put('${ApiEndpoints.userDetail}$id', user.toJson());
    return ApiResponse(
      data: User.fromJson(response),
      message: response['message'] as String?,
    );
  }

  // Delete user by ID
  Future<ApiResponse<void>> deleteUser(String id) async {
    final response = await apiClient.delete('${ApiEndpoints.userDetail}$id');
    return ApiResponse(
      message: response['message'] as String?,
    );
  }

  // Search users by name with pagination
  Future<ApiResponse<List<User>>> searchUsers(String name, {int pageNumber = 1, int pageSize = 10}) async {
    final response = await apiClient.get(
      '${ApiEndpoints.userSearch}?name=$name&pageNumber=$pageNumber&pageSize=$pageSize',
    );
    List<User> users;
    if (response is List) {
      users = response.map((json) => User.fromJson(json)).toList();
    } else if (response is Map && response['items'] is List) {
      users = (response['items'] as List).map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Invalid response format');
    }
    return ApiResponse(
      data: users,
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