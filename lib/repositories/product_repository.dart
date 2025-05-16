import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_repository.dart';
import '../models/product.dart';

class ProductRepository implements BaseRepository<Product> {
  final String baseUrl = 'https://api.escuelajs.co/api/v1';
  
  ProductRepository();

  @override
  Future<List<Product>> getAll() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      
      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        
        return productsJson.map((json) => Product(
          id: json['id'],
          name: json['title'],
          description: json['description'],
          price: json['price'].toDouble(),
          imageUrl: json['images'][0],
          category: json['category']['name'],
        )).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  @override
  Future<Product?> getById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/$id'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Product(
          id: json['id'],
          name: json['title'],
          description: json['description'],
          price: json['price'].toDouble(),
          imageUrl: json['images'][0],
          category: json['category']['name'],
        );
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load product: $e');
    }
  }

  // These methods are required by the interface but we're not implementing them yet
  @override
  Future<Product> create(Product item) {
    throw UnimplementedError('Create not implemented yet');
  }

  @override
  Future<Product> update(Product item) {
    throw UnimplementedError('Update not implemented yet');
  }

  @override
  Future<bool> delete(int id) {
    throw UnimplementedError('Delete not implemented yet');
  }
} 