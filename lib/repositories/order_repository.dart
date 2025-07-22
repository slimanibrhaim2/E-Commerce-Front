import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_response.dart';
import '../models/order.dart';
import 'dart:convert';

class OrderRepository {
  final ApiClient apiClient;
  OrderRepository(this.apiClient);

  Future<ApiResponse<Order>> checkout(String addressId) async {
    final response = await apiClient.postRaw(ApiEndpoints.orderCheckout, '"$addressId"');
    print('Checkout API response: $response');
    
    return ApiResponse(
      data: response['data'] != null ? Order.fromJson(response['data']) : null,
      message: response['message'] as String?,
      success: response['success'] ?? true,
      resultStatus: response['resultStatus'] as int?,
    );
  }

  Future<ApiResponse<List<Order>>> getMyOrders({int pageNumber = 1, int pageSize = 10}) async {
    try {
      final queryParams = '?pageNumber=$pageNumber&pageSize=$pageSize';
      final endpoint = '${ApiEndpoints.myOrders}$queryParams';
      final response = await apiClient.get(endpoint);
      
      final outerData = response['data'];
      List<Order> orders = [];
      
      if (outerData is Map && outerData.containsKey('data')) {
        final innerData = outerData['data'];
        if (innerData is List) {
          orders = innerData.map((json) => Order.fromJson(json)).toList();
        }
      }

      // Extract pagination metadata from backend response
      Map<String, dynamic>? paginationMetadata;
      if (outerData is Map) {
        paginationMetadata = {
          'pageNumber': outerData['pageNumber'],
          'pageSize': outerData['pageSize'],
          'totalPages': outerData['totalPages'],
          'totalCount': outerData['totalCount'],
          'hasPreviousPage': outerData['hasPreviousPage'],
          'hasNextPage': outerData['hasNextPage'],
        };
      }
      
      return ApiResponse(
        data: orders,
        message: response['message'] as String?,
        success: response['success'] ?? true,
        resultStatus: response['resultStatus'] as int?,
        metadata: paginationMetadata,
      );
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  Future<ApiResponse<Order>> getOrderById(String orderId) async {
    final response = await apiClient.get('${ApiEndpoints.orderDetail}$orderId');
    final data = response['data'];
    return ApiResponse(
      data: data != null ? Order.fromJson(data) : null,
      message: response['message'] as String?,
      success: response['success'] ?? true,
      resultStatus: response['resultStatus'] as int?,
    );
  }

  Future<ApiResponse<bool>> cancelOrder(String orderId) async {
    final response = await apiClient.post('${ApiEndpoints.orderCancel}$orderId/cancel', {});
    return ApiResponse(
      data: response['data'] as bool?,
      message: response['message'] as String?,
      success: response['success'] ?? true,
      resultStatus: response['resultStatus'] as int?,
    );
  }

  Future<ApiResponse<bool>> markOrderDelivered(String orderId) async {
    final response = await apiClient.post('${ApiEndpoints.markOrderDelivered}$orderId/mark-delivered', {});
    return ApiResponse(
      data: response['data'] as bool?,
      message: response['message'] as String?,
      success: response['success'] ?? true,
      resultStatus: response['resultStatus'] as int?,
    );
  }
} 