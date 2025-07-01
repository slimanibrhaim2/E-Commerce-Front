import '../core/api/api_client.dart';
import '../models/address.dart';
import '../core/api/api_response.dart';
import '../core/api/api_endpoints.dart';

class AddressRepository {
  final ApiClient apiClient;

  AddressRepository(this.apiClient);

  // Fetch all addresses for current user
  Future<ApiResponse<List<Address>>> fetchAddresses() async {
    final response = await apiClient.get(ApiEndpoints.addresses);
    print('Addresses response: $response');

    List<Address> addresses = [];
    final outerData = response['data'];
    if (outerData is Map && outerData.containsKey('data')) {
      final innerData = outerData['data'];
      if (innerData is List) {
        addresses = innerData.map((json) => Address.fromJson(json)).toList();
      }
    }

    return ApiResponse(
      data: addresses,
      message: response['message'] as String?,
    );
  }

  // Fetch single address by ID
  Future<ApiResponse<Address>> fetchAddress(String addressId) async {
    final response = await apiClient.get('${ApiEndpoints.addressDetail}$addressId');
    final data = response['data'];
    return ApiResponse(
      data: data != null ? Address.fromJson(data) : null,
      message: response['message'] as String?,
    );
  }

  // Create new address
  Future<ApiResponse<Address>> createAddress(Address address) async {
    final addressData = address.toJson();
    print('Sending address data to API: $addressData');
    
    final response = await apiClient.post(ApiEndpoints.addresses, addressData);
    print('API response for address creation: $response');
    
    final data = response['data'];
    return ApiResponse(
      data: data != null ? Address.fromJson(data) : null,
      message: response['message'] as String?,
    );
  }

  // Update existing address
  Future<ApiResponse<Address>> updateAddress(String addressId, Address address) async {
    final response = await apiClient.put('${ApiEndpoints.addressDetail}$addressId', address.toJson());
    final data = response['data'];
    return ApiResponse(
      data: data != null ? Address.fromJson(data) : null,
      message: response['message'] as String?,
    );
  }

  // Delete address
  Future<ApiResponse<void>> deleteAddress(String addressId) async {
    final response = await apiClient.delete('${ApiEndpoints.addressDetail}$addressId');
    return ApiResponse(
      message: response['message'] as String?,
    );
  }
} 