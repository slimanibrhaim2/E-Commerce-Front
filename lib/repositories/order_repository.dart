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
    return ApiResponse.fromJson(response, (data) => Order.fromJson(data));
  }

  Future<ApiResponse<List<Order>>> getMyOrders() async {
    final response = await apiClient.get(ApiEndpoints.myOrders);
    final outerData = response['data'];
    List<Order> orders = [];
    if (outerData is Map && outerData.containsKey('data')) {
      final innerData = outerData['data'];
      if (innerData is List) {
        orders = innerData.map((json) => Order.fromJson(json)).toList();
      }
    }
    return ApiResponse(
      data: orders,
      message: response['message'] as String?,
      success: response['success'] ?? true,
      resultStatus: response['resultStatus'] as int?,
    );
  }
} 