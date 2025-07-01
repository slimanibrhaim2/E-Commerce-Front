import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_response.dart';
import '../models/payment_method.dart';

class PaymentRepository {
  final ApiClient apiClient;
  PaymentRepository(this.apiClient);

  Future<ApiResponse<List<PaymentMethod>>> getPaymentMethods() async {
    final response = await apiClient.get(ApiEndpoints.paymentMethods);
    final outerData = response['data'];
    List<PaymentMethod> paymentMethods = [];
    if (outerData is Map && outerData.containsKey('data')) {
      final innerData = outerData['data'];
      if (innerData is List) {
        paymentMethods = innerData.map((json) => PaymentMethod.fromJson(json)).toList();
      }
    }
    return ApiResponse(
      data: paymentMethods,
      message: response['message'] as String?,
      success: response['success'] ?? true,
      resultStatus: response['resultStatus'] as int?,
    );
  }

  Future<ApiResponse<dynamic>> processPayment({
    required String orderId,
    required double amount,
    required String paymentMethodId,
    String? paymentDetails,
  }) async {
    final response = await apiClient.post(ApiEndpoints.paymentProcess, {
      'orderId': orderId,
      'amount': amount,
      'paymentMethodId': paymentMethodId,
      'paymentDetails': paymentDetails ?? '',
    });
    return ApiResponse(
      data: response['data'],
      message: response['message'] as String?,
      success: response['success'] ?? true,
      resultStatus: response['resultStatus'] as int?,
    );
  }
} 