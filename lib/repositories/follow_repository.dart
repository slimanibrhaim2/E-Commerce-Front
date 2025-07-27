import '../core/api/api_base_repository.dart' as api;
import '../core/api/api_endpoints.dart';
import '../core/api/api_response.dart';

class FollowRepository extends api.ApiRepositoryBase<void> {
  FollowRepository(super.apiClient);

  /// Follow a user
  /// POST /api/users/followers/{followingId}
  Future<ApiResponse<void>> followUser(String userId) async {
    try {
      print('Following user with ID: $userId');
      
      final endpoint = '${ApiEndpoints.userFollowers}/$userId';
      final response = await apiClient.post(endpoint, {});
      
      print('Follow response: $response');
      
      return ApiResponse<void>(
        data: null,
        message: response['message'] as String?,
        success: response['success'] ?? true,
        resultStatus: response['resultStatus'] as int?,
      );
    } catch (e) {
      print('Error following user: $e');
      rethrow;
    }
  }

  /// Unfollow a user
  /// DELETE /{followingId}
  Future<ApiResponse<void>> unfollowUser(String followingId) async {
    try {
      print('Unfollowing user with following ID: $followingId');
      
      final endpoint = '/$followingId';
      final response = await apiClient.delete(endpoint);
      
      print('Unfollow response: $response');
      
      return ApiResponse<void>(
        data: null,
        message: response['message'] as String?,
        success: response['success'] ?? true,
        resultStatus: response['resultStatus'] as int?,
      );
    } catch (e) {
      print('Error unfollowing user: $e');
      rethrow;
    }
  }
} 