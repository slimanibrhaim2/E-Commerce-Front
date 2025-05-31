import '../core/api/api_client.dart';
import '../models/user.dart';
import '../core/api/api_endpoints.dart';

class UserRepository {
  final ApiClient apiClient;

  UserRepository(this.apiClient);

  Future<User> fetchUserProfile() async {
    final response = await apiClient.get(ApiEndpoints.userProfile);
    return User.fromJson(response);
  }

  Future<User> updateUserProfile(User user) async {
    final response = await apiClient.put(ApiEndpoints.userProfile, user.toJson());
    return User.fromJson(response);
  }
} 