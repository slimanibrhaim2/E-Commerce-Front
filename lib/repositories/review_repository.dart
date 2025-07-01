import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_response.dart';
import '../models/review.dart';

class ReviewRepository {
  final ApiClient apiClient;
  
  ReviewRepository(this.apiClient);

  Future<ApiResponse<Review>> createReview(Review review) async {
    final reviewData = review.toJson();
    print('Sending review data to API: $reviewData');
    
    final response = await apiClient.post(ApiEndpoints.reviews, reviewData);
    print('API response for review creation: $response');
    
    // The API returns data as a string GUID, not a JSON object
    // So we'll create a Review object with the submitted data and the returned ID
    Review? createdReview;
    if (response['success'] == true && response['data'] != null) {
      // Create a new Review object with the submitted data and the returned ID
      createdReview = review.copyWith(
        id: response['data'] as String,
      );
    }
    
    return ApiResponse(
      data: createdReview,
      message: response['message'] as String?,
      success: response['success'] ?? true,
      resultStatus: response['resultStatus'] as int?,
    );
  }
} 