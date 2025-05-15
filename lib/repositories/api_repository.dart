import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_repository.dart';
import '../models/product.dart';

class ApiRepository implements BaseRepository<Product> {
  final String baseUrl = 'https://dummyjson.com';
  
  ApiRepository();

  @override
  Future<List<Product>> getAll() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productsJson = data['products'];
        
        return productsJson.map((json) => Product(
          id: json['id'],
          name: json['title'],
          description: json['description'],
          price: json['price'].toDouble(),
          imageUrl: json['images'][0], // Using the first image from the array
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

  @override
  Future<Product> create(Product item) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': item.name,
          'description': item.description,
          'price': item.price,
          'images': [item.imageUrl],
        }),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Product(
          id: json['id'],
          name: json['title'],
          description: json['description'],
          price: json['price'].toDouble(),
          imageUrl: json['images'][0],
        );
      } else {
        throw Exception('Failed to create product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  @override
  Future<Product> update(Product item) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/${item.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': item.name,
          'description': item.description,
          'price': item.price,
          'images': [item.imageUrl],
        }),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Product(
          id: json['id'],
          name: json['title'],
          description: json['description'],
          price: json['price'].toDouble(),
          imageUrl: json['images'][0],
        );
      } else {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  @override
  Future<bool> delete(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }
} 