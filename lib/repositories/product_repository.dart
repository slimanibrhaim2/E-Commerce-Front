import '../core/api/api_endpoints.dart';
import '../core/api/api_base_repository.dart' as api;
import '../models/product.dart';
import '../core/api/api_response.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ProductRepository extends api.ApiRepositoryBase<Product> {
  ProductRepository(super.apiClient);

  Future<bool> handleBooleanApiCall(Future<bool> Function() apiCall) async {
    try {
      return await apiCall();
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<List<Product>>> getProductsByCategory(String categoryId, {int pageNumber = 1, int pageSize = 10}) async {
    try {
      final queryParams = '?pageNumber=$pageNumber&pageSize=$pageSize';
      final endpoint = '${ApiEndpoints.categoryProducts}$categoryId$queryParams';
      final response = await apiClient.get(endpoint);
      
      List<Product> products = [];
      final outerData = response['data'];
      
      if (outerData is Map && outerData.containsKey('data')) {
        final innerData = outerData['data'];
        if (innerData is List) {
          products = innerData.map((json) => Product.fromJson(json)).toList();
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
        data: products,
        message: response['message'] as String?,
        metadata: paginationMetadata,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<List<Product>>> getProducts({int pageNumber = 1, int pageSize = 10}) async {
    try {
      final queryParams = '?pageNumber=$pageNumber&pageSize=$pageSize';
      final endpoint = '${ApiEndpoints.products}$queryParams';
      final response = await apiClient.get(endpoint);
      
      List<Product> products = [];
      final outerData = response['data'];
      
      if (outerData is Map && outerData.containsKey('data')) {
        final innerData = outerData['data'];
        if (innerData is List) {
          products = innerData.map((json) => Product.fromJson(json)).toList();
        }
      } else if (response is List) {
        products = response.map((json) => Product.fromJson(json)).toList();
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
        data: products,
        message: response['message'] as String?,
        metadata: paginationMetadata,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<List<Product>>> getMyProducts({int pageNumber = 1, int pageSize = 10}) async {
    try {
      final queryParams = '?pageNumber=$pageNumber&pageSize=$pageSize';
      final endpoint = '${ApiEndpoints.myProducts}$queryParams';
      final response = await apiClient.get(endpoint);
      
      List<Product> products = [];
      final outerData = response['data'];
      
      if (outerData is Map && outerData.containsKey('data')) {
        final innerData = outerData['data'];
        if (innerData is List) {
          products = innerData.map((json) => Product.fromJson(json)).toList();
        }
      } else if (response is List) {
        products = response.map((json) => Product.fromJson(json)).toList();
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
        data: products,
        message: response['message'] as String?,
        metadata: paginationMetadata,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Product?> getById(String id) async {
    try {
      final response = await apiClient.get('${ApiEndpoints.productDetail}$id');
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          if (response['data'] is Map<String, dynamic>) {
            return Product.fromJson(response['data']);
          } else {
            return null; // Product not found, data is null
          }
        }
        // Unwrapped response support
        return Product.fromJson(response);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<List<Product>>> getAll() async {
    return getProducts();
  }

  // Keep the original getMyProducts method for backward compatibility
  Future<List<Product>> getMyProductsLegacy() async {
    return handleListApiCall(() async {
      final response = await apiClient.get(ApiEndpoints.myProducts);
      if (response is Map<String, dynamic> &&
          response.containsKey('data') &&
          response['data'] is Map<String, dynamic> &&
          response['data'].containsKey('data') &&
          response['data']['data'] is List) {
        final List<dynamic> productListJson = response['data']['data'];
        return productListJson.map((json) => Product.fromJson(json)).toList();
      } else if (response is List) {
        return response.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Invalid response format for getMyProducts');
    });
  }

  Future<ApiResponse<Product>> create(Product item, {List<File>? images}) async {
    try {
      // Always use multipart form data, even if there are no images
      var uri = Uri.parse('${apiClient.baseUrl}${ApiEndpoints.aggregateProduct}');
      print('Creating product at: $uri');
      print('Product data: ${item.toJson()}');
      print('Number of images:  [32m${images?.length ?? 0} [0m');
      
      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll(apiClient.buildMultipartHeaders());
      print('Request headers: ${request.headers}');

      // Add text fields
      request.fields['Name'] = item.name;
      request.fields['Description'] = item.description;
      request.fields['Price'] = item.price.toString();
      request.fields['Sku'] = item.sku;
      if (item.serialNumber != null && item.serialNumber!.isNotEmpty) {
        request.fields['SerialNumber'] = item.serialNumber!;
      }
      request.fields['StockQuantity'] = item.stockQuantity.toString();
      request.fields['IsAvailable'] = item.isAvailable.toString();
      request.fields['CategoryId'] = item.categoryId;
      
      // Add features as JSON string
      if (item.features.isNotEmpty) {
        request.fields['Features'] = json.encode(item.features.map((f) => f.toJson()).toList());
      }

      print('Request fields: ${request.fields}');

      // Add image files if any
      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          final image = images[i];
          print('Adding image file ${i + 1}: ${image.path}');
          
          // Determine MIME type based on file extension
          String mimeType = 'image/png'; // default
          final extension = image.path.split('.').last.toLowerCase();
          switch (extension) {
            case 'jpg':
            case 'jpeg':
              mimeType = 'image/jpeg';
              break;
            case 'png':
              mimeType = 'image/png';
              break;
            case 'gif':
              mimeType = 'image/gif';
              break;
          }
          
          print('Detected MIME type: $mimeType for file extension: $extension');
          
          request.files.add(await http.MultipartFile.fromPath(
            'mediaFiles', // Use 'mediaFiles' as the field name for multiple images (like profile upload)
            image.path,
            contentType: MediaType.parse(mimeType),
          ));
          print('Image file ${i + 1} added successfully with MIME type: $mimeType');
        }
      }

      // Send request
      print('Sending product creation request...');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print('Product creation response: \nStatus: ${response.statusCode}\nBody: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        final newProduct = item.copyWith(id: data['data']?.toString());
        
        return ApiResponse(
          data: newProduct,
          success: data['success'] ?? true,
          message: data['message'],
          resultStatus: data['resultStatus'] as int?,
        );
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to create product: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error creating product: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Product> update(Product item) async {
    return handleApiCall(() async {
      final response = await apiClient.post(
        '${ApiEndpoints.productDetail}${item.id}',
        item.toJson(),
      );
      if (response is Map<String, dynamic>) {
        return Product.fromJson(response);
      }
      throw Exception('Invalid response format');
    });
  }

  Future<bool> delete(String id) async {
    try {
      await apiClient.delete('${ApiEndpoints.deleteProduct}$id');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<List<Product>>> searchProducts(String query, {int pageNumber = 1, int pageSize = 10}) async {
      try {
        // URL encode the query parameter
        final encodedQuery = Uri.encodeComponent(query.trim());
      final searchUrl = '${ApiEndpoints.productSearch}?name=$encodedQuery&pageNumber=$pageNumber&pageSize=$pageSize';
        
        print('Searching products with URL: $searchUrl');
        print('Original query: "$query"');
        print('Encoded query: "$encodedQuery"');
        
        final response = await apiClient.get(searchUrl);
        
        print('Search response: $response');
        
      List<Product> products = [];
      final outerData = response['data'];
      
      if (outerData is Map && outerData.containsKey('data')) {
        final innerData = outerData['data'];
        if (innerData is List) {
          products = innerData.map((json) => Product.fromJson(json)).toList();
        }
      }
      
          print('Found ${products.length} products');

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
        data: products,
        message: response['message'] as String?,
        success: response['success'] ?? true,
        resultStatus: response['resultStatus'] as int?,
        metadata: paginationMetadata,
      );
      } catch (e) {
        print('Error in searchProducts: $e');
        print('Error type: ${e.runtimeType}');
        rethrow;
      }
  }

  Future<ApiResponse<Product>> updateProduct(Product item, {List<File>? images}) async {
    try {
      // Use multipart form data for update as well
      var uri = Uri.parse('${apiClient.baseUrl}${ApiEndpoints.aggregateProduct}/${item.id}');
      print('Updating product at: $uri');
      print('Product data: ${item.toJson()}');
      print('Number of images: ${images?.length ?? 0}');

      var request = http.MultipartRequest('PUT', uri);

      // Add headers
      request.headers.addAll(apiClient.buildMultipartHeaders());
      print('Request headers: ${request.headers}');

      // Add text fields
      request.fields['Name'] = item.name;
      request.fields['Description'] = item.description;
      request.fields['Price'] = item.price.toString();
      request.fields['Sku'] = item.sku;
      if (item.serialNumber != null && item.serialNumber!.isNotEmpty) {
        request.fields['SerialNumber'] = item.serialNumber!;
      }
      request.fields['StockQuantity'] = item.stockQuantity.toString();
      request.fields['IsAvailable'] = item.isAvailable.toString();
      request.fields['CategoryId'] = item.categoryId;

      // Add features as JSON string
      if (item.features.isNotEmpty) {
        request.fields['Features'] = json.encode(item.features.map((f) => f.toJson()).toList());
      }

      print('Request fields: ${request.fields}');

      // Add image files if any
      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          final image = images[i];
          print('Adding image file ${i + 1}: ${image.path}');

          // Determine MIME type based on file extension
          String mimeType = 'image/png'; // default
          final extension = image.path.split('.').last.toLowerCase();
          switch (extension) {
            case 'jpg':
            case 'jpeg':
              mimeType = 'image/jpeg';
              break;
            case 'png':
              mimeType = 'image/png';
              break;
            case 'gif':
              mimeType = 'image/gif';
              break;
          }

          print('Detected MIME type: $mimeType for file extension: $extension');

          request.files.add(await http.MultipartFile.fromPath(
            'mediaFiles',
            image.path,
            contentType: MediaType.parse(mimeType),
          ));
          print('Image file ${i + 1} added successfully with MIME type: $mimeType');
        }
      }

      // Send request
      print('Sending product update request...');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print('Product update response: \nStatus: ${response.statusCode}\nBody: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        final updatedProduct = item.copyWith(id: data['data']?.toString());

        return ApiResponse(
          data: updatedProduct,
          success: data['success'] ?? true,
          message: data['message'],
          resultStatus: data['resultStatus'] as int?,
        );
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update product: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error updating product: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
} 