import '../core/api/api_client.dart';
import '../models/user.dart';
import '../core/api/api_endpoints.dart';

class UserRepository {
  final ApiClient apiClient;

  UserRepository(this.apiClient);

  // Fetch current user profile
  Future<User> fetchUserProfile() async {
    final response = await apiClient.get(ApiEndpoints.userProfile);
    return User.fromJson(response);
  }

  // Update current user profile
  Future<User> updateUserProfile(User user) async {
    final response = await apiClient.put(ApiEndpoints.userProfile, user.toJson());
    return User.fromJson(response);
  }

  // Create a new user
  Future<Map<String, dynamic>> createUser(User user) async {
    final response = await apiClient.post(ApiEndpoints.users, user.toJson());
    // If backend returns { user: {...}, message: '...' }
    if (response is Map && response.containsKey('message')) {
      return {
        'user': User.fromJson(response['user'] ?? response),
        'message': response['message'] as String,
      };
    }
    // If backend returns just the user object
    return {
      'user': User.fromJson(response),
      'message': null,
    };
  }

  // List users with pagination
  Future<List<User>> listUsers({int pageNumber = 1, int pageSize = 10}) async {
    final response = await apiClient.get(
      '${ApiEndpoints.users}?pageNumber=$pageNumber&pageSize=$pageSize',
    );
    if (response is List) {
      return response.map((json) => User.fromJson(json)).toList();
    } else if (response is Map && response['items'] is List) {
      // In case API returns { items: [...], ... }
      return (response['items'] as List).map((json) => User.fromJson(json)).toList();
    }
    throw Exception('Invalid response format');
  }

  // Get user by ID
  Future<User> getUserById(String id) async {
    final response = await apiClient.get('${ApiEndpoints.userDetail}$id');
    return User.fromJson(response);
  }

  // Update user by ID
  Future<User> updateUser(String id, User user) async {
    final response = await apiClient.put('${ApiEndpoints.userDetail}$id', user.toJson());
    return User.fromJson(response);
  }

  // Delete user by ID
  Future<void> deleteUser(String id) async {
    await apiClient.delete('${ApiEndpoints.userDetail}$id');
  }

  // Search users by name with pagination
  Future<List<User>> searchUsers(String name, {int pageNumber = 1, int pageSize = 10}) async {
    final response = await apiClient.get(
      '${ApiEndpoints.userSearch}?name=$name&pageNumber=$pageNumber&pageSize=$pageSize',
    );
    if (response is List) {
      return response.map((json) => User.fromJson(json)).toList();
    } else if (response is Map && response['items'] is List) {
      return (response['items'] as List).map((json) => User.fromJson(json)).toList();
    }
    throw Exception('Invalid response format');
  }
} 