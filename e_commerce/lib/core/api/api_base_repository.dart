import 'api_client.dart';

abstract class ApiRepositoryBase<T> {
  final ApiClient apiClient;

  ApiRepositoryBase(this.apiClient);

  Future<T> handleApiCall(Future<T> Function() apiCall) async {
    try {
     return await apiCall();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<T>> handleListApiCall(Future<List<T>> Function() apiCall) async {
    try {
      return await apiCall();
    } catch (e) {
      rethrow;
    }
  }
} 